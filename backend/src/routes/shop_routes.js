const express = require('express');
const router = express.Router();
const shopController = require('../controllers/shop_controller');
const { authenticateToken } = require('../middleware/auth_middleware');

router.get('/me', authenticateToken, shopController.getProfile);
router.put('/me', authenticateToken, shopController.updateProfile);

module.exports = router;
