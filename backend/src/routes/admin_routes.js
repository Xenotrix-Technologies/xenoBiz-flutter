const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin_controller');

router.get('/dashboard', adminController.getDashboard);
router.get('/shops', adminController.getShops);
router.get('/shops/:id', adminController.getShopDetails);
router.put('/shops/:id/status', adminController.updateShopStatus);

module.exports = router;
