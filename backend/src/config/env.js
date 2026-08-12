const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

module.exports = {
  PORT: process.env.PORT || 3000,
  NODE_ENV: process.env.NODE_ENV || 'development',
  JWT_SECRET: process.env.JWT_SECRET || 'xenobiz_dev_jwt_secret_key_2026_super_secure',
  DB_PATH: process.env.DB_PATH || path.join(__dirname, '../../data/xenobiz.db'),
};
