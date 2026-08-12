const express = require('express');
const analyticsController = require('../controllers/analytics_controller');
const { authenticateToken } = require('../middleware/auth_middleware');
const { requireBusinessAccess } = require('../middleware/tenant_middleware');

const router = express.Router();

router.use(authenticateToken);
router.use(requireBusinessAccess);

router.get('/sales', (req, res, next) => analyticsController.getSalesAnalytics(req, res, next));

module.exports = router;
