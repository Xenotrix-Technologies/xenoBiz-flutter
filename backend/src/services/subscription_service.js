const { v4: uuidv4 } = require('uuid');
const subscriptionRepository = require('../repositories/subscription_repository');
const planRepository = require('../repositories/plan_repository');
const billingPaymentRepository = require('../repositories/billing_payment_repository');

class SubscriptionService {
  async getPlans() {
    return await planRepository.findAll({ isActiveOnly: true });
  }

  async getShopSubscription(shopId) {
    const sub = await subscriptionRepository.findByShopId(shopId);
    if (!sub) {
      return null;
    }
    return sub;
  }

  async subscribe(shopId, { planId, paymentMethod = 'UPI', transactionId = '' }) {
    const plan = await planRepository.findById(planId);
    if (!plan) {
      throw { statusCode: 404, message: 'Subscription plan not found.' };
    }

    const now = new Date();
    const endDate = new Date();
    if (plan.billing_cycle === 'yearly') {
      endDate.setFullYear(endDate.getFullYear() + 1);
    } else {
      endDate.setMonth(endDate.getMonth() + 1);
    }

    const subId = `sub_${uuidv4().substring(0, 8)}`;
    const subscription = await subscriptionRepository.create({
      id: subId,
      shopId,
      planId: plan.id,
      planName: plan.name,
      status: 'active',
      startDate: now.toISOString(),
      endDate: endDate.toISOString(),
      renewalDate: endDate.toISOString(),
      billingCycle: plan.billing_cycle || 'monthly',
      amount: plan.price,
      currency: plan.currency || 'INR',
      autoRenew: true,
      provider: 'razorpay',
    });

    // Record Billing Payment
    const paymentId = `pay_${uuidv4().substring(0, 8)}`;
    const payment = await billingPaymentRepository.create({
      id: paymentId,
      shopId,
      subscriptionId: subscription.id,
      planId: plan.id,
      amount: plan.price,
      currency: plan.currency || 'INR',
      paymentMethod,
      provider: 'razorpay',
      transactionId: transactionId || `TXN_${Date.now()}`,
      status: 'successful',
      paidAt: now.toISOString(),
    });

    return {
      subscription,
      payment,
    };
  }

  async cancelSubscription(shopId) {
    const sub = await subscriptionRepository.findByShopId(shopId);
    if (!sub) {
      throw { statusCode: 404, message: 'No active subscription found.' };
    }

    const updated = await subscriptionRepository.update(sub.id, {
      status: 'cancelled',
      autoRenew: false,
    });

    return updated;
  }
}

module.exports = new SubscriptionService();
