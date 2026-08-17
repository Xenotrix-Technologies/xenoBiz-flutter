const paymentService = require('../services/payment_service');

class PaymentController {
  async getMyPaymentHistory(req, res, next) {
    try {
      const shopId = req.user.shopId;
      const history = await paymentService.getShopPaymentHistory(shopId);
      res.json({
        success: true,
        data: history,
      });
    } catch (err) {
      next(err);
    }
  }

  async getPaymentDetails(req, res, next) {
    try {
      const { id } = req.params;
      const payment = await paymentService.getPaymentById(id);
      res.json({
        success: true,
        data: payment,
      });
    } catch (err) {
      next(err);
    }
  }

  async recordPayment(req, res, next) {
    try {
      const shopId = req.user.shopId;
      const payment = await paymentService.recordSubscriptionPayment(shopId, req.body);
      res.status(201).json({
        success: true,
        message: 'Payment recorded successfully.',
        data: payment,
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new PaymentController();
