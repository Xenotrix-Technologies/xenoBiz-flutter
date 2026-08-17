const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
const env = require('../config/env');

const pool = new Pool({
  connectionString: env.DATABASE_URL,
  ssl: false,
});

pool.on('connect', () => {
  console.log('PostgreSQL database connected');
});

pool.on('error', (error) => {
  console.error('Unexpected PostgreSQL error:', error);
});

async function initDb() {
  try {
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schemaSql = fs.readFileSync(schemaPath, 'utf8');

    await pool.query(schemaSql);

    console.log('PostgreSQL database initialized successfully');
  } catch (error) {
    console.error('PostgreSQL database initialization failed:');
    console.error(error);

    throw error;
  }
}

module.exports = {
  pool,
  initDb,
};