/**
 * Fills destinations_data.json + activity_images.json with Cloudinary URLs
 * from the live hotels API (same CDN as hotel images in the app).
 *
 * Run: node scripts/build_cloudinary_catalog.js
 */
const fs = require('fs');
const path = require('path');

const API = 'https://sufar-rho.vercel.app/api/hotels';
const DEST_FILE = path.join(__dirname, '..', 'assets', 'destinations_data.json');
const IMAGES_FILE = path.join(__dirname, '..', 'assets', 'activity_images.json');

const NAME_ALIASES = {
  'Al Madinah': 'Madinah',
  'New York': 'New York',
  'Los Angeles': 'Los Angeles',
  'Abu Dhabi': 'Abu Dhabi',
  'Sharm El Sheikh': 'Sharm El Sheikh',
};

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function uniqueCloudinary(list) {
  const out = [];
  const seen = new Set();
  for (const u of list) {
    if (!u || !u.includes('res.cloudinary.com')) continue;
    if (seen.has(u)) continue;
    seen.add(u);
    out.push(u);
  }
  return out;
}

async function fetchHotelImages(cityName) {
  const q = NAME_ALIASES[cityName] || cityName;
  const url = `${API}?city=${encodeURIComponent(q)}&limit=8`;
  try {
    const res = await fetch(url);
    if (!res.ok) return [];
    const data = await res.json();
    const hotels = Array.isArray(data.hotels) ? data.hotels : [];
    return uniqueCloudinary(hotels.flatMap((h) => h.images || []));
  } catch (e) {
    console.warn(`Hotels API failed for ${cityName}:`, e.message);
    return [];
  }
}

async function main() {
  const destinations = JSON.parse(fs.readFileSync(DEST_FILE, 'utf8'));
  const activityCatalog = {};
  let fallbackPool = [];

  for (const dest of destinations) {
    const name = dest.name;
    const slug = dest.slug || name.toLowerCase().replace(/\s+/g, '-');
    dest.slug = slug;

    let images = await fetchHotelImages(name);
    if (images.length === 0 && fallbackPool.length) images = [...fallbackPool];
    if (images.length) fallbackPool = images;

    if (!images.length) {
      console.warn(`⚠️  No Cloudinary images for ${name}`);
      continue;
    }

    dest.image = images[0];

    const acts = Array.isArray(dest.activities) ? dest.activities : [];
    acts.forEach((act, i) => {
      act.image = images[i % images.length];
      activityCatalog[`${slug}|${act.title}`] = act.image;
    });

    console.log(`✓ ${name}: ${images.length} Cloudinary images`);
    await sleep(200);
  }

  fs.writeFileSync(DEST_FILE, JSON.stringify(destinations, null, 2));
  fs.writeFileSync(IMAGES_FILE, JSON.stringify(activityCatalog, null, 2));
  console.log(`\nWrote ${DEST_FILE}`);
  console.log(`Wrote ${IMAGES_FILE} (${Object.keys(activityCatalog).length} activities)`);
}

main().catch((e) => {
  console.error(e);
  process.exitCode = 1;
});
