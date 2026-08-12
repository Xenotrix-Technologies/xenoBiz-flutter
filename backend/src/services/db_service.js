const fs = require('fs');
const path = require('path');

const DB_FILE = path.join(__dirname, '../../data/db.json');

// Initial seed data with hashed password for default user
const initialData = {
  users: [
    {
      id: 'usr_owner',
      name: 'Business Owner',
      email: 'owner@xenobiz.com',
      phone: '+919847011223',
      // Hashed password for 'password123'
      passwordHash: '$2a$10$w8T0hR.tQ4SjPZz4eD0EHevK3wU6z7Xp8/n1a1y8y9k0c1d2e3f4g',
      role: 'OWNER',
      createdAt: new Date().toISOString(),
    },
  ],
  businesses: [
    {
      id: 'biz_101',
      userId: 'usr_owner',
      name: 'Apex Technologies Pvt Ltd',
      phone: '+91 98470 11223',
      email: 'finance@apextech.in',
      address: 'Kalamassery, Kochi, Kerala',
      gstin: '32ABCDE1234F1Z5',
      category: 'Retail Store',
      createdAt: new Date().toISOString(),
    },
  ],
};

function ensureDbExists() {
  const dir = path.dirname(DB_FILE);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  if (!fs.existsSync(DB_FILE)) {
    fs.writeFileSync(DB_FILE, JSON.stringify(initialData, null, 2));
  }
}

function readDb() {
  ensureDbExists();
  try {
    const raw = fs.readFileSync(DB_FILE, 'utf8');
    return JSON.parse(raw);
  } catch (err) {
    return initialData;
  }
}

function writeDb(data) {
  ensureDbExists();
  fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2));
}

module.exports = {
  readDb,
  writeDb,
};
