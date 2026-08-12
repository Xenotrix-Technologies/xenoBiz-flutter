const businessService = require('../services/business_service');

class BusinessController {
  async setup(req, res, next) {
    try {
      const business = await businessService.setupBusiness(req.user.userId, req.body);
      res.json({
        success: true,
        message: 'Business profile configured successfully!',
        data: business,
      });
    } catch (err) {
      next(err);
    }
  }

  async getProfile(req, res, next) {
    try {
      const businessId = req.params.id || req.businessId || (req.user && req.user.businessId);
      const business = await businessService.getBusinessById(businessId);
      res.json({
        success: true,
        data: business,
      });
    } catch (err) {
      next(err);
    }
  }

  async updateProfile(req, res, next) {
    try {
      const businessId = req.params.id || req.businessId;
      const updated = await businessService.updateBusiness(businessId, req.body);
      res.json({
        success: true,
        message: 'Business profile updated successfully!',
        data: updated,
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new BusinessController();
