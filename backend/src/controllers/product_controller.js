const productService = require('../services/product_service');

class ProductController {
  async getAll(req, res, next) {
    try {
      const { search, category, status, lowStockOnly, limit, offset } = req.query;
      const products = await productService.getProducts(req.businessId, {
        search,
        category,
        status,
        lowStockOnly: lowStockOnly === 'true' || lowStockOnly === '1',
        limit: limit ? parseInt(limit) : 100,
        offset: offset ? parseInt(offset) : 0,
      });

      res.json({
        success: true,
        data: products,
      });
    } catch (err) {
      next(err);
    }
  }

  async getById(req, res, next) {
    try {
      const product = await productService.getProductById(req.params.id, req.businessId);
      res.json({
        success: true,
        data: product,
      });
    } catch (err) {
      next(err);
    }
  }

  async lookup(req, res, next) {
    try {
      const { code } = req.query;
      if (!code) {
        return res.status(400).json({ success: false, message: 'Barcode/SKU code parameter is required.' });
      }
      const product = await productService.findByBarcodeOrSku(code, req.businessId);
      res.json({
        success: true,
        data: product,
      });
    } catch (err) {
      next(err);
    }
  }

  async create(req, res, next) {
    try {
      const newProduct = await productService.createProduct(req.businessId, req.body, req.user.userId);
      res.status(201).json({
        success: true,
        message: 'Product created successfully!',
        data: newProduct,
      });
    } catch (err) {
      next(err);
    }
  }

  async update(req, res, next) {
    try {
      const updated = await productService.updateProduct(req.params.id, req.businessId, req.body);
      res.json({
        success: true,
        message: 'Product updated successfully!',
        data: updated,
      });
    } catch (err) {
      next(err);
    }
  }

  async delete(req, res, next) {
    try {
      await productService.deleteProduct(req.params.id, req.businessId);
      res.json({
        success: true,
        message: 'Product deleted/deactivated successfully!',
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new ProductController();
