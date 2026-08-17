const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/payment_controller');
const { authenticateToken } = require('../middleware/auth_middleware');

router.get('/my-history', authenticateToken, paymentController.getMyPaymentHistory);
router.get('/history', authenticateToken, paymentController.getMyPaymentHistory);
router.get('/:id', authenticateToken, paymentController.getPaymentDetails);
router.post('/', authenticateToken, paymentController.recordPayment);

module.exports = router;
