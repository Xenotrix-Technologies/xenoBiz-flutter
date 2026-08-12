const express = require('express');
const customerController = require('../controllers/customer_controller');
const { authenticateToken } = require('../middleware/auth_middleware');
const { requireBusinessAccess } = require('../middleware/tenant_middleware');

const router = express.Router();

router.use(authenticateToken);
router.use(requireBusinessAccess);

router.get('/', (req, res, next) => customerController.getAll(req, res, next));
router.post('/', (req, res, next) => customerController.create(req, res, next));
router.get('/:id', (req, res, next) => customerController.getById(req, res, next));
router.put('/:id', (req, res, next) => customerController.update(req, res, next));
router.delete('/:id', (req, res, next) => customerController.delete(req, res, next));
router.post('/:id/interactions', (req, res, next) => customerController.addInteraction(req, res, next));

module.exports = router;
