const express = require('express');
const purchaseController = require('../controllers/purchase_controller');
const { authenticateToken } = require('../middleware/auth_middleware');
const { requireBusinessAccess } = require('../middleware/tenant_middleware');

const router = express.Router();

router.use(authenticateToken);
router.use(requireBusinessAccess);

router.get('/', (req, res, next) => purchaseController.getAll(req, res, next));
router.post('/', (req, res, next) => purchaseController.create(req, res, next));
router.get('/:id', (req, res, next) => purchaseController.getById(req, res, next));

module.exports = router;
