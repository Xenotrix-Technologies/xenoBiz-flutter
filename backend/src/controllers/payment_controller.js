const paymentService = require('../services/payment_service');

class PaymentController {
  async getAll(req, res, next) {
    try {
      const { invoiceId, purchaseId, customerId, supplierId, paymentType, limit, offset } = req.query;
      const payments = await paymentService.getPayments(req.businessId, {
        invoiceId,
        purchaseId,
        customerId,
        supplierId,
        paymentType,
        limit: limit ? parseInt(limit) : 100,
        offset: offset ? parseInt(offset) : 0,
      });

      res.json({
        success: true,
        data: payments,
      });
    } catch (err) {
      next(err);
    }
  }

  async create(req, res, next) {
    try {
      const payment = await paymentService.recordPayment(req.businessId, req.body, req.user.userId);
      res.status(201).json({
        success: true,
        message: 'Payment recorded successfully!',
        data: payment,
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new PaymentController();
