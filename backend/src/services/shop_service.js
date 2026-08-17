const shopRepository = require('../repositories/shop_repository');
const subscriptionRepository = require('../repositories/subscription_repository');

class ShopService {
  async getShopProfile(shopId) {
    const shop = shopRepository.findById(shopId);
    if (!shop) {
      throw { statusCode: 404, message: 'Shop account not found.' };
    }

    const subscription = subscriptionRepository.findByShopId(shopId);
    const { password_hash, ...shopData } = shop;

    return {
      shop: shopData,
      subscription,
    };
  }

  async updateShopProfile(shopId, updateData) {
    const existing = shopRepository.findById(shopId);
    if (!existing) {
      throw { statusCode: 404, message: 'Shop account not found.' };
    }

    const updated = shopRepository.update(shopId, updateData);
    const { password_hash, ...shopData } = updated;

    return shopData;
  }
}

module.exports = new ShopService();
