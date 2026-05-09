const { MongoClient } = require('mongodb');

const uri = process.env.MONGO_URI;

async function run() {
  if (!uri) {
    console.error('Missing MONGO_URI env var');
    process.exitCode = 1;
    return;
  }
  const client = new MongoClient(uri);

  try {
    await client.connect();
    console.log('Connected to MongoDB');
    
    const db = client.db('sufar');
    const usersCollection = db.collection('users');
    
    const result = await usersCollection.deleteMany({});
    console.log(`Successfully deleted ${result.deletedCount} users.`);
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await client.close();
  }
}

run();
