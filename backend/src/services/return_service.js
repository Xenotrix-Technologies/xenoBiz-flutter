const { v4: uuidv4 } = require('uuid');
const returnRepository = require('../repositories/return_repository');
const productRepository = require('../repositories/product_repository');
const inventoryRepository = require('../repositories/inventory_repository');
const customerRepository = require('../repositories/customer_repository');
const supplierRepository = require('../repositories/supplier_repository');

class ReturnService {
  async processSalesReturn(businessId, returnData, userId) {
    if (!returnData.productId || !returnData.quantity || returnData.quantity <= 0) {
      throw { statusCode: 400, message: 'ProductId and positive quantity are required.' };
    }

    const retId = `sret_${uuidv4().substring(0, 8)}`;
    const salesReturn = {
      id: retId,
      businessId,
      invoiceId: returnData.invoiceId || returnData.invoice_id || null,
      customerId: returnData.customerId || returnData.customer_id || null,
      productId: returnData.productId || returnData.product_id,
      quantity: returnData.quantity,
      refundAmount: returnData.refundAmount || returnData.refund_amount || 0.0,
      reason: returnData.reason || 'Sales Return',
      returnDate: returnData.returnDate || new Date().toISOString(),
      createdBy: userId,
    };

    const record = returnRepository.createSalesReturn(salesReturn);

    // Increase product stock & record audit
    productRepository.updateStock(salesReturn.productId, businessId, salesReturn.quantity);
    inventoryRepository.recordMovement({
      id: `mov_${uuidv4().substring(0, 8)}`,
      businessId,
      productId: salesReturn.productId,
      quantity: salesReturn.quantity,
      movementType: 'Sales Return',
      referenceDocument: salesReturn.invoiceId || 'SALES_RETURN',
      reason: salesReturn.reason,
      userId,
    });

    // Reduce customer balance if linked
    if (salesReturn.customerId) {
      customerRepository.updateBalances(salesReturn.customerId, businessId, -salesReturn.refundAmount, 0);
    }

    return record;
  }

  async getSalesReturns(businessId) {
    return returnRepository.getSalesReturns(businessId);
  }

  async processPurchaseReturn(businessId, returnData, userId) {
    if (!returnData.productId || !returnData.quantity || returnData.quantity <= 0) {
      throw { statusCode: 400, message: 'ProductId and positive quantity are required.' };
    }

    const retId = `pret_${uuidv4().substring(0, 8)}`;
    const purchaseReturn = {
      id: retId,
      businessId,
      purchaseId: returnData.purchaseId || returnData.purchase_id || null,
      supplierId: returnData.supplierId || returnData.supplier_id || null,
      productId: returnData.productId || returnData.product_id,
      quantity: returnData.quantity,
      returnAmount: returnData.returnAmount || returnData.return_amount || 0.0,
      reason: returnData.reason || 'Purchase Return',
      returnDate: returnData.returnDate || new Date().toISOString(),
      createdBy: userId,
    };

    const record = returnRepository.createPurchaseReturn(purchaseReturn);

    // Decrease product stock & record audit
    productRepository.updateStock(purchaseReturn.productId, businessId, -purchaseReturn.quantity);
    inventoryRepository.recordMovement({
      id: `mov_${uuidv4().substring(0, 8)}`,
      businessId,
      productId: purchaseReturn.productId,
      quantity: -purchaseReturn.quantity,
      movementType: 'Purchase Return',
      referenceDocument: purchaseReturn.purchaseId || 'PURCHASE_RETURN',
      reason: purchaseReturn.reason,
      userId,
    });

    // Reduce supplier payable if linked
    if (purchaseReturn.supplierId) {
      supplierRepository.updatePayable(purchaseReturn.supplierId, businessId, -purchaseReturn.returnAmount);
    }

    return record;
  }

  async getPurchaseReturns(businessId) {
    return returnRepository.getPurchaseReturns(businessId);
  }
}

module.exports = new ReturnService();
