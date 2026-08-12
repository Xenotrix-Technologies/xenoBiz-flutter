const express = require('express');
const dashboardController = require('../controllers/dashboard_controller');
const { authenticateToken } = require('../middleware/auth_middleware');
const { requireBusinessAccess } = require('../middleware/tenant_middleware');

const router = express.Router();

router.use(authenticateToken);
router.use(requireBusinessAccess);

router.get('/summary', (req, res, next) => dashboardController.getSummary(req, res, next));

module.exports = router;
