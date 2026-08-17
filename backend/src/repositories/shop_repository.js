const { db } = require('../db/database');

class ShopRepository {
  findById(id) {
    const stmt = db.prepare('SELECT * FROM shops WHERE id = ?');
    return stmt.get(id) || null;
  }

  findByEmail(email) {
    if (!email) return null;
    const stmt = db.prepare('SELECT * FROM shops WHERE LOWER(email) = LOWER(?)');
    return stmt.get(email) || null;
  }

  findByLoginId(loginId) {
    if (!loginId) return null;
    const stmt = db.prepare('SELECT * FROM shops WHERE LOWER(login_id) = LOWER(?) OR LOWER(username) = LOWER(?)');
    return stmt.get(loginId, loginId) || null;
  }

  findByPhone(phone) {
    if (!phone) return null;
    const stmt = db.prepare('SELECT * FROM shops WHERE phone = ?');
    return stmt.get(phone) || null;
  }

  findByEmailOrLoginId(identifier) {
    if (!identifier) return null;
    const clean = identifier.trim().toLowerCase();
    const stmt = db.prepare(
      'SELECT * FROM shops WHERE LOWER(email) = ? OR LOWER(login_id) = ? OR phone = ?'
    );
    return stmt.get(clean, clean, clean) || null;
  }

  create(data) {
    const stmt = db.prepare(`
      INSERT INTO shops (
        id, shop_name, owner_name, email, phone, address, city, state, country,
        postal_code, gst_number, business_type, login_id, password_hash,
        status, is_verified, role, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    `);

    stmt.run(
      data.id,
      data.shopName || data.name || 'New Shop',
      data.ownerName || data.fullName || 'Shop Owner',
      data.email,
      data.phone || null,
      data.address || null,
      data.city || null,
      data.state || null,
      data.country || 'India',
      data.postalCode || data.zipCode || null,
      data.gstNumber || data.taxNumber || null,
      data.businessType || null,
      data.loginId || data.username || data.email.split('@')[0],
      data.passwordHash,
      data.status || 'active',
      data.isVerified !== undefined ? (data.isVerified ? 1 : 0) : 1,
      data.role || 'OWNER'
    );

    return this.findById(data.id);
  }

  update(id, data) {
    const fields = [];
    const values = [];

    const mapField = (dbCol, jsVal) => {
      if (jsVal !== undefined) {
        fields.push(`${dbCol} = ?`);
        values.push(jsVal);
      }
    };

    mapField('shop_name', data.shopName || data.name);
    mapField('owner_name', data.ownerName || data.fullName);
    mapField('email', data.email);
    mapField('phone', data.phone);
    mapField('address', data.address);
    mapField('city', data.city);
    mapField('state', data.state);
    mapField('country', data.country);
    mapField('postal_code', data.postalCode || data.zipCode);
    mapField('gst_number', data.gstNumber || data.taxNumber);
    mapField('business_type', data.businessType);
    mapField('login_id', data.loginId || data.username);
    mapField('status', data.status);
    mapField('is_verified', data.isVerified !== undefined ? (data.isVerified ? 1 : 0) : undefined);
    mapField('last_login_at', data.lastLoginAt || data.lastLogin);

    if (data.passwordHash) {
      mapField('password_hash', data.passwordHash);
    }

    if (fields.length === 0) return this.findById(id);

    fields.push('updated_at = CURRENT_TIMESTAMP');
    values.push(id);

    const query = `UPDATE shops SET ${fields.join(', ')} WHERE id = ?`;
    db.prepare(query).run(...values);

    return this.findById(id);
  }

  findAll({ status, query } = {}) {
    let sql = 'SELECT * FROM shops';
    const params = [];
    const conditions = [];

    if (status) {
      conditions.push('status = ?');
      params.push(status);
    }

    if (query) {
      conditions.push('(LOWER(shop_name) LIKE ? OR LOWER(owner_name) LIKE ? OR LOWER(email) LIKE ?)');
      const q = `%${query.toLowerCase()}%`;
      params.push(q, q, q);
    }

    if (conditions.length > 0) {
      sql += ' WHERE ' + conditions.join(' AND ');
    }

    sql += ' ORDER BY created_at DESC';
    return db.prepare(sql).all(...params);
  }

  count() {
    const stmt = db.prepare('SELECT COUNT(*) as total FROM shops');
    return stmt.get().total;
  }
}

module.exports = new ShopRepository();
