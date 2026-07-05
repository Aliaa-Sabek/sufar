/**
 * Sets MongoDB destination.image to Cloudinary path used by seedMaster.js:
 *   Images/destinations/{slug} → sufar/destinations/{filename}
 *
 * Run on the Sufar backend repo after seed: node scripts/fix_vercel_destination_images.js
 * Requires: MONGO_URI
 */
const fs = require('fs');
const path = require('path');
const { MongoClient } = require('mongodb');

const MONGO_URI = process.env.MONGO_URI;
const DB_NAME = process.env.DB_NAME || 'sufar';
const COLLECTION = 'destinations';
const CLOUD_BASE =
  'https://res.cloudinary.com/dgggctaxn/image/upload';

const DEST_FILE = path.join(__dirname, '..', 'assets', 'destinations_data.json');
const IMAGES_DEST = path.join(__dirname, '..', 'Images', 'destinations');

function toSlug(name) {
  return String(name)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function localDestinationFile(slug) {
  const exts = ['.jpg', '.jpeg', '.png', '.webp'];
  const dir = path.join(IMAGES_DEST, slug);
  if (fs.existsSync(dir)) {
    const files = fs
      .readdirSync(dir)
      .filter((f) => /\.(jpg|jpeg|png|webp)$/i.test(f));
    if (files.length) return files[0];
  }
  for (const ext of exts) {
    const p = path.join(IMAGES_DEST, `${slug}${ext}`);
    if (fs.existsSync(p)) return `${slug}${ext}`;
  }
  return `${slug}.jpg`;
}

function cityImageUrl(slug) {
  const file = localDestinationFile(slug);
  return `${CLOUD_BASE}/sufar/destinations/${file}`;
}

async function main() {
  if (!MONGO_URI) {
    console.error('Set MONGO_URI (same as Vercel env on github.com/Nada-Khaled21/Sufar).');
    process.exit(1);
  }

  const destinations = JSON.parse(fs.readFileSync(DEST_FILE, 'utf8'));
  const client = new MongoClient(MONGO_URI);
  await client.connect();
  const col = client.db(DB_NAME).collection(COLLECTION);

  let updated = 0;
  for (const dest of destinations) {
    const slug = dest.slug || toSlug(dest.name);
    const url = cityImageUrl(slug);
    const res = await col.updateOne(
      { $or: [{ slug }, { name: dest.name }] },
      { $set: { image: url, slug } },
    );
    if (res.matchedCount) {
      updated++;
      console.log('✓', dest.name, '→', url.replace(CLOUD_BASE + '/', ''));
    }
  }

  await client.close();
  console.log(`\nUpdated ${updated} destinations (Cloudinary sufar/destinations/, not Pexels).`);
  console.log('Re-run seedMaster.js on the backend repo if images are still missing.\n');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
