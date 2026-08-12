const Database = require('better-sqlite3');
const fs = require('fs');
const path = require('path');
const env = require('../config/env');

// Ensure database directory exists
const dbDir = path.dirname(env.DB_PATH);
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
}

// Initialize SQLite database instance
const db = new Database(env.DB_PATH, { verbose: env.NODE_ENV === 'development' ? null : null });
db.pragma('foreign_keys = ON');

function initDb() {
  const schemaPath = path.join(__dirname, 'schema.sql');
  const schemaSql = fs.readFileSync(schemaPath, 'utf8');
  db.exec(schemaSql);
}

module.exports = {
  db,
  initDb,
};
