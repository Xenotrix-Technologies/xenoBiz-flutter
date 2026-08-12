const express = require('express');
const inventoryController = require('../controllers/inventory_controller');
const { authenticateToken } = require('../middleware/auth_middleware');
const { requireBusinessAccess } = require('../middleware/tenant_middleware');

const router = express.Router();

router.use(authenticateToken);
router.use(requireBusinessAccess);

router.post('/adjust', (req, res, next) => inventoryController.adjust(req, res, next));
router.get('/movements', (req, res, next) => inventoryController.getMovements(req, res, next));
router.get('/movements/product/:productId', (req, res, next) => inventoryController.getProductMovements(req, res, next));

module.exports = router;
