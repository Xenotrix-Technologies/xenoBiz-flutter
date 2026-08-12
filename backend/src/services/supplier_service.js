const { v4: uuidv4 } = require('uuid');
const supplierRepository = require('../repositories/supplier_repository');

class SupplierService {
  async getSuppliers(businessId, options) {
    return supplierRepository.findAll(businessId, options);
  }

  async getSupplierById(id, businessId) {
    const supp = supplierRepository.findById(id, businessId);
    if (!supp) {
      throw { statusCode: 404, message: 'Supplier not found.' };
    }
    return supp;
  }

  async createSupplier(businessId, supplierData) {
    if (!supplierData.name) {
      throw { statusCode: 400, message: 'Supplier name is required.' };
    }

    const supplier = {
      id: `supp_${uuidv4().substring(0, 8)}`,
      businessId,
      name: supplierData.name,
      company: supplierData.company || null,
      phone: supplierData.phone || null,
      email: supplierData.email || null,
      address: supplierData.address || null,
      taxNumber: supplierData.taxNumber || supplierData.tax_number || null,
      notes: supplierData.notes || null,
      outstandingPayable: supplierData.outstandingPayable || supplierData.outstanding_payable || 0.0,
      status: supplierData.status || 'active',
    };

    return supplierRepository.create(supplier);
  }

  async updateSupplier(id, businessId, updates) {
    const existing = supplierRepository.findById(id, businessId);
    if (!existing) {
      throw { statusCode: 404, message: 'Supplier not found.' };
    }
    return supplierRepository.update(id, businessId, updates);
  }

  async deleteSupplier(id, businessId) {
    return supplierRepository.delete(id, businessId);
  }
}

module.exports = new SupplierService();
