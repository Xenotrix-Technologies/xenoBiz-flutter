require('dotenv').config();

const { pool } = require('./database');

async function testConnection() {
  try {
    const result = await pool.query(`
      SELECT
        current_database() AS database,
        NOW() AS time
    `);

    console.log('PostgreSQL connection successful!');
    console.log(result.rows[0]);
  } catch (error) {
    console.error('PostgreSQL connection failed!');
    console.error(error);
  } finally {
    await pool.end();
  }
}

testConnection();