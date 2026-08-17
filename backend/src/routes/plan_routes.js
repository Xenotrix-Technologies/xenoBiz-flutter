const express = require('express');
const router = express.Router();
const subscriptionController = require('../controllers/subscription_controller');

router.get('/', subscriptionController.getPlans);

module.exports = router;
