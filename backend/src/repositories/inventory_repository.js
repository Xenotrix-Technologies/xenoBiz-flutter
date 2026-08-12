const { db } = require('../db/database');

class InventoryRepository {
  recordMovement(movement) {
    const now = new Date().toISOString();
    db.prepare(`
      INSERT INTO stock_movements (id, business_id, product_id, quantity, movement_type, reference_document, reason, user_id, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      movement.id,
      movement.businessId || movement.business_id,
      movement.productId || movement.product_id,
      movement.quantity,
      movement.movementType || movement.movement_type,
      movement.referenceDocument || movement.reference_document || null,
      movement.reason || null,
      movement.userId || movement.user_id || null,
      movement.createdAt || now
    );

    return db.prepare('SELECT * FROM stock_movements WHERE id = ?').get(movement.id);
  }

  getMovementsByBusiness(businessId, { productId, movementType, limit = 100, offset = 0 } = {}) {
    let sql = `
      SELECT sm.*, p.name as product_name, p.sku
      FROM stock_movements sm
      JOIN products p ON sm.product_id = p.id
      WHERE sm.business_id = ?
    `;
    const params = [businessId];

    if (productId) {
      sql += ' AND sm.product_id = ?';
      params.push(productId);
    }
    if (movementType) {
      sql += ' AND sm.movement_type = ?';
      params.push(movementType);
    }

    sql += ' ORDER BY sm.created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    return db.prepare(sql).all(...params);
  }

  getMovementsByProduct(productId, businessId) {
    return db.prepare(`
      SELECT * FROM stock_movements
      WHERE product_id = ? AND business_id = ?
      ORDER BY created_at DESC
    `).all(productId, businessId);
  }
}

module.exports = new InventoryRepository();
