/**
 * Restores activities (title, description, image keys) from backend catalog
 * and assigns semantic Cloudinary URLs from city hotels API.
 *
 * Run: node scripts/sync_activities_from_backend.js
 */
const fs = require('fs');
const path = require('path');

const API = 'https://sufar-rho.vercel.app/api/hotels';
const BACKEND_SRC = path.join(__dirname, 'destination_backend_original.json');
const DEST_FILE = path.join(__dirname, '..', 'assets', 'destinations_data.json');
const IMAGES_FILE = path.join(__dirname, '..', 'assets', 'activity_images.json');
const PYTHON_DEST = path.join(__dirname, '..', 'python_backend', 'destination.json');

const CITY_API = {
  'Al Madinah': 'Madinah',
  'Sharm El Sheikh': 'Sharm El Sheikh',
};

/** Cities with no hotels in API — borrow images from a nearby catalog city */
const FALLBACK_HOTEL_CITY = {
  riyadh: 'Jeddah',
  beirut: 'Amman',
};

/** slug|imageFilename -> hotel slug keywords (first match wins) */
const HOTEL_HINTS = {
  cairo: {
    'pyramids.jpg': ['pyramisa', 'giza', 'mena'],
    'gem.jpg': ['museum', 'tahrir', 'cairo'],
    'khan.jpg': ['downtown', 'khan', 'tahrir'],
    'nile.jpg': ['nile', 'grand-nile', 'hilton-grand'],
    'cairo.jpg': ['pyramisa', 'nile', 'grand-nile'],
  },
  alexandria: {
    'library.jpg': ['metropole', 'cecil', 'windsor'],
    'citadel.jpg': ['metropole', 'cecil'],
    'corniche.jpg': ['metropole', 'windsor', 'cecil'],
    'roman.jpg': ['metropole', 'windsor'],
    'alex.jpg': ['metropole', 'cecil'],
  },
  hurghada: {
    'motion.jpg': ['oberoi', 'aldau', 'beach', 'steigenberger'],
    'motion2.jpg': ['aldau', 'beach'],
    'diving.jpg': ['oberoi', 'beach', 'aldau'],
    'yacht.jpg': ['beach', 'aldau', 'oberoi'],
    'safari.jpg': ['beach', 'oberoi'],
    'water.jpg': ['beach', 'aldau'],
    'hurghada.jpg': ['oberoi', 'aldau'],
  },
  'sharm-el-sheikh': {
    'ras.jpg': ['white-hills', 'coral', 'reef', 'sharm'],
    'coral.jpg': ['coral', 'reef', 'white-hills'],
    'sinai.jpg': ['sinai', 'desert', 'sharm'],
    'dolphin.jpg': ['beach', 'reef', 'white-hills'],
    'sharm.jpg': ['white-hills', 'sharm'],
  },
  luxor: {
    'karnak.jpg': ['sofitel', 'winter', 'luxor'],
    'kings.jpg': ['winter', 'luxor', 'sofitel'],
    'balloon.jpg': ['winter', 'luxor'],
    'luxor-temple.jpg': ['luxor', 'sofitel'],
    'luxor.jpg': ['winter', 'luxor'],
  },
  aswan: {
    'abu.jpg': ['movenpick', 'cataract', 'aswan'],
    'philae.jpg': ['cataract', 'movenpick'],
    'felucca.jpg': ['movenpick', 'nile', 'cataract'],
    'nubian.jpg': ['movenpick', 'aswan'],
    'aswan.jpg': ['cataract', 'movenpick'],
  },
  riyadh: {
    'masmak.jpg': ['masmak', 'riyadh', 'fort'],
    'tower.jpg': ['kingdom', 'tower', 'faisal'],
    'diriyah.jpg': ['diriyah', 'heritage'],
    'season.jpg': ['riyadh', 'season', 'boulevard'],
    'riyadh.jpg': ['kingdom', 'riyadh'],
  },
  jeddah: {
    'corniche.jpg': ['corniche', 'jeddah', 'red-sea'],
    'balad.jpg': ['balad', 'historic', 'jeddah'],
    'fountain.jpg': ['fountain', 'jeddah', 'corniche'],
    'diving.jpg': ['beach', 'red-sea', 'diving'],
    'jeddah.jpg': ['jeddah', 'corniche'],
  },
  makkah: {
    'haram.jpg': ['haram', 'makkah', 'clock'],
    'kaaba.jpg': ['haram', 'kaaba', 'makkah'],
    'noor.jpg': ['noor', 'mountain', 'makkah'],
    'thawr.jpg': ['thawr', 'mountain'],
    'Makkah.jpg': ['haram', 'makkah'],
  },
  'al-madinah': {
    'nabawi.jpg': ['nabawi', 'madinah', 'prophet'],
    'uhud.jpg': ['uhud', 'madinah'],
    'museum.jpg': ['museum', 'madinah'],
    'garden.jpg': ['garden', 'nabawi', 'madinah'],
    'Al Madinah.jpg': ['nabawi', 'madinah'],
  },
  dubai: {
    'burj.jpg': ['burj', 'khalifa', 'downtown'],
    'mall.jpg': ['mall', 'dubai', 'downtown'],
    'desert.jpg': ['desert', 'safari', 'dubai'],
    'beach.jpg': ['beach', 'jumeirah', 'palm'],
    'dubai.jpg': ['burj', 'downtown'],
  },
  'abu-dhabi': {
    'mosque.jpg': ['mosque', 'zayed', 'sheikh'],
    'louvre.jpg': ['louvre', 'saadiyat'],
    'yas.jpg': ['yas', 'ferrari'],
    'corniche.jpg': ['corniche', 'abu'],
    'abudhabi.jpg': ['mosque', 'zayed'],
  },
  doha: {
    'museum.jpg': ['museum', 'islamic', 'mia'],
    'souq.jpg': ['souq', 'waqif'],
    'lusail.jpg': ['lusail', 'marina'],
    'katara.jpg': ['katara', 'cultural'],
    'doha.jpg': ['museum', 'doha'],
  },
  amman: {
    'theatre.jpg': ['theatre', 'roman', 'amman'],
    'citadel.jpg': ['citadel', 'amman'],
    'museum.jpg': ['museum', 'amman'],
    'food.jpg': ['downtown', 'amman'],
    'amman.jpg': ['citadel', 'amman'],
  },
  beirut: {
    'downtown.jpg': ['downtown', 'beirut'],
    'corniche.jpg': ['corniche', 'beirut'],
    'gemmayzeh.jpg': ['gemmayzeh', 'beirut'],
    'museum.jpg': ['museum', 'beirut'],
    'beirut.jpg': ['beirut', 'downtown'],
  },
  paris: {
    'eiffel.jpg': ['eiffel', 'tour', 'pullman'],
    'louvre.jpg': ['louvre', 'paris'],
    'seine.jpg': ['seine', 'paris', 'crillon'],
    'montmartre.jpg': ['montmartre', 'paris'],
    'paris.jpg': ['eiffel', 'plaza'],
  },
  rome: {
    'colosseum.jpg': ['colosseum', 'rome'],
    'vatican.jpg': ['vatican', 'rome'],
    'trevi.jpg': ['trevi', 'rome'],
    'forum.jpg': ['forum', 'rome', 'colosseum'],
    'rome.jpg': ['colosseum', 'rome'],
  },
  barcelona: {
    'sagrada.jpg': ['sagrada', 'barcelona'],
    'park.jpg': ['park', 'guell', 'barcelona'],
    'ramblas.jpg': ['ramblas', 'barcelona'],
    'beach.jpg': ['beach', 'barcelona'],
    'barcelona.jpg': ['sagrada', 'barcelona'],
  },
  london: {
    'eye.jpg': ['eye', 'london', 'thames'],
    'bridge.jpg': ['bridge', 'tower', 'london'],
    'museum.jpg': ['museum', 'british', 'london'],
    'park.jpg': ['hyde', 'park', 'london'],
    'london.jpg': ['london', 'thames'],
  },
  'new-york': {
    'liberty.jpg': ['liberty', 'new-york', 'nyc'],
    'park.jpg': ['central', 'park', 'new-york'],
    'times.jpg': ['times', 'square', 'new-york'],
    'bridge.jpg': ['brooklyn', 'bridge'],
    'nyc.jpg': ['new-york', 'manhattan'],
  },
  'los-angeles': {
    'hollywood.jpg': ['hollywood', 'angeles'],
    'beach.jpg': ['santa', 'monica', 'beach'],
    'studio.jpg': ['universal', 'studio'],
    'beverly.jpg': ['beverly', 'hills'],
    'la.jpg': ['hollywood', 'angeles'],
  },
  istanbul: {
    'hagia.jpg': ['hagia', 'sophia', 'sultanahmet'],
    'mosque.jpg': ['mosque', 'blue', 'sultanahmet'],
    'bazaar.jpg': ['bazaar', 'grand', 'istanbul'],
    'bosphorus.jpg': ['bosphorus', 'istanbul'],
    'istanbul.jpg': ['sultanahmet', 'hagia'],
  },
  tokyo: {
    'shibuya.jpg': ['shibuya', 'tokyo'],
    'tower.jpg': ['tower', 'tokyo'],
    'akihabara.jpg': ['akihabara', 'tokyo'],
    'temple.jpg': ['temple', 'senso', 'tokyo'],
    'tokyo.jpg': ['tokyo', 'shibuya'],
  },
  maldives: {
    'diving.jpg': ['diving', 'reef', 'maldives'],
    'villa.jpg': ['villa', 'overwater', 'maldives'],
    'dolphin.jpg': ['dolphin', 'maldives'],
    'sunset.jpg': ['sunset', 'maldives'],
    'maldives.jpg': ['villa', 'maldives'],
  },
};

