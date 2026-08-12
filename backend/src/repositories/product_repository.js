const { db } = require('../db/database');

class ProductRepository {
  findById(id, businessId) {
    if (businessId) {
      return db.prepare('SELECT * FROM products WHERE id = ? AND business_id = ?').get(id, businessId);
    }
    return db.prepare('SELECT * FROM products WHERE id = ?').get(id);
  }

  findByBarcodeOrSku(identifier, businessId) {
    return db.prepare(`
      SELECT * FROM products
      WHERE business_id = ? AND (barcode = ? OR sku = ?)
    `).get(businessId, identifier, identifier);
  }

  findAll(businessId, { search, category, status, lowStockOnly, limit = 100, offset = 0 } = {}) {
    let sql = 'SELECT * FROM products WHERE business_id = ?';
    const params = [businessId];

    if (search) {
      sql += ' AND (LOWER(name) LIKE LOWER(?) OR LOWER(sku) LIKE LOWER(?) OR barcode LIKE ? OR LOWER(category) LIKE LOWER(?))';
      const term = `%${search}%`;
      params.push(term, term, term, term);
    }

    if (category) {
      sql += ' AND category = ?';
      params.push(category);
    }

    if (status) {
      sql += ' AND status = ?';
      params.push(status);
    }

    if (lowStockOnly) {
      sql += ' AND current_stock <= min_stock_level';
    }

    sql += ' ORDER BY name ASC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    return db.prepare(sql).all(...params);
  }

  count(businessId) {
    const res = db.prepare('SELECT COUNT(*) as count FROM products WHERE business_id = ?').get(businessId);
    return res ? res.count : 0;
  }

  countLowStock(businessId) {
    const res = db.prepare('SELECT COUNT(*) as count FROM products WHERE business_id = ? AND current_stock <= min_stock_level').get(businessId);
    return res ? res.count : 0;
  }

  create(product) {
    const now = new Date().toISOString();
    db.prepare(`
      INSERT INTO products (
        id, business_id, name, sku, barcode, description, category, brand, unit,
        purchase_price, selling_price, tax_percentage, min_stock_level, current_stock,
        image_url, status, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      product.id,
      product.businessId || product.business_id,
      product.name,
      product.sku || null,
      product.barcode || null,
      product.description || null,
      product.category || 'General',
      product.brand || null,
      product.unit || 'pcs',
      product.purchasePrice || product.purchase_price || 0.0,
      product.sellingPrice || product.selling_price || 0.0,
      product.taxPercentage || product.tax_percentage || 0.0,
      product.minStockLevel || product.min_stock_level || 5,
      product.currentStock || product.current_stock || 0,
      product.imageUrl || product.image_url || null,
      product.status || 'active',
      product.createdAt || now,
      product.updatedAt || now
    );

    return this.findById(product.id, product.businessId || product.business_id);
  }

  update(id, businessId, updates) {
    const fields = [];
    const values = [];
    const now = new Date().toISOString();

    const map = {
      name: 'name = ?',
      sku: 'sku = ?',
      barcode: 'barcode = ?',
      description: 'description = ?',
      category: 'category = ?',
      brand: 'brand = ?',
      unit: 'unit = ?',
      purchasePrice: 'purchase_price = ?',
      purchase_price: 'purchase_price = ?',
      sellingPrice: 'selling_price = ?',
      selling_price: 'selling_price = ?',
      taxPercentage: 'tax_percentage = ?',
      tax_percentage: 'tax_percentage = ?',
      minStockLevel: 'min_stock_level = ?',
      min_stock_level: 'min_stock_level = ?',
      currentStock: 'current_stock = ?',
      current_stock: 'current_stock = ?',
      imageUrl: 'image_url = ?',
      image_url: 'image_url = ?',
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

    db.prepare(`UPDATE products SET ${fields.join(', ')} WHERE id = ? AND business_id = ?`).run(...values);
    return this.findById(id, businessId);
  }

  updateStock(id, businessId, quantityDelta) {
    db.prepare(`
      UPDATE products
      SET current_stock = current_stock + ?,
          updated_at = ?
      WHERE id = ? AND business_id = ?
    `).run(quantityDelta, new Date().toISOString(), id, businessId);

    return this.findById(id, businessId);
  }

  delete(id, businessId) {
    // Soft delete or hard delete
    return db.prepare('UPDATE products SET status = "inactive", updated_at = ? WHERE id = ? AND business_id = ?').run(new Date().toISOString(), id, businessId);
  }
}

module.exports = new ProductRepository();
