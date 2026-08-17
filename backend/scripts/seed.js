const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const { db, initDb } = require('../src/db/database');
const shopRepository = require('../src/repositories/shop_repository');
const planRepository = require('../src/repositories/plan_repository');
const subscriptionRepository = require('../src/repositories/subscription_repository');
const billingPaymentRepository = require('../src/repositories/billing_payment_repository');

console.log('🌱 Seeding XenoBiz Shop/Admin & Subscription database...');

async function seed() {
  initDb();

  // Clear existing records safely
  db.exec(`
    DELETE FROM payments;
    DELETE FROM subscriptions;
    DELETE FROM plans;
    DELETE FROM shops;
  `);

  const passwordHash = await bcrypt.hash('Demo@12345', 10);
  const adminHash = await bcrypt.hash('admin', 10);

  // 1. Seed Subscription Plans
  const plans = [
    planRepository.create({
      id: 'plan_free',
      name: 'Free',
      description: 'Essential starter plan with basic invoicing and inventory tracking.',
      price: 0.0,
      currency: 'INR',
      billingCycle: 'monthly',
      features: ['Basic Invoicing', 'Up to 50 Products', 'Single User Access', '14-Day Free Access'],
      isActive: 1,
    }),
    planRepository.create({
      id: 'plan_basic',
      name: 'Basic',
      description: 'Standard plan for growing retail shops and small businesses.',
      price: 499.0,
      currency: 'INR',
      billingCycle: 'monthly',
      features: ['Unlimited Invoices', 'Unlimited Products', 'Customer Due Tracking', 'WhatsApp Sharing'],
      isActive: 1,
    }),
    planRepository.create({
      id: 'plan_pro',
      name: 'Pro',
      description: 'Professional suite with advanced analytics, multi-user, and CRM.',
      price: 999.0,
      currency: 'INR',
      billingCycle: 'monthly',
      features: ['All Basic Features', 'Advanced POS Reports', 'Tax/GST Export', 'Priority Support'],
      isActive: 1,
    }),
    planRepository.create({
      id: 'plan_premium',
      name: 'Premium',
      description: 'Enterprise solution for multi-outlet businesses and franchises.',
      price: 2499.0,
      currency: 'INR',
      billingCycle: 'yearly',
      features: ['All Pro Features', 'Multi-Store Sync', 'Custom Domain', 'Dedicated Account Manager'],
      isActive: 1,
    }),
  ];
  console.log(`✅ Created ${plans.length} Subscription Plans`);

  // 2. Create System Admin Account
  const adminShop = shopRepository.create({
    id: 'shop_admin',
    shopName: 'XenoBiz Admin System',
    ownerName: 'System Administrator',
    email: 'admin@xenobiz.local',
    phone: '+919000000000',
    loginId: 'admin',
    passwordHash: adminHash,
    role: 'ADMIN',
    status: 'active',
  });
  console.log('✅ Created System Administrator Account (admin / admin@xenobiz.local)');

  // 3. Shop 1: NovaTech Electronics
  const shop1 = shopRepository.create({
    id: 'shop_novatech',
    shopName: 'NovaTech Electronics',
    ownerName: 'Rahul Sharma',
    email: 'demo@xenobiz.local',
    phone: '+91 98470 11223',
    address: 'Suite 402, Tech Park, MG Road',
    city: 'Kochi',
    state: 'Kerala',
    country: 'India',
    postalCode: '682016',
    gstNumber: '32AAACN1234F1Z5',
    businessType: 'Electronics & Gadgets',
    loginId: 'novatech_owner',
    passwordHash,
    status: 'active',
    role: 'OWNER',
  });

  // Shop 2: GreenLeaf Supermarket
  const shop2 = shopRepository.create({
    id: 'shop_greenleaf',
    shopName: 'GreenLeaf Supermarket',
    ownerName: 'Anita Roy',
    email: 'greenleaf@xenobiz.local',
    phone: '+91 98765 43210',
    address: 'Plot 12, Main Market Road',
    city: 'Bengaluru',
    state: 'Karnataka',
    country: 'India',
    postalCode: '560001',
    gstNumber: '29ABCDE5678G1Z2',
    businessType: 'Retail / Grocery',
    loginId: 'greenleaf_owner',
    passwordHash,
    status: 'active',
    role: 'OWNER',
  });

  // Shop 3: UrbanCraft Furniture
  const shop3 = shopRepository.create({
    id: 'shop_urbancraft',
    shopName: 'UrbanCraft Furniture',
    ownerName: 'Vikram Mehta',
    email: 'urbancraft@xenobiz.local',
    phone: '+91 99887 76655',
    address: '88 Industrial Area Phase 2',
    city: 'Mumbai',
    state: 'Maharashtra',
    country: 'India',
    postalCode: '400013',
    gstNumber: '27XYZAB9876H1Z9',
    businessType: 'Furniture & Interiors',
    loginId: 'urbancraft_owner',
    passwordHash,
    status: 'active',
    role: 'OWNER',
  });
  console.log('✅ Created 3 Registered Shop Accounts');

  // 4. Seed Subscriptions & Billing Payment History
  const now = new Date();
  const thirtyDaysLater = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

  // NovaTech Electronics -> Pro Plan (Paid)
  const sub1 = subscriptionRepository.create({
    id: 'sub_novatech_pro',
    shopId: shop1.id,
    planId: 'plan_pro',
    planName: 'Pro',
    status: 'active',
    startDate: new Date(now.getTime() - 60 * 24 * 60 * 60 * 1000).toISOString(),
    endDate: thirtyDaysLater.toISOString(),
    renewalDate: thirtyDaysLater.toISOString(),
    billingCycle: 'monthly',
    amount: 999.0,
    currency: 'INR',
    autoRenew: 1,
    provider: 'razorpay',
  });

  // Payments for NovaTech
  billingPaymentRepository.create({
    id: 'pay_nova_1',
    shopId: shop1.id,
    subscriptionId: sub1.id,
    planId: 'plan_pro',
    amount: 999.0,
    currency: 'INR',
    paymentMethod: 'UPI',
    provider: 'razorpay',
    transactionId: 'TXN_NOVA_AUG2026',
    status: 'successful',
    paidAt: new Date(now.getTime() - 1 * 24 * 60 * 60 * 1000).toISOString(),
  });

  billingPaymentRepository.create({
    id: 'pay_nova_2',
    shopId: shop1.id,
    subscriptionId: sub1.id,
    planId: 'plan_pro',
    amount: 999.0,
    currency: 'INR',
    paymentMethod: 'UPI',
    provider: 'razorpay',
    transactionId: 'TXN_NOVA_JUL2026',
    status: 'successful',
    paidAt: new Date(now.getTime() - 31 * 24 * 60 * 60 * 1000).toISOString(),
  });

  // GreenLeaf Supermarket -> Basic Plan (Paid)
  const sub2 = subscriptionRepository.create({
    id: 'sub_greenleaf_basic',
    shopId: shop2.id,
    planId: 'plan_basic',
    planName: 'Basic',
    status: 'active',
    startDate: new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000).toISOString(),
    endDate: thirtyDaysLater.toISOString(),
    renewalDate: thirtyDaysLater.toISOString(),
    billingCycle: 'monthly',
    amount: 499.0,
    currency: 'INR',
    autoRenew: 1,
    provider: 'razorpay',
  });

  billingPaymentRepository.create({
    id: 'pay_green_1',
    shopId: shop2.id,
    subscriptionId: sub2.id,
    planId: 'plan_basic',
    amount: 499.0,
    currency: 'INR',
    paymentMethod: 'Card',
    provider: 'razorpay',
    transactionId: 'TXN_GREEN_AUG2026',
    status: 'successful',
    paidAt: new Date(now.getTime() - 10 * 24 * 60 * 60 * 1000).toISOString(),
  });

  // UrbanCraft Furniture -> Free Trial
  subscriptionRepository.create({
    id: 'sub_urbancraft_free',
    shopId: shop3.id,
    planId: 'plan_free',
    planName: 'Free',
    status: 'trial',
    startDate: now.toISOString(),
    endDate: new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000).toISOString(),
    renewalDate: new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000).toISOString(),
    billingCycle: 'monthly',
    amount: 0.0,
    currency: 'INR',
    autoRenew: 1,
    provider: 'system',
  });

  console.log('✅ Created Active Subscriptions & Billing Payment History');

  console.log('✅ Seeding completed successfully!');
  console.log('--------------------------------------------------');
  console.log('Development Credentials Ready:');
  console.log('1) Shop 1 (Electronics): demo@xenobiz.local / Demo@12345');
  console.log('2) Shop 2 (Grocery):     greenleaf@xenobiz.local / Demo@12345');
  console.log('3) Shop 3 (Furniture):   urbancraft@xenobiz.local / Demo@12345');
  console.log('4) Admin Account:        admin@xenobiz.local / admin');
  console.log('--------------------------------------------------');
}

seed().catch((err) => {
  console.error('❌ Seeding failed:', err);
  process.exit(1);
});
