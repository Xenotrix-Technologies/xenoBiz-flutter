const analyticsService = require('../services/analytics_service');

class AnalyticsController {
  async getSalesAnalytics(req, res, next) {
    try {
      const data = await analyticsService.getSalesAnalytics(req.businessId, req.query);
      res.json({
        success: true,
        data,
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new AnalyticsController();
