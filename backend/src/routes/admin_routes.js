const express = require('express');
const adminController = require('../controllers/admin_controller');
const { authenticateToken } = require('../middleware/auth_middleware');
const { requireAdmin } = require('../middleware/admin_middleware');

const router = express.Router();

router.use(authenticateToken);
router.use(requireAdmin);

router.get('/stats', (req, res, next) => adminController.getStats(req, res, next));
router.get('/businesses', (req, res, next) => adminController.getBusinesses(req, res, next));
router.get('/users', (req, res, next) => adminController.getUsers(req, res, next));

module.exports = router;
