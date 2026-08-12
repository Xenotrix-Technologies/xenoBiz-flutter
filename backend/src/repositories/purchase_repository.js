const { db } = require('../db/database');

class PurchaseRepository {
  findById(id, businessId) {
    const purchase = db.prepare(`
      SELECT p.*, s.name as supplier_name, s.company as supplier_company
      FROM purchases p
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      WHERE p.id = ? AND p.business_id = ?
    `).get(id, businessId);

    if (!purchase) return null;

    const items = db.prepare('SELECT * FROM purchase_items WHERE purchase_id = ?').all(id);
    purchase.items = items;
    return purchase;
  }

  findAll(businessId, { supplierId, paymentStatus, startDate, endDate, limit = 100, offset = 0 } = {}) {
    let sql = `
      SELECT p.*, s.name as supplier_name, s.company as supplier_company
      FROM purchases p
      LEFT JOIN suppliers s ON p.supplier_id = s.id
      WHERE p.business_id = ?
    `;
    const params = [businessId];

    if (supplierId) {
      sql += ' AND p.supplier_id = ?';
      params.push(supplierId);
    }
    if (paymentStatus) {
      sql += ' AND p.payment_status = ?';
      params.push(paymentStatus);
    }
    if (startDate) {
      sql += ' AND p.purchase_date >= ?';
      params.push(startDate);
    }
    if (endDate) {
      sql += ' AND p.purchase_date <= ?';
      params.push(endDate);
    }

    sql += ' ORDER BY p.purchase_date DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    return db.prepare(sql).all(...params);
  }

  create(purchase, items = []) {
    const now = new Date().toISOString();
    const insertPurchase = db.prepare(`
      INSERT INTO purchases (
        id, business_id, supplier_id, invoice_number, purchase_date, subtotal, discount,
        tax_amount, other_charges, grand_total, paid_amount, due_amount, payment_status,
        payment_method, status, notes, created_at, updated_at, created_by
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    const insertItem = db.prepare(`
      INSERT INTO purchase_items (id, purchase_id, product_id, product_name, quantity, purchase_price, tax, discount, total)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    const tx = db.transaction(() => {
      insertPurchase.run(
        purchase.id,
        purchase.businessId || purchase.business_id,
        purchase.supplierId || purchase.supplier_id || null,
        purchase.invoiceNumber || purchase.invoice_number || null,
        purchase.purchaseDate || purchase.purchase_date || now,
        purchase.subtotal || 0.0,
        purchase.discount || 0.0,
        purchase.taxAmount || purchase.tax_amount || 0.0,
        purchase.otherCharges || purchase.other_charges || 0.0,
        purchase.grandTotal || purchase.grand_total || 0.0,
        purchase.paidAmount || purchase.paid_amount || 0.0,
        purchase.dueAmount || purchase.due_amount || 0.0,
        purchase.paymentStatus || purchase.payment_status || 'unpaid',
        purchase.paymentMethod || purchase.payment_method || 'Cash',
        purchase.status || 'active',
        purchase.notes || null,
        purchase.createdAt || now,
        purchase.updatedAt || now,
        purchase.createdBy || purchase.created_by || null
      );

      for (const item of items) {
        insertItem.run(
          item.id,
          purchase.id,
          item.productId || item.product_id || null,
          item.productName || item.product_name,
          item.quantity,
          item.purchasePrice || item.purchase_price,
          item.tax || 0.0,
          item.discount || 0.0,
          item.total
        );
      }
    });

    tx();
    return this.findById(purchase.id, purchase.businessId || purchase.business_id);
  }

  updatePayment(id, businessId, addPaidAmount) {
    const p = this.findById(id, businessId);
    if (!p) return null;

    const newPaid = p.paid_amount + addPaidAmount;
    const newDue = Math.max(0, p.grand_total - newPaid);
    let newStatus = 'unpaid';
    if (newDue <= 0) {
      newStatus = 'paid';
    } else if (newPaid > 0) {
      newStatus = 'partially_paid';
    }

    db.prepare(`
      UPDATE purchases
      SET paid_amount = ?, due_amount = ?, payment_status = ?, updated_at = ?
      WHERE id = ? AND business_id = ?
    `).run(newPaid, newDue, newStatus, new Date().toISOString(), id, businessId);

    return this.findById(id, businessId);
  }
}

module.exports = new PurchaseRepository();
