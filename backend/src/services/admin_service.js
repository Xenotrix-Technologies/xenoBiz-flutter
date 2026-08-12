const userRepository = require('../repositories/user_repository');
const businessRepository = require('../repositories/business_repository');

class AdminService {
  async getSystemStats() {
    const users = userRepository.findAll();
    const businesses = businessRepository.findAll();

    return {
      totalUsers: users.length,
      totalBusinesses: businesses.length,
      users,
      businesses,
    };
  }

  async getAllBusinesses() {
    return businessRepository.findAll();
  }

  async getAllUsers() {
    return userRepository.findAll();
  }
}

module.exports = new AdminService();
