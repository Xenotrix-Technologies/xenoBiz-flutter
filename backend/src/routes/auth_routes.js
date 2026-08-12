const express = require('express');
const authController = require('../controllers/auth_controller');
const businessController = require('../controllers/business_controller');
const { authenticateToken } = require('../middleware/auth_middleware');

const router = express.Router();

router.post('/register', (req, res, next) => authController.register(req, res, next));
router.post('/login', (req, res, next) => authController.login(req, res, next));
router.post('/logout', authenticateToken, (req, res) => authController.logout(req, res));
router.get('/me', authenticateToken, (req, res, next) => authController.getCurrentUser(req, res, next));

// Legacy / business setup endpoint compatibility
router.post('/business-setup', authenticateToken, (req, res, next) => businessController.setup(req, res, next));

module.exports = router;
