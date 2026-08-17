const { db } = require('../db/database');

class PlanRepository {
  findById(id) {
    const stmt = db.prepare('SELECT * FROM plans WHERE id = ?');
    return stmt.get(id) || null;
  }

  findByName(name) {
    const stmt = db.prepare('SELECT * FROM plans WHERE LOWER(name) = LOWER(?)');
    return stmt.get(name) || null;
  }

  findAll({ isActiveOnly = true } = {}) {
    let sql = 'SELECT * FROM plans';
    if (isActiveOnly) {
      sql += ' WHERE is_active = 1';
    }
    sql += ' ORDER BY price ASC';
    return db.prepare(sql).all();
  }

  create(data) {
    const stmt = db.prepare(`
      INSERT INTO plans (
        id, name, description, price, currency, billing_cycle, features, is_active,
        created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    `);

    stmt.run(
      data.id,
      data.name,
      data.description || '',
      data.price || 0.0,
      data.currency || 'INR',
      data.billingCycle || 'monthly',
      typeof data.features === 'object' ? JSON.stringify(data.features) : (data.features || '[]'),
      data.isActive !== undefined ? (data.isActive ? 1 : 0) : 1
    );

    return this.findById(data.id);
  }

  update(id, data) {
    const fields = [];
    const values = [];

    if (data.name !== undefined) { fields.push('name = ?'); values.push(data.name); }
    if (data.description !== undefined) { fields.push('description = ?'); values.push(data.description); }
    if (data.price !== undefined) { fields.push('price = ?'); values.push(data.price); }
    if (data.currency !== undefined) { fields.push('currency = ?'); values.push(data.currency); }
    if (data.billingCycle !== undefined) { fields.push('billing_cycle = ?'); values.push(data.billingCycle); }
    if (data.features !== undefined) {
      fields.push('features = ?');
      values.push(typeof data.features === 'object' ? JSON.stringify(data.features) : data.features);
    }
    if (data.isActive !== undefined) { fields.push('is_active = ?'); values.push(data.isActive ? 1 : 0); }

    if (fields.length === 0) return this.findById(id);

    fields.push('updated_at = CURRENT_TIMESTAMP');
    values.push(id);

    const query = `UPDATE plans SET ${fields.join(', ')} WHERE id = ?`;
    db.prepare(query).run(...values);

    return this.findById(id);
  }
}

module.exports = new PlanRepository();
