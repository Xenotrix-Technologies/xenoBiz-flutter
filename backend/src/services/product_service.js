const { v4: uuidv4 } = require('uuid');
const productRepository = require('../repositories/product_repository');
const inventoryRepository = require('../repositories/inventory_repository');

class ProductService {
  async getProducts(businessId, options) {
    return productRepository.findAll(businessId, options);
  }

  async getProductById(id, businessId) {
    const prod = productRepository.findById(id, businessId);
    if (!prod) {
      throw { statusCode: 404, message: 'Product not found.' };
    }
    return prod;
  }

  async findByBarcodeOrSku(identifier, businessId) {
    const prod = productRepository.findByBarcodeOrSku(identifier, businessId);
    if (!prod) {
      throw { statusCode: 404, message: 'Product not found with specified Barcode/SKU.' };
    }
    return prod;
  }

  async createProduct(businessId, productData, userId) {
    if (!productData.name) {
      throw { statusCode: 400, message: 'Product name is required.' };
    }

    const productId = `prod_${uuidv4().substring(0, 8)}`;
    const initialStock = productData.currentStock || productData.current_stock || 0;

    const product = {
      id: productId,
      businessId,
      name: productData.name,
      sku: productData.sku || `SKU-${Math.floor(100000 + Math.random() * 900000)}`,
      barcode: productData.barcode || null,
      description: productData.description || null,
      category: productData.category || 'General',
      brand: productData.brand || null,
      unit: productData.unit || 'pcs',
      purchasePrice: productData.purchasePrice || productData.purchase_price || 0.0,
      sellingPrice: productData.sellingPrice || productData.selling_price || 0.0,
      taxPercentage: productData.taxPercentage || productData.tax_percentage || 0.0,
      minStockLevel: productData.minStockLevel || productData.min_stock_level || 5,
      currentStock: initialStock,
      imageUrl: productData.imageUrl || productData.image_url || null,
      status: productData.status || 'active',
    };

    const newProd = productRepository.create(product);

    // Audit initial opening stock if > 0
    if (initialStock > 0) {
      inventoryRepository.recordMovement({
        id: `mov_${uuidv4().substring(0, 8)}`,
        businessId,
        productId: newProd.id,
        quantity: initialStock,
        movementType: 'Opening Stock',
        referenceDocument: 'PRODUCT_CREATION',
        reason: 'Initial opening stock setup',
        userId,
      });
    }

    return newProd;
  }

  async updateProduct(id, businessId, updates) {
    const existing = productRepository.findById(id, businessId);
    if (!existing) {
      throw { statusCode: 404, message: 'Product not found.' };
    }
    return productRepository.update(id, businessId, updates);
  }

  async deleteProduct(id, businessId) {
    return productRepository.delete(id, businessId);
  }
}

module.exports = new ProductService();
