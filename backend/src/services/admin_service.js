const shopRepository = require('../repositories/shop_repository');
const subscriptionRepository = require('../repositories/subscription_repository');
const billingPaymentRepository = require('../repositories/billing_payment_repository');
const planRepository = require('../repositories/plan_repository');

class AdminService {
  async getDashboardData() {
    const shops = shopRepository.findAll();
    const plans = planRepository.findAll();
    const subBreakdown = subscriptionRepository.countByStatus();
    const revenueSummary = billingPaymentRepository.getRevenueSummary();
    const recentPayments = billingPaymentRepository.findAll({ limit: 10 });

    const shopsWithDetails = shops.map((shop) => {
      const { password_hash, ...shopInfo } = shop;
      const sub = subscriptionRepository.findByShopId(shop.id);
      const latestPay = billingPaymentRepository.findLatestByShopId(shop.id);
      return {
        ...shopInfo,
        subscription: sub || null,
        latestPayment: latestPay || null,
      };
    });

    return {
      metrics: {
        totalShops: shops.length,
        totalPlans: plans.length,
        totalRevenue: revenueSummary.revenue.totalRevenue || 0,
        totalPayments: revenueSummary.revenue.totalPayments || 0,
        subscriptionBreakdown: subBreakdown,
        paymentBreakdown: revenueSummary.breakdown,
      },
      shops: shopsWithDetails,
      recentPayments,
    };
  }

  async getAllShops({ status, query } = {}) {
    const shops = shopRepository.findAll({ status, query });
    return shops.map((shop) => {
      const { password_hash, ...shopInfo } = shop;
      const sub = subscriptionRepository.findByShopId(shop.id);
      return {
        ...shopInfo,
        subscription: sub || null,
      };
    });
  }

  async getShopDetails(shopId) {
    const shop = shopRepository.findById(shopId);
    if (!shop) {
      throw { statusCode: 404, message: 'Shop account not found.' };
    }

    const { password_hash, ...shopInfo } = shop;
    const subscription = subscriptionRepository.findByShopId(shopId);
    const paymentHistory = billingPaymentRepository.findByShopId(shopId);

    return {
      shop: shopInfo,
      subscription,
      paymentHistory,
    };
  }

  async updateShopStatus(shopId, { status }) {
    const validStatuses = ['active', 'inactive', 'suspended', 'blocked', 'pending'];
    if (!validStatuses.includes(status)) {
      throw { statusCode: 400, message: `Invalid status. Must be one of: ${validStatuses.join(', ')}` };
    }

    const updated = shopRepository.update(shopId, { status });
    const { password_hash, ...shopInfo } = updated;

    return shopInfo;
  }
}

module.exports = new AdminService();
