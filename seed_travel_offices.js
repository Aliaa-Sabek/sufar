const { MongoClient } = require('mongodb');

const MONGO_URI = process.env.MONGO_URI;
const DB_NAME = process.env.MONGO_DB || 'sufar';
const COLLECTION = 'travel_offices';

const travelOffices = [
  {
    name: 'EgyptAir Travel',
    description: 'Official travel agency for EgyptAir, providing flight bookings, vacation packages, and corporate travel solutions.',
    rating: 4.5,
    reviews_count: 320,
    images: ['https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/EgyptAir_logo.svg/1200px-EgyptAir_logo.svg.png'],
    city: 'Cairo',
    country: 'Egypt',
    services: ['Flight', 'Hotel', 'Visa', 'Transport'],
    contact: {
      phone: '+20 2 12345678',
      email: 'info@egyptair.com',
      website: 'https://www.egyptair.com'
    },
    featured: true
  },
  {
    name: 'Emirates Holidays',
    description: 'Book your complete holiday with Emirates Holidays. Enjoy world-class flights and luxury hotel stays.',
    rating: 4.8,
    reviews_count: 850,
    images: ['https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Emirates_logo.svg/1024px-Emirates_logo.svg.png'],
    city: 'Dubai',
    country: 'UAE',
    services: ['Flight', 'Luxury', 'Hotel'],
    contact: {
      phone: '+971 4 1234567',
      email: 'holidays@emirates.com',
      website: 'https://www.emiratesholidays.com'
    },
    featured: true
  },
  {
    name: 'Qatar Airways Holidays',
    description: 'Discover the world with Qatar Airways Holidays. Unforgettable vacation packages and flight deals.',
    rating: 4.9,
    reviews_count: 1200,
    images: ['https://upload.wikimedia.org/wikipedia/en/thumb/9/9b/Qatar_Airways_Logo.svg/1200px-Qatar_Airways_Logo.svg.png'],
    city: 'Doha',
    country: 'Qatar',
    services: ['Flight', 'Tours', 'Hotel'],
    contact: {
      phone: '+974 4022 2222',
      email: 'holidays@qatarairways.com',
      website: 'https://www.qatarairways.com'
    },
    featured: true
  },
  {
    name: 'Travco Travel',
    description: 'Leading travel agency in the Middle East offering comprehensive travel services including flights and tours.',
    rating: 4.6,
    reviews_count: 450,
    images: ['https://www.travcogroup.com/img/logo.png'],
    city: 'Cairo',
    country: 'Egypt',
    services: ['Flight', 'Hotel', 'Tours', 'Cruises'],
    contact: {
      phone: '+20 2 24567890',
      email: 'info@travco.com',
      website: 'https://www.travco.com'
    },
    featured: false
  },
  {
    name: 'Kanoo Travel',
    description: 'The largest travel management company in the Middle East, offering premium flight booking services.',
    rating: 4.4,
    reviews_count: 310,
    images: ['https://www.kanootravel.com/images/logo.png'],
    city: 'Dubai',
    country: 'UAE',
    services: ['Flight', 'Corporate', 'Hotel'],
    contact: {
      phone: '+971 4 3456789',
      email: 'info@kanootravel.com',
      website: 'https://www.kanootravel.com'
    },
    featured: false
  }
];

async function main() {
  if (!MONGO_URI) {
    console.error('Missing MONGO_URI env var. Please run with $env:MONGO_URI=\"...\" ; node seed_travel_offices.js');
    process.exitCode = 1;
    return;
  }

  const client = new MongoClient(MONGO_URI);
  try {
    await client.connect();
    console.log('Connected to MongoDB');
    const db = client.db(DB_NAME);
    const collection = db.collection(COLLECTION);
    
    // Clear existing to avoid duplicates if re-run
    await collection.deleteMany({});
    console.log('Cleared existing travel offices');
    
    const result = await collection.insertMany(travelOffices);
    console.log(Successfully inserted  travel offices!);
  } catch(e) {
    console.error('Error seeding data:', e);
  } finally {
    await client.close();
  }
}

main();
