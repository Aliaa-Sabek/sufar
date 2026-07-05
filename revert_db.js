const fs = require('fs');
const { MongoClient } = require('mongodb');

const MONGO_URI = process.env.MONGO_URI || 'mongodb+srv://AliaaSabek:Aliaa_123456789@sufar.o5m3b.mongodb.net/sufar?retryWrites=true&w=majority&appName=Sufar';
const DB_NAME = 'sufar';
const COLLECTION = 'destinations';

async function updateDB() {
  const orig = JSON.parse(fs.readFileSync('assets/destinations_data.json', 'utf8'));
  const client = new MongoClient(MONGO_URI);
  await client.connect();
  const col = client.db(DB_NAME).collection(COLLECTION);
  let updated = 0;
  for (const dest of orig) {
    const slug = dest.slug || dest.name.toLowerCase().replace(/&/g, 'and').replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
    const res = await col.updateOne(
      { $or: [{ slug }, { name: dest.name }] },
      { $set: { image: dest.image, activities: dest.activities, slug } }
    );
    if (res.matchedCount) updated++;
  }
  console.log('Updated ' + updated + ' destinations in MongoDB');
  await client.close();
}
updateDB().catch(console.error);
