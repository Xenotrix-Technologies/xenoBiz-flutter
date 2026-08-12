const { db } = require('../db/database');

class AnalyticsRepository {
  getSalesSummary(businessId, startDate, endDate) {
    const res = db.prepare(`
      SELECT
        COALESCE(SUM(grand_total), 0) as total_sales,
        COALESCE(SUM(paid_amount), 0) as total_paid,
        COALESCE(SUM(due_amount), 0) as total_due,
        COUNT(id) as invoice_count
      FROM invoices
      WHERE business_id = ? AND status != 'cancelled' AND issue_date >= ? AND issue_date <= ?
    `).get(businessId, startDate, endDate);

    return res;
  }

  getPurchaseSummary(businessId, startDate, endDate) {
    const res = db.prepare(`
      SELECT
        COALESCE(SUM(grand_total), 0) as total_purchases,
        COALESCE(SUM(paid_amount), 0) as total_paid,
        COALESCE(SUM(due_amount), 0) as total_due,
        COUNT(id) as purchase_count
      FROM purchases
      WHERE business_id = ? AND status != 'cancelled' AND purchase_date >= ? AND purchase_date <= ?
    `).get(businessId, startDate, endDate);

    return res;
  }

  getProfitSummary(businessId, startDate, endDate) {
    const sales = this.getSalesSummary(businessId, startDate, endDate);
    const purchases = this.getPurchaseSummary(businessId, startDate, endDate);
    return {
      totalSales: sales.total_sales,
      totalPurchases: purchases.total_purchases,
      netProfit: sales.total_sales - purchases.total_purchases,
    };
  }

  getDailySalesTrend(businessId, days = 7) {
    return db.prepare(`
      SELECT
        DATE(issue_date) as date,
        COALESCE(SUM(grand_total), 0) as total_sales,
        COUNT(id) as count
      FROM invoices
      WHERE business_id = ? AND status != 'cancelled'
      GROUP BY DATE(issue_date)
      ORDER BY DATE(issue_date) DESC
      LIMIT ?
    `).all(businessId, days);
  }

  getSalesByPaymentMethod(businessId, startDate, endDate) {
    return db.prepare(`
      SELECT payment_method, COALESCE(SUM(grand_total), 0) as total_amount, COUNT(id) as count
      FROM invoices
      WHERE business_id = ? AND status != 'cancelled' AND issue_date >= ? AND issue_date <= ?
      GROUP BY payment_method
    `).all(businessId, startDate, endDate);
  }

  getTopProducts(businessId, limit = 5) {
    return db.prepare(`
      SELECT p.id, p.name, p.category, SUM(ii.quantity) as total_quantity_sold, SUM(ii.total) as total_revenue
      FROM invoice_items ii
      JOIN invoices i ON ii.invoice_id = i.id
      JOIN products p ON ii.product_id = p.id
      WHERE i.business_id = ? AND i.status != 'cancelled'
      GROUP BY p.id, p.name, p.category
      ORDER BY total_revenue DESC
      LIMIT ?
    `).all(businessId, limit);
  }

  getTopCustomers(businessId, limit = 5) {
    return db.prepare(`
      SELECT c.id, c.name, c.company, c.outstanding_balance, COALESCE(SUM(i.grand_total), 0) as total_spent, COUNT(i.id) as invoice_count
      FROM customers c
      LEFT JOIN invoices i ON c.id = i.customer_id AND i.status != 'cancelled'
      WHERE c.business_id = ?
      GROUP BY c.id, c.name, c.company, c.outstanding_balance
      ORDER BY total_spent DESC
      LIMIT ?
    `).all(businessId, limit);
  }

  getBusinessOverview(businessId) {
    const custRes = db.prepare('SELECT COUNT(*) as count, COALESCE(SUM(outstanding_balance), 0) as total_receivable FROM customers WHERE business_id = ?').get(businessId);
    const prodRes = db.prepare('SELECT COUNT(*) as count FROM products WHERE business_id = ?').get(businessId);
    const lowStockRes = db.prepare('SELECT COUNT(*) as count FROM products WHERE business_id = ? AND current_stock <= min_stock_level').get(businessId);
    const suppRes = db.prepare('SELECT COUNT(*) as count, COALESCE(SUM(outstanding_payable), 0) as total_payable FROM suppliers WHERE business_id = ?').get(businessId);
    const salesRes = db.prepare("SELECT COALESCE(SUM(grand_total), 0) as total_sales FROM invoices WHERE business_id = ? AND status != 'cancelled'").get(businessId);
    const purRes = db.prepare("SELECT COALESCE(SUM(grand_total), 0) as total_purchases FROM purchases WHERE business_id = ? AND status != 'cancelled'").get(businessId);

    return {
      totalCustomers: custRes.count,
      totalReceivables: custRes.total_receivable,
      totalProducts: prodRes.count,
      lowStockProducts: lowStockRes.count,
      totalSuppliers: suppRes.count,
      totalPayables: suppRes.total_payable,
      totalSales: salesRes.total_sales,
      totalPurchases: purRes.total_purchases,
      totalProfit: salesRes.total_sales - purRes.total_purchases,
    };
  }
}

module.exports = new AnalyticsRepository();
