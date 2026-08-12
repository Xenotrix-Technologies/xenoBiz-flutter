const analyticsService = require('../services/analytics_service');

class DashboardController {
  async getSummary(req, res, next) {
    try {
      const summary = await analyticsService.getDashboardSummary(req.businessId);
      res.json({
        success: true,
        data: summary,
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new DashboardController();
