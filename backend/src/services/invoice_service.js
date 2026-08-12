const { v4: uuidv4 } = require('uuid');
const invoiceRepository = require('../repositories/invoice_repository');
const productRepository = require('../repositories/product_repository');
const inventoryRepository = require('../repositories/inventory_repository');
const customerRepository = require('../repositories/customer_repository');
const paymentRepository = require('../repositories/payment_repository');
const businessRepository = require('../repositories/business_repository');

class InvoiceService {
  async getInvoices(businessId, options) {
    return invoiceRepository.findAll(businessId, options);
  }

  async getInvoiceById(id, businessId) {
    const inv = invoiceRepository.findById(id, businessId);
    if (!inv) {
      throw { statusCode: 404, message: 'Invoice not found.' };
    }
    return inv;
  }

  async createInvoice(businessId, invoiceData, userId) {
    if (!invoiceData.items || !Array.isArray(invoiceData.items) || invoiceData.items.length === 0) {
      throw { statusCode: 400, message: 'Invoice items list cannot be empty.' };
    }

    const business = businessRepository.findById(businessId);
    const prefix = (business && business.invoice_prefix) ? business.invoice_prefix : 'INV-';
    const invoiceCount = invoiceRepository.count(businessId) + 1;
    const invNumber = invoiceData.invoiceNumber || invoiceData.invoice_number || `${prefix}${String(invoiceCount).padStart(4, '0')}`;

    const invoiceId = `inv_${uuidv4().substring(0, 8)}`;
    const now = new Date().toISOString();

    let custName = invoiceData.customerName || invoiceData.customer_name || 'Walk-in Customer';
    let custId = invoiceData.customerId || invoiceData.customer_id;

    if (custId) {
      const cust = customerRepository.findById(custId, businessId);
      if (cust) {
        custName = cust.name;
      }
    }

    let subtotal = 0.0;
    const formattedItems = [];

    for (const item of invoiceData.items) {
      if (!item.productId && !item.product_id && !item.productName) {
        throw { statusCode: 400, message: 'Product ID or Name is required for invoice item.' };
      }

      let prodName = item.productName || item.product_name;
      let prodId = item.productId || item.product_id;
      let unitPrice = item.unitPrice || item.unit_price;

      if (prodId) {
        const prod = productRepository.findById(prodId, businessId);
        if (prod) {
          prodName = prod.name;
          if (unitPrice === undefined) {
            unitPrice = prod.selling_price;
          }
        }
      }

      const qty = item.quantity || 1;
      unitPrice = unitPrice || 0.0;
      const tax = item.tax || 0.0;
      const disc = item.discount || 0.0;
      const itemTotal = (unitPrice * qty) + tax - disc;

      subtotal += itemTotal;

      formattedItems.push({
        id: `iitm_${uuidv4().substring(0, 8)}`,
        productId: prodId || null,
        productName: prodName,
        quantity: qty,
        unitPrice,
        tax,
        discount: disc,
        total: itemTotal,
      });
    }

    const discount = invoiceData.discount || 0.0;
    const taxAmount = invoiceData.taxAmount || invoiceData.tax_amount || 0.0;
    const otherCharges = invoiceData.otherCharges || invoiceData.other_charges || 0.0;
    const grandTotal = subtotal - discount + taxAmount + otherCharges;

    const paidAmount = invoiceData.paidAmount || invoiceData.paid_amount || 0.0;
    const dueAmount = Math.max(0, grandTotal - paidAmount);

    let paymentStatus = 'unpaid';
    if (dueAmount <= 0) {
      paymentStatus = 'paid';
    } else if (paidAmount > 0) {
      paymentStatus = 'partially_paid';
    }

    const invoice = {
      id: invoiceId,
      businessId,
      invoiceNumber: invNumber,
      customerId: custId || null,
      customerName: custName,
      issueDate: invoiceData.issueDate || invoiceData.issue_date || now,
      dueDate: invoiceData.dueDate || invoiceData.due_date || null,
      subtotal,
      discount,
      taxAmount,
      otherCharges,
      grandTotal,
      paidAmount,
      dueAmount,
      paymentStatus,
      paymentMethod: invoiceData.paymentMethod || invoiceData.payment_method || 'Cash',
      notes: invoiceData.notes || null,
      createdBy: userId,
    };

    const newInvoice = invoiceRepository.create(invoice, formattedItems);

    // Reduce stock and record audit movement
    for (const item of formattedItems) {
      if (item.productId) {
        productRepository.updateStock(item.productId, businessId, -item.quantity);
        inventoryRepository.recordMovement({
          id: `mov_${uuidv4().substring(0, 8)}`,
          businessId,
          productId: item.productId,
          quantity: -item.quantity,
          movementType: 'Sale',
          referenceDocument: newInvoice.invoice_number || newInvoice.id,
          reason: `Stock deducted via Invoice #${newInvoice.invoice_number}`,
          userId,
        });
      }
    }

    // Update customer purchases and outstanding balance
    if (custId) {
      customerRepository.updateBalances(custId, businessId, grandTotal, paidAmount);
    }

    // Record initial payment entry if paidAmount > 0
    if (paidAmount > 0) {
      paymentRepository.create({
        id: `pay_${uuidv4().substring(0, 8)}`,
        businessId,
        invoiceId: newInvoice.id,
        customerId: custId || null,
        amount: paidAmount,
        paymentMethod: newInvoice.payment_method,
        paymentType: 'IN',
        paymentStatus: 'completed',
        notes: `Initial payment for Invoice #${newInvoice.invoice_number}`,
        createdBy: userId,
      });
    }

    return newInvoice;
  }

  async cancelInvoice(id, businessId) {
    const inv = invoiceRepository.findById(id, businessId);
    if (!inv) {
      throw { statusCode: 404, message: 'Invoice not found.' };
    }
    if (inv.status === 'cancelled') {
      return inv;
    }

    // Revert stock deductions
    for (const item of inv.items) {
      if (item.product_id) {
        productRepository.updateStock(item.product_id, businessId, item.quantity);
        inventoryRepository.recordMovement({
          id: `mov_${uuidv4().substring(0, 8)}`,
          businessId,
          productId: item.product_id,
          quantity: item.quantity,
          movementType: 'Sales Return',
          referenceDocument: inv.invoice_number,
          reason: `Stock restored due to cancelled Invoice #${inv.invoice_number}`,
        });
      }
    }

    // Revert customer balance
    if (inv.customer_id) {
      customerRepository.updateBalances(inv.customer_id, businessId, -inv.grand_total, -inv.paid_amount);
    }

    return invoiceRepository.cancel(id, businessId);
  }
}

module.exports = new InvoiceService();
