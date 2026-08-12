const { db } = require('../db/database');

class ReturnRepository {
  createSalesReturn(ret) {
    const now = new Date().toISOString();
    db.prepare(`
      INSERT INTO sales_returns (
        id, business_id, invoice_id, customer_id, product_id, quantity, refund_amount, reason, return_date, created_at, created_by
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      ret.id,
      ret.businessId || ret.business_id,
      ret.invoiceId || ret.invoice_id || null,
      ret.customerId || ret.customer_id || null,
      ret.productId || ret.product_id,
      ret.quantity,
      ret.refundAmount || ret.refund_amount,
      ret.reason || null,
      ret.returnDate || ret.return_date || now,
      ret.createdAt || now,
      ret.createdBy || ret.created_by || null
    );

    return db.prepare('SELECT * FROM sales_returns WHERE id = ?').get(ret.id);
  }

  getSalesReturns(businessId) {
    return db.prepare('SELECT * FROM sales_returns WHERE business_id = ? ORDER BY return_date DESC').all(businessId);
  }

  createPurchaseReturn(ret) {
    const now = new Date().toISOString();
    db.prepare(`
      INSERT INTO purchase_returns (
        id, business_id, purchase_id, supplier_id, product_id, quantity, return_amount, reason, return_date, created_at, created_by
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      ret.id,
      ret.businessId || ret.business_id,
      ret.purchaseId || ret.purchase_id || null,
      ret.supplierId || ret.supplier_id || null,
      ret.productId || ret.product_id,
      ret.quantity,
      ret.returnAmount || ret.return_amount,
      ret.reason || null,
      ret.returnDate || ret.return_date || now,
      ret.createdAt || now,
      ret.createdBy || ret.created_by || null
    );

    return db.prepare('SELECT * FROM purchase_returns WHERE id = ?').get(ret.id);
  }

  getPurchaseReturns(businessId) {
    return db.prepare('SELECT * FROM purchase_returns WHERE business_id = ? ORDER BY return_date DESC').all(businessId);
  }
}

module.exports = new ReturnRepository();
