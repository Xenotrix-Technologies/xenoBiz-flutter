const { pool } = require('../db/database');

class BillingPaymentRepository {
  async findById(id) {
    const res = await pool.query('SELECT * FROM payments WHERE id = $1', [id]);
    return res.rows[0] || null;
  }

  async findByShopId(shopId) {
    const res = await pool.query('SELECT * FROM payments WHERE shop_id = $1 ORDER BY paid_at DESC', [shopId]);
    return res.rows;
  }

  async findLatestByShopId(shopId) {
    const res = await pool.query("SELECT * FROM payments WHERE shop_id = $1 AND status = 'successful' ORDER BY paid_at DESC LIMIT 1", [shopId]);
    return res.rows[0] || null;
  }

  async findAll({ limit = 50, offset = 0 } = {}) {
    const res = await pool.query('SELECT * FROM payments ORDER BY paid_at DESC LIMIT $1 OFFSET $2', [limit, offset]);
    return res.rows;
  }

  async create(data) {
    const query = `
      INSERT INTO payments (
        id, shop_id, subscription_id, plan_id, amount, currency, payment_method,
        provider, transaction_id, provider_payment_id, status, paid_at,
        failure_reason, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING *
    `;

    const paidAt = data.paidAt || new Date().toISOString();

    const values = [
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
      data.failureReason || null,
    ];

    const res = await pool.query(query, values);
    return res.rows[0];
  }

  async getRevenueSummary() {
    const totalRes = await pool.query(
      "SELECT COALESCE(SUM(amount), 0)::FLOAT as \"totalRevenue\", COUNT(*)::INTEGER as \"totalPayments\" FROM payments WHERE status = 'successful'"
    );
    const statusBreakdownRes = await pool.query(
      "SELECT status, COUNT(*)::INTEGER as count, COALESCE(SUM(amount), 0)::FLOAT as \"sumAmount\" FROM payments GROUP BY status"
    );

    return {
      revenue: totalRes.rows[0] || { totalRevenue: 0, totalPayments: 0 },
      breakdown: statusBreakdownRes.rows,
    };
  }
}

module.exports = new BillingPaymentRepository();
