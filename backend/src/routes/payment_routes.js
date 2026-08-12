const express = require('express');
const paymentController = require('../controllers/payment_controller');
const { authenticateToken } = require('../middleware/auth_middleware');
const { requireBusinessAccess } = require('../middleware/tenant_middleware');

const router = express.Router();

router.use(authenticateToken);
router.use(requireBusinessAccess);

router.get('/', (req, res, next) => paymentController.getAll(req, res, next));
router.post('/', (req, res, next) => paymentController.create(req, res, next));

module.exports = router;
