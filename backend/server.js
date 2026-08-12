const express = require('express');
const cors = require('cors');
const env = require('./src/config/env');
const { initDb } = require('./src/db/database');
const errorHandler = require('./src/middleware/error_middleware');

// Route Imports
const authRoutes = require('./src/routes/auth_routes');
const businessRoutes = require('./src/routes/business_routes');
const customerRoutes = require('./src/routes/customer_routes');
const crmRoutes = require('./src/routes/crm_routes');
const productRoutes = require('./src/routes/product_routes');
const inventoryRoutes = require('./src/routes/inventory_routes');
const supplierRoutes = require('./src/routes/supplier_routes');
const purchaseRoutes = require('./src/routes/purchase_routes');
const invoiceRoutes = require('./src/routes/invoice_routes');
const paymentRoutes = require('./src/routes/payment_routes');
const returnRoutes = require('./src/routes/return_routes');
const analyticsRoutes = require('./src/routes/analytics_routes');
const dashboardRoutes = require('./src/routes/dashboard_routes');
const adminRoutes = require('./src/routes/admin_routes');

const app = express();
const PORT = env.PORT;

// Initialize SQLite Schema
initDb();

// Middleware
app.use(cors());
app.use(express.json());

// Request logger
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Health Check
app.get('/api/v1/health', (req, res) => {
  res.json({
    status: 'online',
    service: 'XenoBiz Backend API',
    database: 'SQLite (Modular Repository Layer)',
    timestamp: new Date().toISOString(),
  });
});

// API Routes Mounting
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/business', businessRoutes);
app.use('/api/v1/customers', customerRoutes);
app.use('/api/v1/crm', crmRoutes);
app.use('/api/v1/products', productRoutes);
app.use('/api/v1/inventory', inventoryRoutes);
app.use('/api/v1/suppliers', supplierRoutes);
app.use('/api/v1/purchases', purchaseRoutes);
app.use('/api/v1/sales', invoiceRoutes);
app.use('/api/v1/invoices', invoiceRoutes);
app.use('/api/v1/payments', paymentRoutes);
app.use('/api/v1/returns', returnRoutes);
app.use('/api/v1/analytics', analyticsRoutes);
app.use('/api/v1/dashboard', dashboardRoutes);
app.use('/api/v1/admin', adminRoutes);

// Global Error Handler
app.use(errorHandler);

app.listen(PORT, '0.0.0.0', () => {
  console.log(`==================================================`);
  console.log(`XenoBiz Business Backend Server running on port ${PORT}`);
  console.log(`Local Access: http://localhost:${PORT}/api/v1/health`);
  console.log(`Emulator Access: http://10.0.2.2:${PORT}/api/v1/health`);
  console.log(`Environment: ${env.NODE_ENV}`);
  console.log(`==================================================`);
});

module.exports = app;
