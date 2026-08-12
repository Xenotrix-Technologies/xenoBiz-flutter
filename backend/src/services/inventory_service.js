const { v4: uuidv4 } = require('uuid');
const inventoryRepository = require('../repositories/inventory_repository');
const productRepository = require('../repositories/product_repository');

class InventoryService {
  async adjustStock(businessId, { productId, quantityDelta, movementType, referenceDocument, reason }, userId) {
    if (!productId || quantityDelta === undefined || !movementType) {
      throw { statusCode: 400, message: 'ProductId, quantityDelta, and movementType are required.' };
    }

    const prod = productRepository.findById(productId, businessId);
    if (!prod) {
      throw { statusCode: 404, message: 'Product not found.' };
    }

    // Update product stock balance
    productRepository.updateStock(productId, businessId, quantityDelta);

    // Record movement audit
    const movement = inventoryRepository.recordMovement({
      id: `mov_${uuidv4().substring(0, 8)}`,
      businessId,
      productId,
      quantity: quantityDelta,
      movementType,
      referenceDocument: referenceDocument || 'MANUAL_ADJUSTMENT',
      reason: reason || 'Stock adjustment',
      userId,
    });

    const updatedProduct = productRepository.findById(productId, businessId);
    return { movement, product: updatedProduct };
  }

  async getMovements(businessId, options) {
    return inventoryRepository.getMovementsByBusiness(businessId, options);
  }

  async getProductMovements(productId, businessId) {
    return inventoryRepository.getMovementsByProduct(productId, businessId);
  }
}

module.exports = new InventoryService();
