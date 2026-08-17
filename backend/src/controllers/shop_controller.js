const shopService = require('../services/shop_service');

class ShopController {
  async getProfile(req, res, next) {
    try {
      const shopId = req.user.shopId;
      const data = await shopService.getShopProfile(shopId);
      res.json({
        success: true,
        data,
      });
    } catch (err) {
      next(err);
    }
  }

  async updateProfile(req, res, next) {
    try {
      const shopId = req.user.shopId;
      const data = await shopService.updateShopProfile(shopId, req.body);
      res.json({
        success: true,
        message: 'Shop profile updated successfully!',
        data,
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new ShopController();
