const inventoryService = require('../services/inventory_service');

class InventoryController {
  async adjust(req, res, next) {
    try {
      const result = await inventoryService.adjustStock(req.businessId, req.body, req.user.userId);
      res.json({
        success: true,
        message: 'Stock adjustment recorded successfully!',
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  async getMovements(req, res, next) {
    try {
      const { productId, movementType, limit, offset } = req.query;
      const movements = await inventoryService.getMovements(req.businessId, {
        productId,
        movementType,
        limit: limit ? parseInt(limit) : 100,
        offset: offset ? parseInt(offset) : 0,
      });

      res.json({
        success: true,
        data: movements,
      });
    } catch (err) {
      next(err);
    }
  }

  async getProductMovements(req, res, next) {
    try {
      const movements = await inventoryService.getProductMovements(req.params.productId, req.businessId);
      res.json({
        success: true,
        data: movements,
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new InventoryController();
