const customerService = require('../services/customer_service');

class CustomerController {
  async getAll(req, res, next) {
    try {
      const { search, customerType, status, limit, offset } = req.query;
      const customers = await customerService.getCustomers(req.businessId, {
        search,
        customerType,
        status,
        limit: limit ? parseInt(limit) : 100,
        offset: offset ? parseInt(offset) : 0,
      });

      res.json({
        success: true,
        data: customers,
      });
    } catch (err) {
      next(err);
    }
  }

  async getById(req, res, next) {
    try {
      const customer = await customerService.getCustomerById(req.params.id, req.businessId);
      res.json({
        success: true,
        data: customer,
      });
    } catch (err) {
      next(err);
    }
  }

  async create(req, res, next) {
    try {
      const newCustomer = await customerService.createCustomer(req.businessId, req.body, req.user.userId);
      res.status(201).json({
        success: true,
        message: 'Customer created successfully!',
        data: newCustomer,
      });
    } catch (err) {
      next(err);
    }
  }

  async update(req, res, next) {
    try {
      const updated = await customerService.updateCustomer(req.params.id, req.businessId, req.body);
      res.json({
        success: true,
        message: 'Customer updated successfully!',
        data: updated,
      });
    } catch (err) {
      next(err);
    }
  }

  async addInteraction(req, res, next) {
    try {
      const interaction = await customerService.addCustomerInteraction(req.params.id, req.businessId, req.body, req.user.userId);
      res.status(201).json({
        success: true,
        message: 'Interaction recorded successfully!',
        data: interaction,
      });
    } catch (err) {
      next(err);
    }
  }

  async delete(req, res, next) {
    try {
      await customerService.deleteCustomer(req.params.id, req.businessId);
      res.json({
        success: true,
        message: 'Customer deleted successfully!',
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new CustomerController();
