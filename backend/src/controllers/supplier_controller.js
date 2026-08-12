const supplierService = require('../services/supplier_service');

class SupplierController {
  async getAll(req, res, next) {
    try {
      const { search, limit, offset } = req.query;
      const suppliers = await supplierService.getSuppliers(req.businessId, {
        search,
        limit: limit ? parseInt(limit) : 100,
        offset: offset ? parseInt(offset) : 0,
      });

      res.json({
        success: true,
        data: suppliers,
      });
    } catch (err) {
      next(err);
    }
  }

  async getById(req, res, next) {
    try {
      const supplier = await supplierService.getSupplierById(req.params.id, req.businessId);
      res.json({
        success: true,
        data: supplier,
      });
    } catch (err) {
      next(err);
    }
  }

  async create(req, res, next) {
    try {
      const newSupplier = await supplierService.createSupplier(req.businessId, req.body);
      res.status(201).json({
        success: true,
        message: 'Supplier created successfully!',
        data: newSupplier,
      });
    } catch (err) {
      next(err);
    }
  }

  async update(req, res, next) {
    try {
      const updated = await supplierService.updateSupplier(req.params.id, req.businessId, req.body);
      res.json({
        success: true,
        message: 'Supplier updated successfully!',
        data: updated,
      });
    } catch (err) {
      next(err);
    }
  }

  async delete(req, res, next) {
    try {
      await supplierService.deleteSupplier(req.params.id, req.businessId);
      res.json({
        success: true,
        message: 'Supplier deleted successfully!',
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new SupplierController();
