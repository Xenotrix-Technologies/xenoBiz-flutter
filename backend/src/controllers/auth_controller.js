const authService = require('../services/auth_service');

class AuthController {
  async register(req, res, next) {
    try {
      const { name, email, username, emailOrPhone, password, phone } = req.body;
      const targetEmail = email || (emailOrPhone && emailOrPhone.includes('@') ? emailOrPhone : null);
      const targetPhone = phone || (emailOrPhone && !emailOrPhone.includes('@') ? emailOrPhone : null);

      const result = await authService.register({
        email: targetEmail,
        username: username || (emailOrPhone && !emailOrPhone.includes('@') ? emailOrPhone : null),
        fullName: name,
        phone: targetPhone,
        password,
      });

      res.status(201).json({
        success: true,
        message: 'User registered successfully!',
        data: result,
      });
    } catch (err) {
      next(err);
    }
  }

  async login(req, res, next) {
    try {
      const { email, username, emailOrPhone, emailOrUsername, password } = req.body;
      const identifier = email || username || emailOrPhone || emailOrUsername;

      const result = await authService.login({
        emailOrUsername: identifier,
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
      const result = await authService.getCurrentUser(req.user.userId);
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
