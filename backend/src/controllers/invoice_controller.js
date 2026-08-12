const invoiceService = require('../services/invoice_service');

class InvoiceController {
  async getAll(req, res, next) {
    try {
      const { customerId, paymentStatus, status, startDate, endDate, search, limit, offset } = req.query;
      const invoices = await invoiceService.getInvoices(req.businessId, {
        customerId,
        paymentStatus,
        status,
        startDate,
        endDate,
        search,
        limit: limit ? parseInt(limit) : 100,
        offset: offset ? parseInt(offset) : 0,
      });

      res.json({
        success: true,
        data: invoices,
      });
    } catch (err) {
      next(err);
    }
  }

  async getById(req, res, next) {
    try {
      const invoice = await invoiceService.getInvoiceById(req.params.id, req.businessId);
      res.json({
        success: true,
        data: invoice,
      });
    } catch (err) {
      next(err);
    }
  }

  async create(req, res, next) {
    try {
      const invoice = await invoiceService.createInvoice(req.businessId, req.body, req.user.userId);
      res.status(201).json({
        success: true,
        message: 'Invoice created successfully and stock updated!',
        data: invoice,
      });
    } catch (err) {
      next(err);
    }
  }

  async cancel(req, res, next) {
    try {
      const invoice = await invoiceService.cancelInvoice(req.params.id, req.businessId);
      res.json({
        success: true,
        message: 'Invoice cancelled and stock restored successfully.',
        data: invoice,
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new InvoiceController();
