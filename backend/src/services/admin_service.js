const shopRepository = require('../repositories/shop_repository');
const subscriptionRepository = require('../repositories/subscription_repository');
const billingPaymentRepository = require('../repositories/billing_payment_repository');
const planRepository = require('../repositories/plan_repository');

class AdminService {
  async getDashboardData() {
    const shops = await shopRepository.findAll();
    const plans = await planRepository.findAll();
    const subBreakdown = await subscriptionRepository.countByStatus();
    const revenueSummary = await billingPaymentRepository.getRevenueSummary();
    const recentPayments = await billingPaymentRepository.findAll({ limit: 10 });

    const shopsWithDetails = await Promise.all(
      shops.map(async (shop) => {
        const { password_hash, ...shopInfo } = shop;
        const sub = await subscriptionRepository.findByShopId(shop.id);
        const latestPay = await billingPaymentRepository.findLatestByShopId(shop.id);
        return {
          ...shopInfo,
          subscription: sub || null,
          latestPayment: latestPay || null,
        };
      })
    );

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
    const shops = await shopRepository.findAll({ status, query });
    return await Promise.all(
      shops.map(async (shop) => {
        const { password_hash, ...shopInfo } = shop;
        const sub = await subscriptionRepository.findByShopId(shop.id);
        return {
          ...shopInfo,
          subscription: sub || null,
        };
      })
    );
  }

  async getShopDetails(shopId) {
    const shop = await shopRepository.findById(shopId);
    if (!shop) {
      throw { statusCode: 404, message: 'Shop account not found.' };
    }

    const { password_hash, ...shopInfo } = shop;
    const subscription = await subscriptionRepository.findByShopId(shopId);
    const paymentHistory = await billingPaymentRepository.findByShopId(shopId);

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

    const updated = await shopRepository.update(shopId, { status });
    const { password_hash, ...shopInfo } = updated;

    return shopInfo;
  }
}

module.exports = new AdminService();
