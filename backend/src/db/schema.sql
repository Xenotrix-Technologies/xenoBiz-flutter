-- XenoBiz Shop/Admin Account & Subscription Billing Database Schema (SQLite)

PRAGMA foreign_keys = ON;

-- 1. Shops / Admin Accounts Table
CREATE TABLE IF NOT EXISTS shops (
    id VARCHAR(36) PRIMARY KEY,
    shop_name VARCHAR(150) NOT NULL,
    owner_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(50),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'India',
    postal_code VARCHAR(20),
    gst_number VARCHAR(50),
    business_type VARCHAR(50),
    login_id VARCHAR(100) UNIQUE,
    password_hash TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'active', -- active, inactive, suspended, blocked, pending
    is_verified BOOLEAN DEFAULT 1,
    role VARCHAR(20) DEFAULT 'OWNER', -- OWNER, ADMIN
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login_at DATETIME
);

-- 2. Subscription Plans Table
CREATE TABLE IF NOT EXISTS plans (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL, -- Free, Basic, Pro, Premium
    description TEXT,
    price DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'INR',
    billing_cycle VARCHAR(20) DEFAULT 'monthly', -- monthly, yearly
    features TEXT, -- JSON array string
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. Subscriptions Table
CREATE TABLE IF NOT EXISTS subscriptions (
    id VARCHAR(36) PRIMARY KEY,
    shop_id VARCHAR(36) NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    plan_id VARCHAR(36) NOT NULL REFERENCES plans(id),
    plan_name VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'active', -- active, trial, expired, cancelled, paused, past_due
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    renewal_date DATETIME,
    billing_cycle VARCHAR(20) DEFAULT 'monthly',
    amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'INR',
    auto_renew BOOLEAN DEFAULT 1,
    provider VARCHAR(50) DEFAULT 'razorpay',
    provider_subscription_id VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 4. Billing / Subscription Payment History Table
CREATE TABLE IF NOT EXISTS payments (
    id VARCHAR(36) PRIMARY KEY,
    shop_id VARCHAR(36) NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    subscription_id VARCHAR(36) REFERENCES subscriptions(id) ON DELETE SET NULL,
    plan_id VARCHAR(36) REFERENCES plans(id) ON DELETE SET NULL,
    amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'INR',
    payment_method VARCHAR(50) DEFAULT 'UPI', -- UPI, Card, Cash, NetBanking, Other
    provider VARCHAR(50) DEFAULT 'razorpay',
    transaction_id VARCHAR(100),
    provider_payment_id VARCHAR(100),
    status VARCHAR(20) DEFAULT 'successful', -- pending, successful, failed, refunded, cancelled
    paid_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    failure_reason TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_shops_email ON shops(email);
CREATE INDEX IF NOT EXISTS idx_shops_login_id ON shops(login_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_shop ON subscriptions(shop_id);
CREATE INDEX IF NOT EXISTS idx_payments_shop ON payments(shop_id);
CREATE INDEX IF NOT EXISTS idx_payments_subscription ON payments(subscription_id);
