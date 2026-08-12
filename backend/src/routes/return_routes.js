const express = require('express');
const returnController = require('../controllers/return_controller');
const { authenticateToken } = require('../middleware/auth_middleware');
const { requireBusinessAccess } = require('../middleware/tenant_middleware');

const router = express.Router();

router.use(authenticateToken);
router.use(requireBusinessAccess);

router.post('/sales', (req, res, next) => returnController.createSalesReturn(req, res, next));
router.get('/sales', (req, res, next) => returnController.getSalesReturns(req, res, next));
router.post('/purchase', (req, res, next) => returnController.createPurchaseReturn(req, res, next));
router.get('/purchase', (req, res, next) => returnController.getPurchaseReturns(req, res, next));

module.exports = router;
