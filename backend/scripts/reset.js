const { pool, initDb } = require('../src/db/database');

console.log('🔄 Resetting XenoBiz PostgreSQL Database...');

async function reset() {
  try {
    await pool.query(`
      DROP TABLE IF EXISTS payments CASCADE;
      DROP TABLE IF EXISTS subscriptions CASCADE;
      DROP TABLE IF EXISTS plans CASCADE;
      DROP TABLE IF EXISTS shops CASCADE;
    `);

    console.log('✅ PostgreSQL tables dropped successfully!');

    // Re-create schema from schema.sql
    await initDb();
    console.log('✅ Fresh PostgreSQL schema created!');
  } catch (err) {
    console.error('❌ PostgreSQL database reset failed:', err);
    process.exit(1);
  }
}

reset();
