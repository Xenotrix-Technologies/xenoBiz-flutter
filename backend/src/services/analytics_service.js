const analyticsRepository = require('../repositories/analytics_repository');
const invoiceRepository = require('../repositories/invoice_repository');
const paymentRepository = require('../repositories/payment_repository');

class AnalyticsService {
  async getDashboardSummary(businessId) {
    const today = new Date();
    const todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate()).toISOString();
    const todayEnd = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59).toISOString();

    const monthStart = new Date(today.getFullYear(), today.getMonth(), 1).toISOString();
    const monthEnd = new Date(today.getFullYear(), today.getMonth() + 1, 0, 23, 59, 59).toISOString();

    const todaySales = analyticsRepository.getSalesSummary(businessId, todayStart, todayEnd);
    const todayPurchases = analyticsRepository.getPurchaseSummary(businessId, todayStart, todayEnd);
    const monthlySales = analyticsRepository.getSalesSummary(businessId, monthStart, monthEnd);

    const overview = analyticsRepository.getBusinessOverview(businessId);
    const recentInvoices = invoiceRepository.findAll(businessId, { limit: 5 });
    const recentPayments = paymentRepository.findAll(businessId, { limit: 5 });
    const topProducts = analyticsRepository.getTopProducts(businessId, 5);
    const topCustomers = analyticsRepository.getTopCustomers(businessId, 5);
    const salesTrend = analyticsRepository.getDailySalesTrend(businessId, 7);
    const overdueCount = invoiceRepository.countOverdue(businessId);

    return {
      today: {
        sales: todaySales.total_sales,
        purchases: todayPurchases.total_purchases,
        profit: todaySales.total_sales - todayPurchases.total_purchases,
        invoiceCount: todaySales.invoice_count,
        paid: todaySales.total_paid,
        due: todaySales.total_due,
      },
      monthly: {
        sales: monthlySales.total_sales,
        paid: monthlySales.total_paid,
        due: monthlySales.total_due,
      },
      overview,
      overdueInvoicesCount: overdueCount,
      recentInvoices,
      recentTransactions: recentPayments,
      topProducts,
      topCustomers,
      salesChart: salesTrend.reverse(),
    };
  }

  async getSalesAnalytics(businessId, { startDate, endDate, days }) {
    const now = new Date();
    let start = startDate;
    let end = endDate || now.toISOString();

    if (!start) {
      const d = new Date();
      d.setDate(d.getDate() - (days ? parseInt(days) : 30));
      start = d.toISOString();
    }

    const salesSummary = analyticsRepository.getSalesSummary(businessId, start, end);
    const byPaymentMethod = analyticsRepository.getSalesByPaymentMethod(businessId, start, end);
    const trend = analyticsRepository.getDailySalesTrend(businessId, days || 30);
    const topProducts = analyticsRepository.getTopProducts(businessId, 10);

    return {
      summary: salesSummary,
      byPaymentMethod,
      trend,
      topProducts,
    };
  }
}

module.exports = new AnalyticsService();
