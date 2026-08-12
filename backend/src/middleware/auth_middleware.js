const jwt = require('jsonwebtoken');
const env = require('../config/env');
const userRepository = require('../repositories/user_repository');
const businessRepository = require('../repositories/business_repository');

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Authentication token missing or unauthorized.',
    });
  }

  jwt.verify(token, env.JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({
        success: false,
        message: 'Invalid or expired authentication token.',
      });
    }

    const user = userRepository.findById(decoded.userId);
    if (!user || user.account_status !== 'active') {
      return res.status(401).json({
        success: false,
        message: 'User account disabled or not found.',
      });
    }

    req.user = {
      userId: user.id,
      email: user.email,
      role: user.role,
      fullName: user.full_name,
    };

    // Attach primary businessId if available
    const primaryBiz = businessRepository.findPrimaryByUserId(user.id);
    if (primaryBiz) {
      req.user.businessId = primaryBiz.id;
    }

    next();
  });
}

module.exports = {
  authenticateToken,
};
