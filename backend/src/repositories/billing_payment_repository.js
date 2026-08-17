const { db } = require('../db/database');

class BillingPaymentRepository {
  findById(id) {
    const stmt = db.prepare('SELECT * FROM payments WHERE id = ?');
    return stmt.get(id) || null;
  }

  findByShopId(shopId) {
    const stmt = db.prepare('SELECT * FROM payments WHERE shop_id = ? ORDER BY paid_at DESC');
    return stmt.all(shopId);
  }

  findLatestByShopId(shopId) {
    const stmt = db.prepare("SELECT * FROM payments WHERE shop_id = ? AND status = 'successful' ORDER BY paid_at DESC LIMIT 1");
    return stmt.get(shopId) || null;
  }

  findAll({ limit = 50, offset = 0 } = {}) {
    const stmt = db.prepare('SELECT * FROM payments ORDER BY paid_at DESC LIMIT ? OFFSET ?');
    return stmt.all(limit, offset);
  }

  create(data) {
    const stmt = db.prepare(`
      INSERT INTO payments (
        id, shop_id, subscription_id, plan_id, amount, currency, payment_method,
        provider, transaction_id, provider_payment_id, status, paid_at,
        failure_reason, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    `);

    const paidAt = data.paidAt || new Date().toISOString();

    stmt.run(
      data.id,
      data.shopId,
      data.subscriptionId || null,
      data.planId || null,
      data.amount || 0.0,
      data.currency || 'INR',
      data.paymentMethod || 'UPI',
      data.provider || 'razorpay',
      data.transactionId || null,
      data.providerPaymentId || null,
      data.status || 'successful',
      paidAt,
      data.failureReason || null
    );

    return this.findById(data.id);
  }

  getRevenueSummary() {
    const totalStmt = db.prepare("SELECT SUM(amount) as totalRevenue, COUNT(*) as totalPayments FROM payments WHERE status = 'successful'");
    const statusBreakdownStmt = db.prepare('SELECT status, COUNT(*) as count, SUM(amount) as sumAmount FROM payments GROUP BY status');

    return {
      revenue: totalStmt.get() || { totalRevenue: 0, totalPayments: 0 },
      breakdown: statusBreakdownStmt.all(),
    };
  }
}

module.exports = new BillingPaymentRepository();
