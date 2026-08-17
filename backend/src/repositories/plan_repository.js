const { pool } = require('../db/database');

class PlanRepository {
  async findById(id) {
    const res = await pool.query('SELECT * FROM plans WHERE id = $1', [id]);
    return res.rows[0] || null;
  }

  async findByName(name) {
    const res = await pool.query('SELECT * FROM plans WHERE LOWER(name) = LOWER($1)', [name]);
    return res.rows[0] || null;
  }

  async findAll({ isActiveOnly = true } = {}) {
    let sql = 'SELECT * FROM plans';
    if (isActiveOnly) {
      sql += ' WHERE is_active = TRUE';
    }
    sql += ' ORDER BY price ASC';
    const res = await pool.query(sql);
    return res.rows;
  }

  async create(data) {
    const query = `
      INSERT INTO plans (
        id, name, description, price, currency, billing_cycle, features, is_active,
        created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING *
    `;

    let featuresVal = data.features;
    if (typeof featuresVal === 'object') {
      featuresVal = JSON.stringify(featuresVal);
    } else if (!featuresVal) {
      featuresVal = '[]';
    }

    const values = [
      data.id,
      data.name,
      data.description || '',
      data.price || 0.0,
      data.currency || 'INR',
      data.billingCycle || 'monthly',
      featuresVal,
      data.isActive !== undefined ? (data.isActive ? true : false) : true,
    ];

    const res = await pool.query(query, values);
    return res.rows[0];
  }

  async update(id, data) {
    const fields = [];
    const values = [];
    let idx = 1;

    if (data.name !== undefined) { fields.push(`name = $${idx++}`); values.push(data.name); }
    if (data.description !== undefined) { fields.push(`description = $${idx++}`); values.push(data.description); }
    if (data.price !== undefined) { fields.push(`price = $${idx++}`); values.push(data.price); }
    if (data.currency !== undefined) { fields.push(`currency = $${idx++}`); values.push(data.currency); }
    if (data.billingCycle !== undefined) { fields.push(`billing_cycle = $${idx++}`); values.push(data.billingCycle); }
    if (data.features !== undefined) {
      fields.push(`features = $${idx++}`);
      values.push(typeof data.features === 'object' ? JSON.stringify(data.features) : data.features);
    }
    if (data.isActive !== undefined) { fields.push(`is_active = $${idx++}`); values.push(data.isActive ? true : false); }

    if (fields.length === 0) return this.findById(id);

    fields.push('updated_at = CURRENT_TIMESTAMP');
    values.push(id);

    const query = `UPDATE plans SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`;
    const res = await pool.query(query, values);
    return res.rows[0] || null;
  }
}

module.exports = new PlanRepository();
