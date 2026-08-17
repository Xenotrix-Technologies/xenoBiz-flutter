require('dotenv').config();

const { initDb, pool } = require('./database');

async function initialize() {
  try {
    await initDb();

    console.log('Database initialization completed.');
  } catch (error) {
    console.error(error);
  } finally {
    await pool.end();
  }
}

initialize();
