const { pool } = require('../db/database');

class SubscriptionRepository {
  async findById(id) {
    const res = await pool.query('SELECT * FROM subscriptions WHERE id = $1', [id]);
    return res.rows[0] || null;
  }

  async findByShopId(shopId) {
    const res = await pool.query('SELECT * FROM subscriptions WHERE shop_id = $1 ORDER BY created_at DESC LIMIT 1', [shopId]);
    return res.rows[0] || null;
  }

  async findAllByShopId(shopId) {
    const res = await pool.query('SELECT * FROM subscriptions WHERE shop_id = $1 ORDER BY created_at DESC', [shopId]);
    return res.rows;
  }

  async create(data) {
    const query = `
      INSERT INTO subscriptions (
        id, shop_id, plan_id, plan_name, status, start_date, end_date, renewal_date,
        billing_cycle, amount, currency, auto_renew, provider, provider_subscription_id,
        created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING *
    `;

    const values = [
      data.id,
      data.shopId,
      data.planId,
      data.planName,
      data.status || 'active',
      data.startDate,
      data.endDate,
      data.renewalDate || data.endDate,
      data.billingCycle || 'monthly',
      data.amount || 0.0,
      data.currency || 'INR',
      data.autoRenew !== undefined ? (data.autoRenew ? true : false) : true,
      data.provider || 'razorpay',
      data.providerSubscriptionId || null,
    ];

    const res = await pool.query(query, values);
    return res.rows[0];
  }

  async update(id, data) {
    const fields = [];
    const values = [];
    let idx = 1;

    if (data.planId !== undefined) { fields.push(`plan_id = $${idx++}`); values.push(data.planId); }
    if (data.planName !== undefined) { fields.push(`plan_name = $${idx++}`); values.push(data.planName); }
    if (data.status !== undefined) { fields.push(`status = $${idx++}`); values.push(data.status); }
    if (data.startDate !== undefined) { fields.push(`start_date = $${idx++}`); values.push(data.startDate); }
    if (data.endDate !== undefined) { fields.push(`end_date = $${idx++}`); values.push(data.endDate); }
    if (data.renewalDate !== undefined) { fields.push(`renewal_date = $${idx++}`); values.push(data.renewalDate); }
    if (data.billingCycle !== undefined) { fields.push(`billing_cycle = $${idx++}`); values.push(data.billingCycle); }
    if (data.amount !== undefined) { fields.push(`amount = $${idx++}`); values.push(data.amount); }
    if (data.currency !== undefined) { fields.push(`currency = $${idx++}`); values.push(data.currency); }
    if (data.autoRenew !== undefined) { fields.push(`auto_renew = $${idx++}`); values.push(data.autoRenew ? true : false); }
    if (data.provider !== undefined) { fields.push(`provider = $${idx++}`); values.push(data.provider); }
    if (data.providerSubscriptionId !== undefined) { fields.push(`provider_subscription_id = $${idx++}`); values.push(data.providerSubscriptionId); }

    if (fields.length === 0) return this.findById(id);

    fields.push('updated_at = CURRENT_TIMESTAMP');
    values.push(id);

    const query = `UPDATE subscriptions SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`;
    const res = await pool.query(query, values);
    return res.rows[0] || null;
  }

  async countByStatus() {
    const res = await pool.query('SELECT status, COUNT(*)::INTEGER as count FROM subscriptions GROUP BY status');
    return res.rows;
  }
}

module.exports = new SubscriptionRepository();
