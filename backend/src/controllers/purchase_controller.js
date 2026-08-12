const purchaseService = require('../services/purchase_service');

class PurchaseController {
  async getAll(req, res, next) {
    try {
      const { supplierId, paymentStatus, startDate, endDate, limit, offset } = req.query;
      const purchases = await purchaseService.getPurchases(req.businessId, {
        supplierId,
        paymentStatus,
        startDate,
        endDate,
        limit: limit ? parseInt(limit) : 100,
        offset: offset ? parseInt(offset) : 0,
      });

      res.json({
        success: true,
        data: purchases,
      });
    } catch (err) {
      next(err);
    }
  }

  async getById(req, res, next) {
    try {
      const purchase = await purchaseService.getPurchaseById(req.params.id, req.businessId);
      res.json({
        success: true,
        data: purchase,
      });
    } catch (err) {
      next(err);
    }
  }

  async create(req, res, next) {
    try {
      const purchase = await purchaseService.createPurchase(req.businessId, req.body, req.user.userId);
      res.status(201).json({
        success: true,
        message: 'Purchase created successfully and stock updated!',
        data: purchase,
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new PurchaseController();
