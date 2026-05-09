/**
 * Seeds/repairs hotel.images in MongoDB using Pexels search results.
 *
 * Usage (PowerShell):
 *   $env:MONGO_URI="mongodb+srv://..."; $env:PEXELS_API_KEY="..."; node .\seed_hotel_images.js
 *
 * Notes:
 * - Does NOT store secrets in code.
 * - Ensures each hotel has at least MIN_IMAGES images.
 */
const { MongoClient } = require('mongodb');
const dns = require('node:dns');

const MONGO_URI = process.env.MONGO_URI;
const PEXELS_API_KEY = process.env.PEXELS_API_KEY;

const DB_NAME = process.env.MONGO_DB || 'sufar';
const COLLECTION = process.env.MONGO_HOTELS_COLLECTION || 'hotels';
const MIN_IMAGES = Number.parseInt(process.env.MIN_IMAGES || '3', 10);
const MAX_HOTELS = Number.parseInt(process.env.MAX_HOTELS || '100', 10);
const PER_HOTEL_SEARCH_LIMIT = Number.parseInt(process.env.PEXELS_PER_PAGE || '10', 10);

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function normalizeUrl(u) {
  if (!u) return '';
  const s = String(u).trim();
  if (!s) return '';
  if (s.startsWith('//')) return `https:${s}`;
  if (s.startsWith('http://')) return `https://${s.slice('http://'.length)}`;
  return s;
}

async function pexelsSearch(query) {
  const url = new URL('https://api.pexels.com/v1/search');
  url.searchParams.set('query', query);
  url.searchParams.set('per_page', String(PER_HOTEL_SEARCH_LIMIT));
  url.searchParams.set('orientation', 'landscape');

  const res = await fetch(url, {
    headers: { Authorization: PEXELS_API_KEY },
  });

  if (!res.ok) {
    const t = await res.text().catch(() => '');
    throw new Error(`Pexels ${res.status}: ${t.slice(0, 200)}`);
  }
  return res.json();
}

function extractImageUrls(pexelsJson) {
  const photos = Array.isArray(pexelsJson?.photos) ? pexelsJson.photos : [];
  const urls = [];
  for (const p of photos) {
    const src = p?.src || {};
    // Prefer large/landscape sizes for UI
    const candidate =
      src.large2x || src.large || src.landscape || src.medium || src.original;
    const u = normalizeUrl(candidate);
    if (u) urls.push(u);
  }
  // De-dup
  return [...new Set(urls)];
}

async function main() {
  if (!MONGO_URI) {
    console.error('Missing MONGO_URI env var');
    process.exitCode = 1;
    return;
  }
  if (!PEXELS_API_KEY) {
    console.error('Missing PEXELS_API_KEY env var');
    process.exitCode = 1;
    return;
  }

  // Reduce common Windows/DNS issues with Atlas SRV records.
  // This does not change the URI, it only influences resolution order.
  try {
    dns.setDefaultResultOrder('ipv4first');
  } catch (_) {
    // ignore (older Node versions)
  }

  const client = new MongoClient(MONGO_URI, {
    serverSelectionTimeoutMS: 20000,
    connectTimeoutMS: 20000,
    socketTimeoutMS: 20000,
  });

  try {
    await client.connect();
  } catch (e) {
    if (e?.code === 'EBADNAME' && String(MONGO_URI).startsWith('mongodb+srv://')) {
      console.error(
        [
          'MongoDB SRV DNS lookup failed (EBADNAME).',
          '',
          'Fix (recommended): use the "Standard connection string" from MongoDB Atlas (mongodb://...) instead of mongodb+srv://',
          'or verify the cluster hostname in your MONGO_URI is correct.',
          '',
          'Also check:',
          '- Atlas > Network Access: your IP is allowed',
          '- If your password has special characters (@ : / ? # & %), URL-encode it in the URI',
        ].join('\n'),
      );
    }
    throw e;
  }

  console.log('Connected to MongoDB');

  try {
    const db = client.db(DB_NAME);
    const hotels = db.collection(COLLECTION);

    const cursor = hotels
      .find({})
      .project({ name: 1, slug: 1, images: 1, location: 1 })
      .limit(MAX_HOTELS);

    let updated = 0;
    let scanned = 0;

    while (await cursor.hasNext()) {
      const h = await cursor.next();
      scanned += 1;

      const existing = Array.isArray(h.images)
        ? h.images.map(normalizeUrl).filter(Boolean)
        : [];

      if (existing.length >= MIN_IMAGES) continue;

      const city = h?.location?.city ? String(h.location.city) : '';
      const country = h?.location?.country ? String(h.location.country) : '';
      const name = h?.name ? String(h.name) : '';

      const queries = [
        [name, city, 'hotel'].filter(Boolean).join(' '),
        [city, country, 'hotel exterior'].filter(Boolean).join(' '),
        [city, 'luxury hotel lobby'].filter(Boolean).join(' '),
      ].filter(Boolean);

      let found = [];
      for (const q of queries) {
        try {
          const p = await pexelsSearch(q);
          found = extractImageUrls(p);
          if (found.length) break;
        } catch (e) {
          console.warn(`Pexels search failed for "${q}":`, e.message);
        } finally {
          // be gentle with rate limits
          await sleep(350);
        }
      }

      const merged = [...new Set([...existing, ...found])].slice(0, Math.max(MIN_IMAGES, 6));

      if (merged.length === 0) {
        console.warn(`No images found for hotel "${name}" (${h._id})`);
        continue;
      }

      await hotels.updateOne({ _id: h._id }, { $set: { images: merged } });
      updated += 1;
      console.log(
        `Updated ${name || h.slug || h._id}: images ${existing.length} -> ${merged.length}`,
      );
    }

    console.log(`Done. Scanned=${scanned}, Updated=${updated}`);
  } finally {
    await client.close();
  }
}

main().catch((e) => {
  console.error(e);
  process.exitCode = 1;
});

