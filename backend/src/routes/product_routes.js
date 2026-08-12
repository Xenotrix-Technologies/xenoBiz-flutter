const express = require('express');
const productController = require('../controllers/product_controller');
const { authenticateToken } = require('../middleware/auth_middleware');
const { requireBusinessAccess } = require('../middleware/tenant_middleware');

const router = express.Router();

router.use(authenticateToken);
router.use(requireBusinessAccess);

router.get('/', (req, res, next) => productController.getAll(req, res, next));
router.post('/', (req, res, next) => productController.create(req, res, next));
router.get('/lookup', (req, res, next) => productController.lookup(req, res, next));
router.get('/:id', (req, res, next) => productController.getById(req, res, next));
router.put('/:id', (req, res, next) => productController.update(req, res, next));
router.delete('/:id', (req, res, next) => productController.delete(req, res, next));

module.exports = router;
