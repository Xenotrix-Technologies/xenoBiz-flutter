const express = require('express');
const router = express.Router();
const subscriptionController = require('../controllers/subscription_controller');
const { authenticateToken } = require('../middleware/auth_middleware');

router.get('/plans', subscriptionController.getPlans);
router.get('/me', authenticateToken, subscriptionController.getMySubscription);
router.post('/subscribe', authenticateToken, subscriptionController.subscribe);
router.post('/cancel', authenticateToken, subscriptionController.cancel);

module.exports = router;
