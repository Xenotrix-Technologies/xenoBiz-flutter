const businessRepository = require('../repositories/business_repository');

function requireBusinessAccess(req, res, next) {
  // Extract businessId from header, query param, or user default
  const businessId = req.headers['x-business-id'] || req.query.businessId || (req.user && req.user.businessId);

  if (!businessId) {
    return res.status(400).json({
      success: false,
      message: 'Business profile required. Please complete business setup first.',
      code: 'BUSINESS_SETUP_REQUIRED',
    });
  }

  // Admin bypass
  if (req.user && req.user.role === 'ADMIN') {
    req.businessId = businessId;
    return next();
  }

  // Check if authenticated user belongs to business
  const belongs = businessRepository.userBelongsToBusiness(req.user.userId, businessId);
  if (!belongs) {
    return res.status(403).json({
      success: false,
      message: 'Forbidden: You do not have access to this business data.',
    });
  }

  req.businessId = businessId;
  next();
}

module.exports = {
  requireBusinessAccess,
};
