const adminService = require('../services/admin_service');

class AdminController {
  async getDashboard(req, res, next) {
    try {
      const data = await adminService.getDashboardData();
      res.json({
        success: true,
        data,
      });
    } catch (err) {
      next(err);
    }
  }

  async getShops(req, res, next) {
    try {
      const { status, query } = req.query;
      const data = await adminService.getAllShops({ status, query });
      res.json({
        success: true,
        data,
      });
    } catch (err) {
      next(err);
    }
  }

  async getShopDetails(req, res, next) {
    try {
      const { id } = req.params;
      const data = await adminService.getShopDetails(id);
      res.json({
        success: true,
        data,
      });
    } catch (err) {
      next(err);
    }
  }

  async updateShopStatus(req, res, next) {
    try {
      const { id } = req.params;
      const { status } = req.body;
      const data = await adminService.updateShopStatus(id, { status });
      res.json({
        success: true,
        message: 'Shop account status updated successfully.',
        data,
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new AdminController();
