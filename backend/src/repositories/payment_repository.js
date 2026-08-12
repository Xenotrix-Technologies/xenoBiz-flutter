const { db } = require('../db/database');

class PaymentRepository {
  findById(id, businessId) {
    return db.prepare('SELECT * FROM payments WHERE id = ? AND business_id = ?').get(id, businessId);
  }

  findAll(businessId, { invoiceId, purchaseId, customerId, supplierId, paymentType, limit = 100, offset = 0 } = {}) {
    let sql = 'SELECT * FROM payments WHERE business_id = ?';
    const params = [businessId];

    if (invoiceId) {
      sql += ' AND invoice_id = ?';
      params.push(invoiceId);
    }
    if (purchaseId) {
      sql += ' AND purchase_id = ?';
      params.push(purchaseId);
    }
    if (customerId) {
      sql += ' AND customer_id = ?';
      params.push(customerId);
    }
    if (supplierId) {
      sql += ' AND supplier_id = ?';
      params.push(supplierId);
    }
    if (paymentType) {
      sql += ' AND payment_type = ?';
      params.push(paymentType);
    }

    sql += ' ORDER BY payment_date DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    return db.prepare(sql).all(...params);
  }

  create(payment) {
    const now = new Date().toISOString();
    db.prepare(`
      INSERT INTO payments (
        id, business_id, invoice_id, purchase_id, customer_id, supplier_id, amount,
        payment_method, payment_type, payment_status, transaction_reference,
        payment_date, notes, created_at, created_by
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      payment.id,
      payment.businessId || payment.business_id,
      payment.invoiceId || payment.invoice_id || null,
      payment.purchaseId || payment.purchase_id || null,
      payment.customerId || payment.customer_id || null,
      payment.supplierId || payment.supplier_id || null,
      payment.amount,
      payment.paymentMethod || payment.payment_method || 'Cash',
      payment.paymentType || payment.payment_type || 'IN',
      payment.paymentStatus || payment.payment_status || 'completed',
      payment.transactionReference || payment.transaction_reference || null,
      payment.paymentDate || payment.payment_date || now,
      payment.notes || null,
      payment.createdAt || now,
      payment.createdBy || payment.created_by || null
    );

    return this.findById(payment.id, payment.businessId || payment.business_id);
  }
}

module.exports = new PaymentRepository();
