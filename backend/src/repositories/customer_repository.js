const { db } = require('../db/database');

class CustomerRepository {
  findById(id, businessId) {
    if (businessId) {
      return db.prepare('SELECT * FROM customers WHERE id = ? AND business_id = ?').get(id, businessId);
    }
    return db.prepare('SELECT * FROM customers WHERE id = ?').get(id);
  }

  findAll(businessId, { search, customerType, status, limit = 50, offset = 0 } = {}) {
    let sql = 'SELECT * FROM customers WHERE business_id = ?';
    const params = [businessId];

    if (search) {
      sql += ' AND (LOWER(name) LIKE LOWER(?) OR LOWER(email) LIKE LOWER(?) OR phone LIKE ? OR LOWER(company) LIKE LOWER(?))';
      const term = `%${search}%`;
      params.push(term, term, term, term);
    }

    if (customerType) {
      sql += ' AND customer_type = ?';
      params.push(customerType);
    }

    if (status) {
      sql += ' AND status = ?';
      params.push(status);
    }

    sql += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    return db.prepare(sql).all(...params);
  }

  count(businessId) {
    const res = db.prepare('SELECT COUNT(*) as count FROM customers WHERE business_id = ?').get(businessId);
    return res ? res.count : 0;
  }

  create(customer) {
    const now = new Date().toISOString();
    const stmt = db.prepare(`
      INSERT INTO customers (
        id, business_id, name, phone, email, address, company, customer_type, notes,
        total_purchases, total_paid, outstanding_balance, credit_limit, status, created_at, updated_at, created_by
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    stmt.run(
      customer.id,
      customer.businessId || customer.business_id,
      customer.name,
      customer.phone || null,
      customer.email || null,
      customer.address || null,
      customer.company || null,
      customer.customerType || customer.customer_type || 'Regular',
      customer.notes || null,
      customer.totalPurchases || customer.total_purchases || 0,
      customer.totalPaid || customer.total_paid || 0,
      customer.outstandingBalance || customer.outstanding_balance || 0,
      customer.creditLimit || customer.credit_limit || 0,
      customer.status || 'active',
      customer.createdAt || now,
      customer.updatedAt || now,
      customer.createdBy || customer.created_by || null
    );

    return this.findById(customer.id, customer.businessId || customer.business_id);
  }

  update(id, businessId, updates) {
    const fields = [];
    const values = [];
    const now = new Date().toISOString();

    const map = {
      name: 'name = ?',
      phone: 'phone = ?',
      email: 'email = ?',
      address: 'address = ?',
      company: 'company = ?',
      customerType: 'customer_type = ?',
      customer_type: 'customer_type = ?',
      notes: 'notes = ?',
      totalPurchases: 'total_purchases = ?',
      total_purchases: 'total_purchases = ?',
      totalPaid: 'total_paid = ?',
      total_paid: 'total_paid = ?',
      outstandingBalance: 'outstanding_balance = ?',
      outstanding_balance: 'outstanding_balance = ?',
      creditLimit: 'credit_limit = ?',
      credit_limit: 'credit_limit = ?',
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

    db.prepare(`UPDATE customers SET ${fields.join(', ')} WHERE id = ? AND business_id = ?`).run(...values);
    return this.findById(id, businessId);
  }

  updateBalances(id, businessId, deltaPurchases = 0, deltaPaid = 0) {
    db.prepare(`
      UPDATE customers
      SET total_purchases = total_purchases + ?,
          total_paid = total_paid + ?,
          outstanding_balance = total_purchases + ? - (total_paid + ?),
          updated_at = ?
      WHERE id = ? AND business_id = ?
    `).run(deltaPurchases, deltaPaid, deltaPurchases, deltaPaid, new Date().toISOString(), id, businessId);

    return this.findById(id, businessId);
  }

  delete(id, businessId) {
    return db.prepare('DELETE FROM customers WHERE id = ? AND business_id = ?').run(id, businessId);
  }

  // Customer Interactions / Notes
  addInteraction(interaction) {
    const now = new Date().toISOString();
    db.prepare(`
      INSERT INTO customer_interactions (id, business_id, customer_id, type, notes, user_id, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `).run(
      interaction.id,
      interaction.businessId || interaction.business_id,
      interaction.customerId || interaction.customer_id,
      interaction.type || 'Note',
      interaction.notes,
      interaction.userId || interaction.user_id || null,
      interaction.createdAt || now
    );
    return db.prepare('SELECT * FROM customer_interactions WHERE id = ?').get(interaction.id);
  }

  getInteractions(customerId, businessId) {
    return db.prepare('SELECT * FROM customer_interactions WHERE customer_id = ? AND business_id = ? ORDER BY created_at DESC').all(customerId, businessId);
  }
}

module.exports = new CustomerRepository();
