/**
 * Builds assets/activity_images.json (Pexels URLs) from curated_activity_photos.json.
 * Does NOT change destinations_data.json — city filenames stay for Cloudinary.
 *
 * Run: node scripts/apply_curated_activity_photos.js
 */
const fs = require('fs');
const path = require('path');

const CATALOG = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'curated_activity_photos.json'), 'utf8'),
);
const IMAGES_FILE = path.join(__dirname, '..', 'assets', 'activity_images.json');

function pexels(id) {
  return `https://images.pexels.com/photos/${id}/pexels-photo-${id}.jpeg?auto=compress&cs=tinysrgb&w=800`;
}

function toUrl(value) {
  if (typeof value === 'string' && value.startsWith('https://')) return value;
  if (typeof value === 'number') return pexels(value);
  const n = Number.parseInt(String(value), 10);
  if (!Number.isNaN(n)) return pexels(n);
  throw new Error(`Invalid catalog entry: ${value}`);
}

const urlCatalog = {};
for (const [key, value] of Object.entries(CATALOG)) {
  urlCatalog[key] = toUrl(value);
}

fs.writeFileSync(IMAGES_FILE, JSON.stringify(urlCatalog, null, 2));
console.log(`Wrote ${Object.keys(urlCatalog).length} Pexels activity URLs → ${IMAGES_FILE}`);
