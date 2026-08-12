const { v4: uuidv4 } = require('uuid');
const purchaseRepository = require('../repositories/purchase_repository');
const productRepository = require('../repositories/product_repository');
const inventoryRepository = require('../repositories/inventory_repository');
const supplierRepository = require('../repositories/supplier_repository');
const paymentRepository = require('../repositories/payment_repository');

class PurchaseService {
  async getPurchases(businessId, options) {
    return purchaseRepository.findAll(businessId, options);
  }

  async getPurchaseById(id, businessId) {
    const purchase = purchaseRepository.findById(id, businessId);
    if (!purchase) {
      throw { statusCode: 404, message: 'Purchase record not found.' };
    }
    return purchase;
  }

  async createPurchase(businessId, purchaseData, userId) {
    if (!purchaseData.items || !Array.isArray(purchaseData.items) || purchaseData.items.length === 0) {
      throw { statusCode: 400, message: 'Purchase items list cannot be empty.' };
    }

    const purchaseId = `pur_${uuidv4().substring(0, 8)}`;
    const now = new Date().toISOString();

    let subtotal = 0.0;
    const formattedItems = [];

    for (const item of purchaseData.items) {
      if (!item.productId && !item.product_id && !item.productName) {
        throw { statusCode: 400, message: 'Product ID or Name is required for purchase item.' };
      }

      let prodName = item.productName || item.product_name;
      let prodId = item.productId || item.product_id;

      if (prodId) {
        const prod = productRepository.findById(prodId, businessId);
        if (prod) {
          prodName = prod.name;
        }
      }

      const qty = item.quantity || 1;
      const unitPrice = item.purchasePrice || item.purchase_price || 0.0;
      const tax = item.tax || 0.0;
      const disc = item.discount || 0.0;
      const itemTotal = (unitPrice * qty) + tax - disc;

      subtotal += itemTotal;

      formattedItems.push({
        id: `pitm_${uuidv4().substring(0, 8)}`,
        productId: prodId || null,
        productName: prodName,
        quantity: qty,
        purchasePrice: unitPrice,
        tax,
        discount: disc,
        total: itemTotal,
      });
    }

    const discount = purchaseData.discount || 0.0;
    const taxAmount = purchaseData.taxAmount || purchaseData.tax_amount || 0.0;
    const otherCharges = purchaseData.otherCharges || purchaseData.other_charges || 0.0;
    const grandTotal = subtotal - discount + taxAmount + otherCharges;

    const paidAmount = purchaseData.paidAmount || purchaseData.paid_amount || 0.0;
    const dueAmount = Math.max(0, grandTotal - paidAmount);

    let paymentStatus = 'unpaid';
    if (dueAmount <= 0) {
      paymentStatus = 'paid';
    } else if (paidAmount > 0) {
      paymentStatus = 'partially_paid';
    }

    const purchase = {
      id: purchaseId,
      businessId,
      supplierId: purchaseData.supplierId || purchaseData.supplier_id || null,
      invoiceNumber: purchaseData.invoiceNumber || purchaseData.invoice_number || `PO-${Math.floor(1000 + Math.random() * 9000)}`,
      purchaseDate: purchaseData.purchaseDate || purchaseData.purchase_date || now,
      subtotal,
      discount,
      taxAmount,
      otherCharges,
      grandTotal,
      paidAmount,
      dueAmount,
      paymentStatus,
      paymentMethod: purchaseData.paymentMethod || purchaseData.payment_method || 'Cash',
      notes: purchaseData.notes || null,
      createdBy: userId,
    };

    const newPurchase = purchaseRepository.create(purchase, formattedItems);

    // Update stock and supplier payables
    for (const item of formattedItems) {
      if (item.productId) {
        productRepository.updateStock(item.productId, businessId, item.quantity);
        inventoryRepository.recordMovement({
          id: `mov_${uuidv4().substring(0, 8)}`,
          businessId,
          productId: item.productId,
          quantity: item.quantity,
          movementType: 'Purchase',
          referenceDocument: newPurchase.invoice_number || newPurchase.id,
          reason: `Stock added via Purchase #${newPurchase.invoice_number}`,
          userId,
        });
      }
    }

    // Update supplier payable balance if dueAmount > 0 and supplierId specified
    if (newPurchase.supplier_id && dueAmount > 0) {
      supplierRepository.updatePayable(newPurchase.supplier_id, businessId, dueAmount);
    }

    // Record initial payment entry if paidAmount > 0
    if (paidAmount > 0) {
      paymentRepository.create({
        id: `pay_${uuidv4().substring(0, 8)}`,
        businessId,
        purchaseId: newPurchase.id,
        supplierId: newPurchase.supplier_id,
        amount: paidAmount,
        paymentMethod: newPurchase.payment_method,
        paymentType: 'OUT',
        paymentStatus: 'completed',
        notes: `Initial payment for Purchase #${newPurchase.invoice_number}`,
        createdBy: userId,
      });
    }

    return newPurchase;
  }
}

module.exports = new PurchaseService();
