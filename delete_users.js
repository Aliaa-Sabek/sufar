const { MongoClient } = require('mongodb');

const uri = 'mongodb+srv://nadak4540_db_user:nadasufar2026@sufar.w06wwj9.mongodb.net/sufar?retryWrites=true&w=majority&appName=Sufar';

async function run() {
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
