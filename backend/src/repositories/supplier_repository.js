const { db } = require('../db/database');

class SupplierRepository {
  findById(id, businessId) {
    if (businessId) {
      return db.prepare('SELECT * FROM suppliers WHERE id = ? AND business_id = ?').get(id, businessId);
    }
    return db.prepare('SELECT * FROM suppliers WHERE id = ?').get(id);
  }

  findAll(businessId, { search, limit = 100, offset = 0 } = {}) {
    let sql = 'SELECT * FROM suppliers WHERE business_id = ?';
    const params = [businessId];

    if (search) {
      sql += ' AND (LOWER(name) LIKE LOWER(?) OR LOWER(company) LIKE LOWER(?) OR phone LIKE ?)';
      const term = `%${search}%`;
      params.push(term, term, term);
    }

    sql += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    return db.prepare(sql).all(...params);
  }

  count(businessId) {
    const res = db.prepare('SELECT COUNT(*) as count FROM suppliers WHERE business_id = ?').get(businessId);
    return res ? res.count : 0;
  }

  create(supplier) {
    const now = new Date().toISOString();
    db.prepare(`
      INSERT INTO suppliers (
        id, business_id, name, company, phone, email, address, tax_number, notes,
        outstanding_payable, status, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      supplier.id,
      supplier.businessId || supplier.business_id,
      supplier.name,
      supplier.company || null,
      supplier.phone || null,
      supplier.email || null,
      supplier.address || null,
      supplier.taxNumber || supplier.tax_number || null,
      supplier.notes || null,
      supplier.outstandingPayable || supplier.outstanding_payable || 0.0,
      supplier.status || 'active',
      supplier.createdAt || now,
      supplier.updatedAt || now
    );

    return this.findById(supplier.id, supplier.businessId || supplier.business_id);
  }

  update(id, businessId, updates) {
    const fields = [];
    const values = [];
    const now = new Date().toISOString();

    const map = {
      name: 'name = ?',
      company: 'company = ?',
      phone: 'phone = ?',
      email: 'email = ?',
      address: 'address = ?',
      taxNumber: 'tax_number = ?',
      tax_number: 'tax_number = ?',
      notes: 'notes = ?',
      outstandingPayable: 'outstanding_payable = ?',
      outstanding_payable: 'outstanding_payable = ?',
      status: 'status = ?'
    };

    Object.keys(updates).forEach((k) => {
      if (map[k]) {
        fields.push(map[k]);
        values.push(updates[k]);
      }
    });

    fields.push('updated_at = ?');
    values.push(now);
    values.push(id, businessId);

    db.prepare(`UPDATE suppliers SET ${fields.join(', ')} WHERE id = ? AND business_id = ?`).run(...values);
    return this.findById(id, businessId);
  }

  updatePayable(id, businessId, deltaAmount) {
    db.prepare(`
      UPDATE suppliers
      SET outstanding_payable = outstanding_payable + ?,
          updated_at = ?
      WHERE id = ? AND business_id = ?
    `).run(deltaAmount, new Date().toISOString(), id, businessId);

    return this.findById(id, businessId);
  }

  delete(id, businessId) {
    return db.prepare('DELETE FROM suppliers WHERE id = ? AND business_id = ?').run(id, businessId);
  }
}

module.exports = new SupplierRepository();
