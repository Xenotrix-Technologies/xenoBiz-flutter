const { initDb } = require('../src/db/database');

console.log('Running database migrations...');
try {
  initDb();
  console.log('✅ Database migration completed successfully!');
} catch (error) {
  console.error('❌ Database migration failed:', error);
  process.exit(1);
}