function toSlug(name) {
  return String(name)
    .toLowerCase()
    .replace(/&/g, 'and')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

function uniqueUrls(list) {
  const out = [];
  const seen = new Set();
  for (const u of list) {
    if (u && u.includes('cloudinary.com') && !seen.has(u)) {
      seen.add(u);
      out.push(u);
    }
  }
  return out;
}

async function fetchHotels(cityName) {
  const q = CITY_API[cityName] || cityName;
  const res = await fetch(`${API}?city=${encodeURIComponent(q)}&limit=12`);
  if (!res.ok) return [];
  const data = await res.json();
  return (data.hotels || []).map((h) => ({
    slug: h.slug || '',
    images: uniqueUrls(h.images || []),
  }));
}

function pickHotelImage(hotels, keywords, usedUrls, fallbackIndex) {
  for (const kw of keywords) {
    const hotel = hotels.find((h) => h.slug.includes(kw));
    if (!hotel || !hotel.images.length) continue;
    for (const url of hotel.images) {
      if (!usedUrls.has(url)) {
        usedUrls.add(url);
        return url;
      }
    }
  }
  const pool = uniqueUrls(hotels.flatMap((h) => h.images));
  if (!pool.length) return '';
  const url = pool[fallbackIndex % pool.length];
  usedUrls.add(url);
  return url;
}

async function main() {
  const backend = JSON.parse(
    fs.readFileSync(BACKEND_SRC, 'utf8').replace(/^\uFEFF/, ''),
  );
  const current = JSON.parse(fs.readFileSync(DEST_FILE, 'utf8'));
  const metaByName = Object.fromEntries(current.map((d) => [d.name, d]));

  const activityCatalog = {};

  for (const dest of backend) {
    const name = dest.name;
    const slug = metaByName[name]?.slug || toSlug(name);
    const meta = metaByName[name] || {};
    dest.slug = slug;
    if (meta.name_ar) dest.name_ar = meta.name_ar;
    if (meta.country) dest.country = meta.country;
    if (meta.country_ar) dest.country_ar = meta.country_ar;
    if (meta.region) dest.region = meta.region;

    let hotels = await fetchHotels(name);
    if (!hotels.length && FALLBACK_HOTEL_CITY[slug]) {
      hotels = await fetchHotels(FALLBACK_HOTEL_CITY[slug]);
    }
    const hints = HOTEL_HINTS[slug] || {};
    const used = new Set();
    let i = 0;

    const acts = dest.activities || [];
    for (const act of acts) {
      const file = (act.image || '').toString();
      const keys = hints[file] || [file.replace('.jpg', ''), slug];
      const url = pickHotelImage(hotels, keys, used, i++);
      act.image = url;
      activityCatalog[`${slug}|${act.title}`] = url;
    }

    const heroFile = (dest.image || '').toString();
    const heroKeys = hints[heroFile] || [slug];
    dest.image =
      pickHotelImage(hotels, heroKeys, used, 0) ||
      (acts[0]?.image || '');

    console.log(`✓ ${name} (${acts.length} activities, ${hotels.length} hotels)`);
    await sleep(180);
  }

  fs.writeFileSync(DEST_FILE, JSON.stringify(backend, null, 2));
  fs.writeFileSync(IMAGES_FILE, JSON.stringify(activityCatalog, null, 2));
  fs.writeFileSync(PYTHON_DEST, JSON.stringify(backend, null, 2));
  console.log('\nSynced assets + python_backend/destination.json');
}

main().catch((e) => {
  console.error(e);
  process.exitCode = 1;
});
