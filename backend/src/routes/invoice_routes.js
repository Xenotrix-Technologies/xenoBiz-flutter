const express = require('express');
const invoiceController = require('../controllers/invoice_controller');
const { authenticateToken } = require('../middleware/auth_middleware');
const { requireBusinessAccess } = require('../middleware/tenant_middleware');

const router = express.Router();

router.use(authenticateToken);
router.use(requireBusinessAccess);

router.get('/', (req, res, next) => invoiceController.getAll(req, res, next));
router.post('/', (req, res, next) => invoiceController.create(req, res, next));
router.get('/:id', (req, res, next) => invoiceController.getById(req, res, next));
router.post('/:id/cancel', (req, res, next) => invoiceController.cancel(req, res, next));

module.exports = router;
