/**
 * Verifies paths vs github.com/Nada-Khaled21/Sufar (seedMaster.js)
 * Run: node scripts/verify_media_paths.js
 */
const API = 'https://sufar-rho.vercel.app/api';

function classify(url) {
  if (!url) return 'empty';
  if (url.includes('/sufar/hotels/') && url.includes('/general/')) return 'hotel-general';
  if (url.includes('/sufar/hotels/') && url.includes('/rooms/')) return 'hotel-rooms';
  if (url.includes('/sufar/hotels/')) return 'hotel';
  if (url.includes('/sufar/destinations/')) return 'destination';
  if (url.includes('pexels.com')) return 'pexels';
  if (url.startsWith('http')) return 'other';
  return 'relative';
}

async function main() {
  console.log('\n=== Sufar API (Vercel) ===\n');

  const listRes = await fetch(`${API}/destinations?limit=50`);
  const listBody = await listRes.json();
  const list = listBody.destinations || listBody;
  const cityStats = {};
  for (const d of list) cityStats[classify(d.image)] = (cityStats[classify(d.image)] || 0) + 1;
  console.log('GET /api/destinations:', cityStats);

  const cairoRes = await fetch(`${API}/destinations/cairo`);
  const cairoBody = await cairoRes.json();
  const dest = cairoBody.destination;
  console.log('\nGET /api/destinations/cairo');
  console.log('  destination.image:', classify(dest?.image));
  console.log('  topHotels:', (cairoBody.topHotels || []).length);

  const hotelsRes = await fetch(`${API}/hotels?city=Cairo&limit=5`);
  const hotelsBody = await hotelsRes.json();
  let g = 0;
  let r = 0;
  for (const h of hotelsBody.hotels || []) {
    for (const img of h.images || []) {
      if (img.includes('/general/')) g++;
      if (img.includes('/rooms/')) r++;
    }
  }
  console.log('\nGET /api/hotels?city=Cairo');
  console.log('  general images:', g, '| rooms in list:', r, '(rooms usually on GET /api/hotels/:slug)');

  const slug = hotelsBody.hotels?.[0]?.slug;
  if (slug) {
    const detail = await (await fetch(`${API}/hotels/${slug}`)).json();
    const rooms = detail.rooms || [];
    const roomImgs = rooms.flatMap((rm) => rm.images || []);
    console.log(`\nGET /api/hotels/${slug}`);
    console.log('  rooms:', rooms.length, '| room images:', roomImgs.length);
    if (roomImgs[0]) console.log('  sample:', classify(roomImgs[0]));
  }

  console.log('\n=== Expected (GitHub Images/ + seedMaster) ===');
  console.log('  Local:  Images/destinations/{slug}/');
  console.log('  Local:  Images/{citySlug}/{hotel}/general|rooms/');
  console.log('  CDN:    sufar/destinations/*');
  console.log('  CDN:    sufar/hotels/{slug}/general|rooms/');
  console.log('  Activities: Pexels only (Flutter activity_images.json)\n');
}

main().catch((e) => console.error(e.message));
