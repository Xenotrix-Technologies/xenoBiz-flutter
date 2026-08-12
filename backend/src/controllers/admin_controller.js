const adminService = require('../services/admin_service');

class AdminController {
  async getStats(req, res, next) {
    try {
      const stats = await adminService.getSystemStats();
      res.json({
        success: true,
        data: stats,
      });
    } catch (err) {
      next(err);
    }
  }

  async getBusinesses(req, res, next) {
    try {
      const businesses = await adminService.getAllBusinesses();
      res.json({
        success: true,
        data: businesses,
      });
    } catch (err) {
      next(err);
    }
  }

  async getUsers(req, res, next) {
    try {
      const users = await adminService.getAllUsers();
      res.json({
        success: true,
        data: users,
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new AdminController();
