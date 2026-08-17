const { v4: uuidv4 } = require('uuid');
const billingPaymentRepository = require('../repositories/billing_payment_repository');

class PaymentService {
  async getShopPaymentHistory(shopId) {
    return await billingPaymentRepository.findByShopId(shopId);
  }

  async getPaymentById(paymentId) {
    const payment = await billingPaymentRepository.findById(paymentId);
    if (!payment) {
      throw { statusCode: 404, message: 'Payment record not found.' };
    }
    return payment;
  }

  async recordSubscriptionPayment(shopId, { planId, subscriptionId, amount, currency = 'INR', paymentMethod = 'UPI', transactionId, providerPaymentId, status = 'successful', failureReason }) {
    const paymentId = `pay_${uuidv4().substring(0, 8)}`;
    const payment = await billingPaymentRepository.create({
      id: paymentId,
      shopId,
      subscriptionId: subscriptionId || null,
      planId: planId || null,
      amount: amount || 0.0,
      currency,
      paymentMethod,
      provider: 'razorpay',
      transactionId: transactionId || `TXN_${Date.now()}`,
      providerPaymentId: providerPaymentId || null,
      status,
      paidAt: new Date().toISOString(),
      failureReason: failureReason || null,
    });

    return payment;
  }
}

module.exports = new PaymentService();
