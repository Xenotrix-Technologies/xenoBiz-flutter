const authService = require('../services/auth_service');

class AuthController {
  async register(req, res, next) {
    try {
      const {
        shopName,
        ownerName,
        name,
        email,
        username,
        loginId,
        emailOrPhone,
        password,
        phone,
        address,
        city,
        state,
        country,
        postalCode,
        gstNumber,
        businessType,
      } = req.body;

      const targetEmail = email || (emailOrPhone && emailOrPhone.includes('@') ? emailOrPhone : null);
      const targetPhone = phone || (emailOrPhone && !emailOrPhone.includes('@') ? emailOrPhone : null);

      const result = await authService.register({
        shopName: shopName || name,
        ownerName: ownerName || name,
        email: targetEmail,
        loginId: loginId || username,
        phone: targetPhone,
        password,
        address,
        city,
        state,
        country,
        postalCode,
        gstNumber,
        businessType,
      });

      res.status(201).json({
        success: true,
        message: 'Shop account registered successfully!',
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  async login(req, res, next) {
    try {
      const { email, username, loginId, emailOrPhone, emailOrUsername, identifier, password } = req.body;
      const cleanIdentifier = identifier || email || username || loginId || emailOrPhone || emailOrUsername;

      const result = await authService.login({
        identifier: cleanIdentifier,
        password,
      });

      res.json({
        success: true,
        message: 'Login successful!',
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  async getCurrentUser(req, res, next) {
    try {
      const shopId = req.user.shopId || req.user.userId;
      const result = await authService.getCurrentShop(shopId);
      res.json({
        success: true,
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  async logout(req, res) {
    res.json({
      success: true,
      message: 'Logged out successfully. Please clear token from client storage.',
    });
  }
}

module.exports = new AuthController();
