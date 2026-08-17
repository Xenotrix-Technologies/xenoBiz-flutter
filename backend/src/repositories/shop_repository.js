const { pool } = require('../db/database');

class ShopRepository {
  async findById(id) {
    const res = await pool.query('SELECT * FROM shops WHERE id = $1', [id]);
    return res.rows[0] || null;
  }

  async findByEmail(email) {
    if (!email) return null;
    const res = await pool.query('SELECT * FROM shops WHERE LOWER(email) = LOWER($1)', [email]);
    return res.rows[0] || null;
  }

  async findByLoginId(loginId) {
    if (!loginId) return null;
    const res = await pool.query(
      'SELECT * FROM shops WHERE LOWER(login_id) = LOWER($1)',
      [loginId]
    );
    return res.rows[0] || null;
  }

  async findByPhone(phone) {
    if (!phone) return null;
    const res = await pool.query('SELECT * FROM shops WHERE phone = $1', [phone]);
    return res.rows[0] || null;
  }

  async findByEmailOrLoginId(identifier) {
    if (!identifier) return null;
    const clean = identifier.trim().toLowerCase();
    const res = await pool.query(
      'SELECT * FROM shops WHERE LOWER(email) = $1 OR LOWER(login_id) = $1 OR phone = $1',
      [clean]
    );
    return res.rows[0] || null;
  }

  async create(data) {
    const query = `
      INSERT INTO shops (
        id, shop_name, owner_name, email, phone, address, city, state, country,
        postal_code, gst_number, business_type, login_id, password_hash,
        status, is_verified, role, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING *
    `;

    const values = [
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
      data.loginId || data.username || (data.email ? data.email.split('@')[0] : (data.phone || data.id)),
      data.passwordHash,
      data.status || 'active',
      data.isVerified !== undefined ? (data.isVerified ? true : false) : true,
      data.role || 'OWNER',
    ];

    const res = await pool.query(query, values);
    return res.rows[0];
  }

  async update(id, data) {
    const fields = [];
    const values = [];
    let idx = 1;

    const mapField = (dbCol, jsVal) => {
      if (jsVal !== undefined) {
        fields.push(`${dbCol} = $${idx++}`);
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
    mapField('is_verified', data.isVerified !== undefined ? (data.isVerified ? true : false) : undefined);
    mapField('last_login_at', data.lastLoginAt || data.lastLogin);

    if (data.passwordHash) {
      mapField('password_hash', data.passwordHash);
    }

    if (fields.length === 0) return this.findById(id);

    fields.push('updated_at = CURRENT_TIMESTAMP');
    values.push(id);

    const query = `UPDATE shops SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`;
    const res = await pool.query(query, values);
    return res.rows[0] || null;
  }

  async findAll({ status, query } = {}) {
    let sql = 'SELECT * FROM shops';
    const params = [];
    const conditions = [];
    let idx = 1;

    if (status) {
      conditions.push(`status = $${idx++}`);
      params.push(status);
    }

    if (query) {
      conditions.push(`(LOWER(shop_name) LIKE $${idx} OR LOWER(owner_name) LIKE $${idx} OR LOWER(email) LIKE $${idx})`);
      params.push(`%${query.toLowerCase()}%`);
      idx++;
    }

    if (conditions.length > 0) {
      sql += ' WHERE ' + conditions.join(' AND ');
    }

    sql += ' ORDER BY created_at DESC';
    const res = await pool.query(sql, params);
    return res.rows;
  }

  async count() {
    const res = await pool.query('SELECT COUNT(*) as total FROM shops');
    return parseInt(res.rows[0].total, 10) || 0;
  }
}

module.exports = new ShopRepository();
