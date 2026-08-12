const returnService = require('../services/return_service');

class ReturnController {
  async createSalesReturn(req, res, next) {
    try {
      const record = await returnService.processSalesReturn(req.businessId, req.body, req.user.userId);
      res.status(201).json({
        success: true,
        message: 'Sales return processed and stock restored!',
        data: record,
      });
    } catch (err) {
      next(err);
    }
  }

  async getSalesReturns(req, res, next) {
    try {
      const records = await returnService.getSalesReturns(req.businessId);
      res.json({
        success: true,
        data: records,
      });
    } catch (err) {
      next(err);
    }
  }

  async createPurchaseReturn(req, res, next) {
    try {
      const record = await returnService.processPurchaseReturn(req.businessId, req.body, req.user.userId);
      res.status(201).json({
        success: true,
        message: 'Purchase return processed and stock deducted!',
        data: record,
      });
    } catch (err) {
      next(err);
    }
  }

  async getPurchaseReturns(req, res, next) {
    try {
      const records = await returnService.getPurchaseReturns(req.businessId);
      res.json({
        success: true,
        data: records,
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new ReturnController();
