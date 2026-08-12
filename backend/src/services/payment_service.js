const { v4: uuidv4 } = require('uuid');
const paymentRepository = require('../repositories/payment_repository');
const invoiceRepository = require('../repositories/invoice_repository');
const purchaseRepository = require('../repositories/purchase_repository');
const customerRepository = require('../repositories/customer_repository');
const supplierRepository = require('../repositories/supplier_repository');

class PaymentService {
  async getPayments(businessId, options) {
    return paymentRepository.findAll(businessId, options);
  }

  async recordPayment(businessId, paymentData, userId) {
    if (!paymentData.amount || paymentData.amount <= 0) {
      throw { statusCode: 400, message: 'Valid payment amount is required.' };
    }

    const paymentType = paymentData.paymentType || paymentData.payment_type || (paymentData.invoiceId ? 'IN' : 'OUT');
    const paymentId = `pay_${uuidv4().substring(0, 8)}`;

    const payment = {
      id: paymentId,
      businessId,
      invoiceId: paymentData.invoiceId || paymentData.invoice_id || null,
      purchaseId: paymentData.purchaseId || paymentData.purchase_id || null,
      customerId: paymentData.customerId || paymentData.customer_id || null,
      supplierId: paymentData.supplierId || paymentData.supplier_id || null,
      amount: paymentData.amount,
      paymentMethod: paymentData.paymentMethod || paymentData.payment_method || 'Cash',
      paymentType,
      paymentStatus: paymentData.paymentStatus || 'completed',
      transactionReference: paymentData.transactionReference || paymentData.transaction_reference || null,
      paymentDate: paymentData.paymentDate || paymentData.payment_date || new Date().toISOString(),
      notes: paymentData.notes || null,
      createdBy: userId,
    };

    const newPayment = paymentRepository.create(payment);

    // Apply payment towards invoice or purchase if linked
    if (payment.invoiceId) {
      invoiceRepository.updatePayment(payment.invoiceId, businessId, payment.amount);
      const inv = invoiceRepository.findById(payment.invoiceId, businessId);
      if (inv && inv.customer_id) {
        customerRepository.updateBalances(inv.customer_id, businessId, 0, payment.amount);
      }
    } else if (payment.customerId && paymentType === 'IN') {
      customerRepository.updateBalances(payment.customerId, businessId, 0, payment.amount);
    }

    if (payment.purchaseId) {
      purchaseRepository.updatePayment(payment.purchaseId, businessId, payment.amount);
      const pur = purchaseRepository.findById(payment.purchaseId, businessId);
      if (pur && pur.supplier_id) {
        supplierRepository.updatePayable(pur.supplier_id, businessId, -payment.amount);
      }
    } else if (payment.supplierId && paymentType === 'OUT') {
      supplierRepository.updatePayable(payment.supplierId, businessId, -payment.amount);
    }

    return newPayment;
  }
}

module.exports = new PaymentService();
