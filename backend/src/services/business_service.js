const { v4: uuidv4 } = require('uuid');
const businessRepository = require('../repositories/business_repository');
const userRepository = require('../repositories/user_repository');

class BusinessService {
  async setupBusiness(userId, businessData) {
    if (!businessData.name) {
      throw { statusCode: 400, message: 'Business name is required.' };
    }

    let existingBiz = businessRepository.findPrimaryByUserId(userId);
    if (existingBiz) {
      // Update existing
      return businessRepository.update(existingBiz.id, businessData);
    }

    const businessId = `biz_${uuidv4().substring(0, 8)}`;
    const newBiz = businessRepository.create({
      id: businessId,
      name: businessData.name,
      businessType: businessData.businessType || businessData.business_type || 'Retail',
      description: businessData.description || null,
      logo: businessData.logo || null,
      address: businessData.address || null,
      city: businessData.city || null,
      state: businessData.state || null,
      country: businessData.country || 'India',
      zipCode: businessData.zipCode || businessData.zip_code || null,
      phone: businessData.phone || null,
      email: businessData.email || null,
      website: businessData.website || null,
      taxNumber: businessData.taxNumber || businessData.tax_number || businessData.gstin || null,
      currency: businessData.currency || 'INR',
      invoicePrefix: businessData.invoicePrefix || businessData.invoice_prefix || 'INV-',
    }, userId, 'OWNER');

    return newBiz;
  }

  async getBusinessById(businessId) {
    const biz = businessRepository.findById(businessId);
    if (!biz) {
      throw { statusCode: 404, message: 'Business profile not found.' };
    }
    return biz;
  }

  async getUserBusinesses(userId) {
    return businessRepository.findByUserId(userId);
  }

  async updateBusiness(businessId, updates) {
    return businessRepository.update(businessId, updates);
  }
}

module.exports = new BusinessService();
