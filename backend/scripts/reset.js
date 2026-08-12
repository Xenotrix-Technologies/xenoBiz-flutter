const fs = require('fs');
const path = require('path');
const env = require('../src/config/env');

console.log('Resetting development database...');
if (fs.existsSync(env.DB_PATH)) {
  try {
    fs.unlinkSync(env.DB_PATH);
    console.log(`Deleted existing database file: ${env.DB_PATH}`);
  } catch (err) {
    console.error(`Error deleting database file: ${err.message}`);
  }
}

const { initDb } = require('../src/db/database');
initDb();
console.log('✅ Database reset and re-initialized successfully!');
