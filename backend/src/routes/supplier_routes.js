const express = require('express');
const supplierController = require('../controllers/supplier_controller');
const { authenticateToken } = require('../middleware/auth_middleware');
const { requireBusinessAccess } = require('../middleware/tenant_middleware');

const router = express.Router();

router.use(authenticateToken);
router.use(requireBusinessAccess);

router.get('/', (req, res, next) => supplierController.getAll(req, res, next));
router.post('/', (req, res, next) => supplierController.create(req, res, next));
router.get('/:id', (req, res, next) => supplierController.getById(req, res, next));
router.put('/:id', (req, res, next) => supplierController.update(req, res, next));
router.delete('/:id', (req, res, next) => supplierController.delete(req, res, next));

module.exports = router;
