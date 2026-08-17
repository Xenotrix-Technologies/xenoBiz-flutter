const jwt = require('jsonwebtoken');
const env = require('../config/env');
const shopRepository = require('../repositories/shop_repository');

async function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Authentication token missing or unauthorized.',
    });
  }

  try {
    const decoded = jwt.verify(token, env.JWT_SECRET);
    const targetId = decoded.shopId || decoded.userId;
    const shop = await shopRepository.findById(targetId);

    if (!shop) {
      return res.status(401).json({
        success: false,
        message: 'Shop account not found.',
      });
    }

    if (shop.status !== 'active') {
      return res.status(403).json({
        success: false,
        message: `Shop account is currently ${shop.status}.`,
      });
    }

    req.user = {
      shopId: shop.id,
      userId: shop.id,
      email: shop.email,
      role: shop.role,
      fullName: shop.owner_name,
      shopName: shop.shop_name,
    };

    req.shop = shop;
    next();
  } catch (err) {
    return res.status(403).json({
      success: false,
      message: 'Invalid or expired authentication token.',
    });
  }
}

module.exports = {
  authenticateToken,
};
