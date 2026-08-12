const { db } = require('../db/database');

class BusinessRepository {
  findById(id) {
    return db.prepare('SELECT * FROM businesses WHERE id = ?').get(id);
  }

  findByUserId(userId) {
    return db.prepare(`
      SELECT b.* FROM businesses b
      JOIN user_businesses ub ON b.id = ub.business_id
      WHERE ub.user_id = ?
      ORDER BY b.created_at ASC
    `).all(userId);
  }

  findPrimaryByUserId(userId) {
    return db.prepare(`
      SELECT b.* FROM businesses b
      JOIN user_businesses ub ON b.id = ub.business_id
      WHERE ub.user_id = ?
      ORDER BY b.created_at ASC
      LIMIT 1
    `).get(userId);
  }

  create(business, userId, role = 'OWNER') {
    const now = new Date().toISOString();
    const insertBiz = db.prepare(`
      INSERT INTO businesses (
        id, name, business_type, description, logo, address, city, state, country,
        zip_code, phone, email, website, tax_number, currency, invoice_prefix, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    const insertJunction = db.prepare(`
      INSERT INTO user_businesses (user_id, business_id, role, created_at)
      VALUES (?, ?, ?, ?)
    `);

    const transaction = db.transaction(() => {
      insertBiz.run(
        business.id,
        business.name,
        business.businessType || business.business_type || null,
        business.description || null,
        business.logo || null,
        business.address || null,
        business.city || null,
        business.state || null,
        business.country || 'India',
        business.zipCode || business.zip_code || null,
        business.phone || null,
        business.email || null,
        business.website || null,
        business.taxNumber || business.tax_number || null,
        business.currency || 'INR',
        business.invoicePrefix || business.invoice_prefix || 'INV-',
        business.createdAt || now,
        business.updatedAt || now
      );

      insertJunction.run(userId, business.id, role, now);
    });

    transaction();
    return this.findById(business.id);
  }

  update(id, updates) {
    const fields = [];
    const values = [];
    const now = new Date().toISOString();

    const fieldMap = {
      name: 'name = ?',
      businessType: 'business_type = ?',
      business_type: 'business_type = ?',
      description: 'description = ?',
      logo: 'logo = ?',
      address: 'address = ?',
      city: 'city = ?',
      state: 'state = ?',
      country: 'country = ?',
      zipCode: 'zip_code = ?',
      zip_code: 'zip_code = ?',
      phone: 'phone = ?',
      email: 'email = ?',
      website: 'website = ?',
      taxNumber: 'tax_number = ?',
      tax_number: 'tax_number = ?',
      currency: 'currency = ?',
      invoicePrefix: 'invoice_prefix = ?',
      invoice_prefix: 'invoice_prefix = ?'
    };

    Object.keys(updates).forEach((key) => {
      if (fieldMap[key]) {
        fields.push(fieldMap[key]);
        values.push(updates[key]);
      }
    });

    fields.push('updated_at = ?');
    values.push(now);
    values.push(id);

    db.prepare(`UPDATE businesses SET ${fields.join(', ')} WHERE id = ?`).run(...values);
    return this.findById(id);
  }

  findAll() {
    return db.prepare('SELECT * FROM businesses ORDER BY created_at DESC').all();
  }

  userBelongsToBusiness(userId, businessId) {
    const record = db.prepare('SELECT 1 FROM user_businesses WHERE user_id = ? AND business_id = ?').get(userId, businessId);
    return !!record;
  }
}

module.exports = new BusinessRepository();
