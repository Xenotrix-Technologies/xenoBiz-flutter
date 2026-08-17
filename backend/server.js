const express = require('express');
const cors = require('cors');
const env = require('./src/config/env');
const { initDb } = require('./src/db/database');
const errorHandler = require('./src/middleware/error_middleware');

// Route Imports
const authRoutes = require('./src/routes/auth_routes');
const shopRoutes = require('./src/routes/shop_routes');
const planRoutes = require('./src/routes/plan_routes');
const subscriptionRoutes = require('./src/routes/subscription_routes');
const paymentRoutes = require('./src/routes/payment_routes');
const adminRoutes = require('./src/routes/admin_routes');

const app = express();
const PORT = env.PORT;

// Initialize Database Schema
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
    service: 'XenoBiz Shop/Admin & Subscription Backend API',
    database: 'PostgreSQL',
    timestamp: new Date().toISOString(),
  });
});

// API Routes Mounting
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/shops', shopRoutes);
app.use('/api/v1/plans', planRoutes);
app.use('/api/v1/subscriptions', subscriptionRoutes);
app.use('/api/v1/payments', paymentRoutes);
app.use('/api/v1/admin', adminRoutes);

// Global Error Handler
app.use(errorHandler);

app.listen(PORT, '0.0.0.0', () => {
  console.log(`==================================================`);
  console.log(`XenoBiz Shop & Subscription Backend Server running on port ${PORT}`);
  console.log(`Local Access: http://localhost:${PORT}/api/v1/health`);
  console.log(`Emulator Access: http://10.0.2.2:${PORT}/api/v1/health`);
  console.log(`Environment: ${env.NODE_ENV}`);
  console.log(`==================================================`);
});

module.exports = app;
