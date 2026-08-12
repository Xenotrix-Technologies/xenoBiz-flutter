-- XenoBiz Core Database Schema (SQLite implementation)
-- Designed to be 1:1 compatible with production relational databases (PostgreSQL/MySQL)

PRAGMA foreign_keys = ON;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    username VARCHAR(100) UNIQUE,
    full_name VARCHAR(150),
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(50),
    password_hash TEXT NOT NULL,
    profile_image TEXT,
    role VARCHAR(20) DEFAULT 'OWNER',
    account_status VARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME
);

-- 2. Businesses Table
CREATE TABLE IF NOT EXISTS businesses (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    business_type VARCHAR(50),
    description TEXT,
    logo TEXT,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'India',
    zip_code VARCHAR(20),
    phone VARCHAR(50),
    email VARCHAR(150),
    website VARCHAR(150),
    tax_number VARCHAR(50),
    currency VARCHAR(10) DEFAULT 'INR',
    invoice_prefix VARCHAR(20) DEFAULT 'INV-',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. User-Businesses Junction Table (Supports multi-user businesses)
CREATE TABLE IF NOT EXISTS user_businesses (
    user_id VARCHAR(36) REFERENCES users(id) ON DELETE CASCADE,
    business_id VARCHAR(36) REFERENCES businesses(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'OWNER',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, business_id)
);

-- 4. Customers Table
CREATE TABLE IF NOT EXISTS customers (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    phone VARCHAR(50),
    email VARCHAR(150),
    address TEXT,
    company VARCHAR(150),
    customer_type VARCHAR(50) DEFAULT 'Regular',
    notes TEXT,
    total_purchases DECIMAL(12,2) DEFAULT 0.00,
    total_paid DECIMAL(12,2) DEFAULT 0.00,
    outstanding_balance DECIMAL(12,2) DEFAULT 0.00,
    credit_limit DECIMAL(12,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(36)
);

-- 5. Customer Interactions / Notes
CREATE TABLE IF NOT EXISTS customer_interactions (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    customer_id VARCHAR(36) NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    type VARCHAR(50) DEFAULT 'Note',
    notes TEXT NOT NULL,
    user_id VARCHAR(36),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 6. CRM Pipelines
CREATE TABLE IF NOT EXISTS crm_pipelines (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 7. CRM Stages
CREATE TABLE IF NOT EXISTS crm_stages (
    id VARCHAR(36) PRIMARY KEY,
    pipeline_id VARCHAR(36) NOT NULL REFERENCES crm_pipelines(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    stage_order INTEGER NOT NULL,
    color VARCHAR(20) DEFAULT '#2563EB',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 8. CRM Leads / Opportunities
CREATE TABLE IF NOT EXISTS crm_leads (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    pipeline_id VARCHAR(36) REFERENCES crm_pipelines(id) ON DELETE SET NULL,
    stage_id VARCHAR(36) REFERENCES crm_stages(id) ON DELETE SET NULL,
    customer_id VARCHAR(36) REFERENCES customers(id) ON DELETE SET NULL,
    title VARCHAR(150) NOT NULL,
    contact_name VARCHAR(150),
    contact_phone VARCHAR(50),
    contact_email VARCHAR(150),
    lead_value DECIMAL(12,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'open',
    priority VARCHAR(20) DEFAULT 'medium',
    assigned_user_id VARCHAR(36),
    expected_closing_date DATE,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(36)
);

-- 9. Products Table
CREATE TABLE IF NOT EXISTS products (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    sku VARCHAR(50),
    barcode VARCHAR(50),
    description TEXT,
    category VARCHAR(100),
    brand VARCHAR(100),
    unit VARCHAR(20) DEFAULT 'pcs',
    purchase_price DECIMAL(12,2) DEFAULT 0.00,
    selling_price DECIMAL(12,2) DEFAULT 0.00,
    tax_percentage DECIMAL(5,2) DEFAULT 0.00,
    min_stock_level INTEGER DEFAULT 5,
    current_stock INTEGER DEFAULT 0,
    image_url TEXT,
    status VARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 10. Inventory / Stock Movements Audit Trail
CREATE TABLE IF NOT EXISTS stock_movements (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    product_id VARCHAR(36) NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL,
    movement_type VARCHAR(50) NOT NULL,
    reference_document VARCHAR(100),
    reason TEXT,
    user_id VARCHAR(36),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 11. Suppliers Table
CREATE TABLE IF NOT EXISTS suppliers (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    company VARCHAR(150),
    phone VARCHAR(50),
    email VARCHAR(150),
    address TEXT,
    tax_number VARCHAR(50),
    notes TEXT,
    outstanding_payable DECIMAL(12,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 12. Purchases Table
CREATE TABLE IF NOT EXISTS purchases (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    supplier_id VARCHAR(36) REFERENCES suppliers(id) ON DELETE SET NULL,
    invoice_number VARCHAR(100),
    purchase_date DATETIME NOT NULL,
    subtotal DECIMAL(12,2) DEFAULT 0.00,
    discount DECIMAL(12,2) DEFAULT 0.00,
    tax_amount DECIMAL(12,2) DEFAULT 0.00,
    other_charges DECIMAL(12,2) DEFAULT 0.00,
    grand_total DECIMAL(12,2) DEFAULT 0.00,
    paid_amount DECIMAL(12,2) DEFAULT 0.00,
    due_amount DECIMAL(12,2) DEFAULT 0.00,
    payment_status VARCHAR(20) DEFAULT 'unpaid',
    payment_method VARCHAR(50) DEFAULT 'Cash',
    status VARCHAR(20) DEFAULT 'active',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(36)
);

-- 13. Purchase Items Table
CREATE TABLE IF NOT EXISTS purchase_items (
    id VARCHAR(36) PRIMARY KEY,
    purchase_id VARCHAR(36) NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
    product_id VARCHAR(36) REFERENCES products(id) ON DELETE SET NULL,
    product_name VARCHAR(150) NOT NULL,
    quantity INTEGER NOT NULL,
    purchase_price DECIMAL(12,2) NOT NULL,
    tax DECIMAL(12,2) DEFAULT 0.00,
    discount DECIMAL(12,2) DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL
);

-- 14. Invoices / Sales Table
CREATE TABLE IF NOT EXISTS invoices (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    invoice_number VARCHAR(50) NOT NULL,
    customer_id VARCHAR(36) REFERENCES customers(id) ON DELETE SET NULL,
    customer_name VARCHAR(150),
    issue_date DATETIME NOT NULL,
    due_date DATETIME,
    subtotal DECIMAL(12,2) DEFAULT 0.00,
    discount DECIMAL(12,2) DEFAULT 0.00,
    tax_amount DECIMAL(12,2) DEFAULT 0.00,
    other_charges DECIMAL(12,2) DEFAULT 0.00,
    grand_total DECIMAL(12,2) DEFAULT 0.00,
    paid_amount DECIMAL(12,2) DEFAULT 0.00,
    due_amount DECIMAL(12,2) DEFAULT 0.00,
    payment_status VARCHAR(20) DEFAULT 'unpaid',
    payment_method VARCHAR(50) DEFAULT 'Cash',
    status VARCHAR(20) DEFAULT 'active',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(36)
);

-- 15. Invoice Items Table (Snapshot of product name & price)
CREATE TABLE IF NOT EXISTS invoice_items (
    id VARCHAR(36) PRIMARY KEY,
    invoice_id VARCHAR(36) NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    product_id VARCHAR(36) REFERENCES products(id) ON DELETE SET NULL,
    product_name VARCHAR(150) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    discount DECIMAL(12,2) DEFAULT 0.00,
    tax DECIMAL(12,2) DEFAULT 0.00,
    total DECIMAL(12,2) NOT NULL
);

-- 16. Payments Table
CREATE TABLE IF NOT EXISTS payments (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    invoice_id VARCHAR(36) REFERENCES invoices(id) ON DELETE SET NULL,
    purchase_id VARCHAR(36) REFERENCES purchases(id) ON DELETE SET NULL,
    customer_id VARCHAR(36) REFERENCES customers(id) ON DELETE SET NULL,
    supplier_id VARCHAR(36) REFERENCES suppliers(id) ON DELETE SET NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_type VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'completed',
    transaction_reference VARCHAR(100),
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(36)
);

-- 17. Sales Returns Table
CREATE TABLE IF NOT EXISTS sales_returns (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    invoice_id VARCHAR(36) REFERENCES invoices(id) ON DELETE SET NULL,
    customer_id VARCHAR(36) REFERENCES customers(id) ON DELETE SET NULL,
    product_id VARCHAR(36) REFERENCES products(id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL,
    refund_amount DECIMAL(12,2) NOT NULL,
    reason TEXT,
    return_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(36)
);

-- 18. Purchase Returns Table
CREATE TABLE IF NOT EXISTS purchase_returns (
    id VARCHAR(36) PRIMARY KEY,
    business_id VARCHAR(36) NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    purchase_id VARCHAR(36) REFERENCES purchases(id) ON DELETE SET NULL,
    supplier_id VARCHAR(36) REFERENCES suppliers(id) ON DELETE SET NULL,
    product_id VARCHAR(36) REFERENCES products(id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL,
    return_amount DECIMAL(12,2) NOT NULL,
    reason TEXT,
    return_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(36)
);

-- Performance Indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_customers_business ON customers(business_id);
CREATE INDEX IF NOT EXISTS idx_products_business ON products(business_id);
CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);
CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode);
CREATE INDEX IF NOT EXISTS idx_invoices_business ON invoices(business_id);
CREATE INDEX IF NOT EXISTS idx_invoices_number ON invoices(invoice_number);
CREATE INDEX IF NOT EXISTS idx_purchases_business ON purchases(business_id);
CREATE INDEX IF NOT EXISTS idx_payments_business ON payments(business_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_product ON stock_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_crm_leads_business ON crm_leads(business_id);
