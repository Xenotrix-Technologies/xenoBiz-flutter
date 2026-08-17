const { db } = require('../src/db/database');
const fs = require('fs');
const path = require('path');

console.log('🔄 Resetting XenoBiz Shop & Subscription Database...');

try {
  db.pragma('foreign_keys = OFF');
  db.exec(`
    DROP TABLE IF EXISTS payments;
    DROP TABLE IF EXISTS subscriptions;
    DROP TABLE IF EXISTS plans;
    DROP TABLE IF EXISTS shops;
    -- Drop legacy tables if present
    DROP TABLE IF EXISTS purchase_returns;
    DROP TABLE IF EXISTS sales_returns;
    DROP TABLE IF EXISTS invoice_items;
    DROP TABLE IF EXISTS invoices;
    DROP TABLE IF EXISTS purchase_items;
    DROP TABLE IF EXISTS purchases;
    DROP TABLE IF EXISTS stock_movements;
    DROP TABLE IF EXISTS products;
    DROP TABLE IF EXISTS crm_leads;
    DROP TABLE IF EXISTS crm_stages;
    DROP TABLE IF EXISTS crm_pipelines;
    DROP TABLE IF EXISTS customer_interactions;
    DROP TABLE IF EXISTS customers;
    DROP TABLE IF EXISTS suppliers;
    DROP TABLE IF EXISTS user_businesses;
    DROP TABLE IF EXISTS businesses;
    DROP TABLE IF EXISTS users;
  `);
  db.pragma('foreign_keys = ON');

  console.log('✅ Legacy tables dropped successfully!');

  // Re-create schema from schema.sql
  const schemaPath = path.join(__dirname, '../src/db/schema.sql');
  const schemaSql = fs.readFileSync(schemaPath, 'utf8');
  db.exec(schemaSql);
  console.log('✅ Fresh Shop & Subscription schema created!');
} catch (err) {
  console.error('❌ Database reset failed:', err);
  process.exit(1);
}
