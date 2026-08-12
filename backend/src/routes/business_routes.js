const express = require('express');
const businessController = require('../controllers/business_controller');
const { authenticateToken } = require('../middleware/auth_middleware');
const { requireBusinessAccess } = require('../middleware/tenant_middleware');

const router = express.Router();

router.use(authenticateToken);

router.post('/setup', (req, res, next) => businessController.setup(req, res, next));
router.get('/me', requireBusinessAccess, (req, res, next) => businessController.getProfile(req, res, next));
router.get('/:id', requireBusinessAccess, (req, res, next) => businessController.getProfile(req, res, next));
router.put('/:id', requireBusinessAccess, (req, res, next) => businessController.updateProfile(req, res, next));

module.exports = router;
