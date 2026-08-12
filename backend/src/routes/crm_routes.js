const express = require('express');
const crmController = require('../controllers/crm_controller');
const { authenticateToken } = require('../middleware/auth_middleware');
const { requireBusinessAccess } = require('../middleware/tenant_middleware');

const router = express.Router();

router.use(authenticateToken);
router.use(requireBusinessAccess);

router.get('/pipeline', (req, res, next) => crmController.getPipeline(req, res, next));
router.get('/leads', (req, res, next) => crmController.getLeads(req, res, next));
router.post('/leads', (req, res, next) => crmController.createLead(req, res, next));
router.get('/leads/:id', (req, res, next) => crmController.getLeadById(req, res, next));
router.put('/leads/:id', (req, res, next) => crmController.updateLead(req, res, next));
router.delete('/leads/:id', (req, res, next) => crmController.deleteLead(req, res, next));

module.exports = router;
