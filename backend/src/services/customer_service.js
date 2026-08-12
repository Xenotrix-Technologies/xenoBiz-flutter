const { v4: uuidv4 } = require('uuid');
const customerRepository = require('../repositories/customer_repository');

class CustomerService {
  async getCustomers(businessId, options) {
    return customerRepository.findAll(businessId, options);
  }

  async getCustomerById(id, businessId) {
    const customer = customerRepository.findById(id, businessId);
    if (!customer) {
      throw { statusCode: 404, message: 'Customer not found.' };
    }
    const interactions = customerRepository.getInteractions(id, businessId);
    return { ...customer, interactions };
  }

  async createCustomer(businessId, customerData, userId) {
    if (!customerData.name) {
      throw { statusCode: 400, message: 'Customer name is required.' };
    }

    const customer = {
      id: `cust_${uuidv4().substring(0, 8)}`,
      businessId,
      name: customerData.name,
      phone: customerData.phone || null,
      email: customerData.email || null,
      address: customerData.address || null,
      company: customerData.company || null,
      customerType: customerData.customerType || customerData.customer_type || 'Regular',
      notes: customerData.notes || null,
      totalPurchases: customerData.totalPurchases || 0.0,
      totalPaid: customerData.totalPaid || 0.0,
      outstandingBalance: customerData.outstandingBalance || 0.0,
      creditLimit: customerData.creditLimit || 0.0,
      status: customerData.status || 'active',
      createdBy: userId,
    };

    return customerRepository.create(customer);
  }

  async updateCustomer(id, businessId, updates) {
    const existing = customerRepository.findById(id, businessId);
    if (!existing) {
      throw { statusCode: 404, message: 'Customer not found.' };
    }
    return customerRepository.update(id, businessId, updates);
  }

  async addCustomerInteraction(id, businessId, interactionData, userId) {
    const existing = customerRepository.findById(id, businessId);
    if (!existing) {
      throw { statusCode: 404, message: 'Customer not found.' };
    }
    return customerRepository.addInteraction({
      id: `int_${uuidv4().substring(0, 8)}`,
      businessId,
      customerId: id,
      type: interactionData.type || 'Note',
      notes: interactionData.notes,
      userId,
    });
  }

  async deleteCustomer(id, businessId) {
    return customerRepository.delete(id, businessId);
  }
}

module.exports = new CustomerService();
