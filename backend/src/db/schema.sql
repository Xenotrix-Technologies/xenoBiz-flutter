-- ============================================================
-- XenoBiz PostgreSQL Database Schema
-- Shop/Admin Account & Subscription Billing
-- ============================================================

-- ============================================================
-- 1. SHOPS / ADMIN ACCOUNTS
-- ============================================================

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

    status VARCHAR(20) DEFAULT 'active',
    is_verified BOOLEAN DEFAULT TRUE,

    role VARCHAR(20) DEFAULT 'OWNER',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP
);


-- ============================================================
-- 2. SUBSCRIPTION PLANS
-- ============================================================

CREATE TABLE IF NOT EXISTS plans (
    id VARCHAR(36) PRIMARY KEY,

    name VARCHAR(100) NOT NULL,
    description TEXT,

    price DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'INR',

    billing_cycle VARCHAR(20) DEFAULT 'monthly',

    features JSONB DEFAULT '[]'::jsonb,

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 3. SUBSCRIPTIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS subscriptions (
    id VARCHAR(36) PRIMARY KEY,

    shop_id VARCHAR(36) NOT NULL,
    plan_id VARCHAR(36) NOT NULL,

    plan_name VARCHAR(100) NOT NULL,

    status VARCHAR(20) DEFAULT 'active',

    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    renewal_date TIMESTAMP,

    billing_cycle VARCHAR(20) DEFAULT 'monthly',

    amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'INR',

    auto_renew BOOLEAN DEFAULT TRUE,

    provider VARCHAR(50) DEFAULT 'razorpay',
    provider_subscription_id VARCHAR(100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_subscription_shop
        FOREIGN KEY (shop_id)
        REFERENCES shops(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_subscription_plan
        FOREIGN KEY (plan_id)
        REFERENCES plans(id)
);


-- ============================================================
-- 4. PAYMENT HISTORY
-- ============================================================

CREATE TABLE IF NOT EXISTS payments (
    id VARCHAR(36) PRIMARY KEY,

    shop_id VARCHAR(36) NOT NULL,

    subscription_id VARCHAR(36),
    plan_id VARCHAR(36),

    amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'INR',

    payment_method VARCHAR(50) DEFAULT 'UPI',

    provider VARCHAR(50) DEFAULT 'razorpay',

    transaction_id VARCHAR(100),
    provider_payment_id VARCHAR(100),

    status VARCHAR(20) DEFAULT 'successful',

    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    failure_reason TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_payment_shop
        FOREIGN KEY (shop_id)
        REFERENCES shops(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_payment_subscription
        FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_payment_plan
        FOREIGN KEY (plan_id)
        REFERENCES plans(id)
        ON DELETE SET NULL
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_shops_email
    ON shops(email);

CREATE INDEX IF NOT EXISTS idx_shops_login_id
    ON shops(login_id);

CREATE INDEX IF NOT EXISTS idx_subscriptions_shop
    ON subscriptions(shop_id);

CREATE INDEX IF NOT EXISTS idx_subscriptions_plan
    ON subscriptions(plan_id);

CREATE INDEX IF NOT EXISTS idx_payments_shop
    ON payments(shop_id);

CREATE INDEX IF NOT EXISTS idx_payments_subscription
    ON payments(subscription_id);

CREATE INDEX IF NOT EXISTS idx_payments_plan
    ON payments(plan_id);

CREATE INDEX IF NOT EXISTS idx_payments_transaction
    ON payments(transaction_id);