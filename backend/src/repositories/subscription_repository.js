const { db } = require('../db/database');

class SubscriptionRepository {
  findById(id) {
    const stmt = db.prepare('SELECT * FROM subscriptions WHERE id = ?');
    return stmt.get(id) || null;
  }

  findByShopId(shopId) {
    const stmt = db.prepare('SELECT * FROM subscriptions WHERE shop_id = ? ORDER BY created_at DESC LIMIT 1');
    return stmt.get(shopId) || null;
  }

  findAllByShopId(shopId) {
    const stmt = db.prepare('SELECT * FROM subscriptions WHERE shop_id = ? ORDER BY created_at DESC');
    return stmt.all(shopId);
  }

  create(data) {
    const stmt = db.prepare(`
      INSERT INTO subscriptions (
        id, shop_id, plan_id, plan_name, status, start_date, end_date, renewal_date,
        billing_cycle, amount, currency, auto_renew, provider, provider_subscription_id,
        created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    `);

    stmt.run(
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
      data.autoRenew !== undefined ? (data.autoRenew ? 1 : 0) : 1,
      data.provider || 'razorpay',
      data.providerSubscriptionId || null
    );

    return this.findById(data.id);
  }

  update(id, data) {
    const fields = [];
    const values = [];

    if (data.planId !== undefined) { fields.push('plan_id = ?'); values.push(data.planId); }
    if (data.planName !== undefined) { fields.push('plan_name = ?'); values.push(data.planName); }
    if (data.status !== undefined) { fields.push('status = ?'); values.push(data.status); }
    if (data.startDate !== undefined) { fields.push('start_date = ?'); values.push(data.startDate); }
    if (data.endDate !== undefined) { fields.push('end_date = ?'); values.push(data.endDate); }
    if (data.renewalDate !== undefined) { fields.push('renewal_date = ?'); values.push(data.renewalDate); }
    if (data.billingCycle !== undefined) { fields.push('billing_cycle = ?'); values.push(data.billingCycle); }
    if (data.amount !== undefined) { fields.push('amount = ?'); values.push(data.amount); }
    if (data.currency !== undefined) { fields.push('currency = ?'); values.push(data.currency); }
    if (data.autoRenew !== undefined) { fields.push('auto_renew = ?'); values.push(data.autoRenew ? 1 : 0); }
    if (data.provider !== undefined) { fields.push('provider = ?'); values.push(data.provider); }
    if (data.providerSubscriptionId !== undefined) { fields.push('provider_subscription_id = ?'); values.push(data.providerSubscriptionId); }

    if (fields.length === 0) return this.findById(id);

    fields.push('updated_at = CURRENT_TIMESTAMP');
    values.push(id);

    const query = `UPDATE subscriptions SET ${fields.join(', ')} WHERE id = ?`;
    db.prepare(query).run(...values);

    return this.findById(id);
  }

  countByStatus() {
    const stmt = db.prepare('SELECT status, COUNT(*) as count FROM subscriptions GROUP BY status');
    return stmt.all();
  }
}

module.exports = new SubscriptionRepository();
