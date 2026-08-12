const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const { db, initDb } = require('../src/db/database');
const userRepository = require('../src/repositories/user_repository');
const businessRepository = require('../src/repositories/business_repository');
const customerRepository = require('../src/repositories/customer_repository');
const crmRepository = require('../src/repositories/crm_repository');
const productRepository = require('../src/repositories/product_repository');
const inventoryRepository = require('../src/repositories/inventory_repository');
const supplierRepository = require('../src/repositories/supplier_repository');
const purchaseRepository = require('../src/repositories/purchase_repository');
const invoiceRepository = require('../src/repositories/invoice_repository');
const paymentRepository = require('../src/repositories/payment_repository');

console.log('🌱 Seeding XenoBiz development database...');

async function seed() {
  initDb();

  // Clear existing records safely
  db.exec(`
    DELETE FROM payments;
    DELETE FROM sales_returns;
    DELETE FROM purchase_returns;
    DELETE FROM invoice_items;
    DELETE FROM invoices;
    DELETE FROM purchase_items;
    DELETE FROM purchases;
    DELETE FROM stock_movements;
    DELETE FROM products;
    DELETE FROM crm_leads;
    DELETE FROM crm_stages;
    DELETE FROM crm_pipelines;
    DELETE FROM customer_interactions;
    DELETE FROM customers;
    DELETE FROM suppliers;
    DELETE FROM user_businesses;
    DELETE FROM businesses;
    DELETE FROM users;
  `);

  const passwordHash = await bcrypt.hash('Demo@12345', 10);
  const adminHash = await bcrypt.hash('Admin@12345', 10);

  // 1. Create Admin Account
  const adminUser = userRepository.create({
    id: 'usr_admin',
    username: 'admin',
    fullName: 'System Administrator',
    email: 'admin@xenobiz.local',
    phone: '+919000000000',
    passwordHash: adminHash,
    role: 'ADMIN',
  });

  // 2. Business 1: NovaTech Electronics
  const demoOwner = userRepository.create({
    id: 'usr_novatech',
    username: 'novatech_owner',
    fullName: 'Rahul Sharma',
    email: 'demo@xenobiz.local',
    phone: '+919847011223',
    passwordHash,
    role: 'OWNER',
  });

  const novaTechBiz = businessRepository.create({
    id: 'biz_novatech',
    name: 'NovaTech Electronics',
    businessType: 'Electronics & Gadgets',
    description: 'Premier retail and wholesale electronics distributor',
    address: 'Suite 402, Tech Park, MG Road',
    city: 'Kochi',
    state: 'Kerala',
    country: 'India',
    zipCode: '682016',
    phone: '+91 98470 11223',
    email: 'contact@novatech.in',
    website: 'https://novatech.local',
    taxNumber: '32AAACN1234F1Z5',
    currency: 'INR',
    invoicePrefix: 'NOV-',
  }, demoOwner.id, 'OWNER');

  // Business 2: GreenLeaf Supermarket
  const greenleafOwner = userRepository.create({
    id: 'usr_greenleaf',
    username: 'greenleaf_owner',
    fullName: 'Anita Roy',
    email: 'greenleaf@xenobiz.local',
    phone: '+919876543210',
    passwordHash,
    role: 'OWNER',
  });

  const greenLeafBiz = businessRepository.create({
    id: 'biz_greenleaf',
    name: 'GreenLeaf Supermarket',
    businessType: 'Retail / Grocery',
    description: 'Fresh organic groceries & household FMCG goods',
    address: 'Plot 12, Main Market Road',
    city: 'Bengaluru',
    state: 'Karnataka',
    country: 'India',
    zipCode: '560001',
    phone: '+91 98765 43210',
    email: 'store@greenleaf.local',
    website: 'https://greenleaf.local',
    taxNumber: '29ABCDE5678G1Z2',
    currency: 'INR',
    invoicePrefix: 'GLS-',
  }, greenleafOwner.id, 'OWNER');

  // Business 3: UrbanCraft Furniture
  const urbancraftOwner = userRepository.create({
    id: 'usr_urbancraft',
    username: 'urbancraft_owner',
    fullName: 'Vikram Mehta',
    email: 'urbancraft@xenobiz.local',
    phone: '+919988776655',
    passwordHash,
    role: 'OWNER',
  });

  const urbanCraftBiz = businessRepository.create({
    id: 'biz_urbancraft',
    name: 'UrbanCraft Furniture',
    businessType: 'Furniture & Interiors',
    description: 'Custom handcrafted wooden furniture and office decor',
    address: '88 Industrial Area Phase 2',
    city: 'Mumbai',
    state: 'Maharashtra',
    country: 'India',
    zipCode: '400013',
    phone: '+91 99887 76655',
    email: 'info@urbancraft.local',
    website: 'https://urbancraft.local',
    taxNumber: '27XYZAB9876H1Z9',
    currency: 'INR',
    invoicePrefix: 'UCF-',
  }, urbancraftOwner.id, 'OWNER');

  console.log('✅ Created Demo Users & Businesses');

  // Seed Data Generator Helper for Businesses
  async function seedBusinessData(biz, ownerId, categories, productTemplates, supplierTemplates, customerNames) {
    const bizId = biz.id;

    // 1. Suppliers
    const suppliers = [];
    for (let i = 0; i < supplierTemplates.length; i++) {
      const sTemp = supplierTemplates[i];
      const supp = supplierRepository.create({
        id: `supp_${bizId}_${i + 1}`,
        businessId: bizId,
        name: sTemp.name,
        company: sTemp.company,
        phone: `+91 98${Math.floor(10000000 + Math.random() * 90000000)}`,
        email: `supplier${i + 1}@${sTemp.company.toLowerCase().replace(/\s+/g, '')}.com`,
        address: `${i * 10 + 5} Logistics Hub, Industrial Zone`,
        taxNumber: `32SUPP${i + 1}00${i}F1Z${i}`,
        outstandingPayable: Math.floor(Math.random() * 25000),
      });
      suppliers.push(supp);
    }

    // 2. Products
    const products = [];
    for (let i = 0; i < productTemplates.length; i++) {
      const pTemp = productTemplates[i];
      const prod = productRepository.create({
        id: `prod_${bizId}_${i + 1}`,
        businessId: bizId,
        name: pTemp.name,
        sku: `${biz.invoicePrefix}SKU-${100 + i}`,
        barcode: `8901234567${100 + i}`,
        description: `High quality ${pTemp.name} for ${biz.name}`,
        category: pTemp.category,
        unit: pTemp.unit || 'pcs',
        purchasePrice: pTemp.cost,
        sellingPrice: pTemp.price,
        taxPercentage: pTemp.tax || 18.0,
        minStockLevel: pTemp.minStock || 5,
        currentStock: pTemp.stock || 25,
      });
      products.push(prod);

      // Record Opening Stock
      inventoryRepository.recordMovement({
        id: `mov_${bizId}_open_${i + 1}`,
        businessId: bizId,
        productId: prod.id,
        quantity: prod.current_stock,
        movementType: 'Opening Stock',
        referenceDocument: 'SEED_INITIAL',
        reason: 'Initial setup opening stock',
        userId: ownerId,
      });
    }

    // 3. Customers
    const customers = [];
    for (let i = 0; i < customerNames.length; i++) {
      const cName = customerNames[i];
      const cust = customerRepository.create({
        id: `cust_${bizId}_${i + 1}`,
        businessId: bizId,
        name: cName,
        phone: `+91 97${Math.floor(10000000 + Math.random() * 90000000)}`,
        email: `${cName.toLowerCase().replace(/\s+/g, '.')}@example.com`,
        address: `${i + 1} Residential Avenue, Sector ${i % 10 + 1}`,
        company: i % 3 === 0 ? `${cName} Enterprise` : null,
        customerType: i % 5 === 0 ? 'VIP' : i % 3 === 0 ? 'Wholesale' : 'Regular',
        creditLimit: i % 3 === 0 ? 50000 : 15000,
        createdBy: ownerId,
      });
      customers.push(cust);
    }

    // 4. CRM Pipeline & Leads
    const pipeId = `pipe_${bizId}`;
    const pipeline = crmRepository.createPipeline({
      id: pipeId,
      businessId: bizId,
      name: `${biz.name} Pipeline`,
      isDefault: 1,
    });

    const stages = [
      crmRepository.createStage({ id: `stg_${bizId}_1`, pipelineId: pipeId, name: 'New Lead', stageOrder: 1, color: '#3B82F6' }),
      crmRepository.createStage({ id: `stg_${bizId}_2`, pipelineId: pipeId, name: 'Contacted', stageOrder: 2, color: '#8B5CF6' }),
      crmRepository.createStage({ id: `stg_${bizId}_3`, pipelineId: pipeId, name: 'Qualified', stageOrder: 3, color: '#EC4899' }),
      crmRepository.createStage({ id: `stg_${bizId}_4`, pipelineId: pipeId, name: 'Proposal', stageOrder: 4, color: '#F59E0B' }),
      crmRepository.createStage({ id: `stg_${bizId}_5`, pipelineId: pipeId, name: 'Negotiation', stageOrder: 5, color: '#10B981' }),
      crmRepository.createStage({ id: `stg_${bizId}_6`, pipelineId: pipeId, name: 'Won', stageOrder: 6, color: '#059669' }),
    ];

    for (let i = 0; i < 8; i++) {
      const cust = customers[i % customers.length];
      const stage = stages[i % stages.length];
      crmRepository.createLead({
        id: `lead_${bizId}_${i + 1}`,
        businessId: bizId,
        pipelineId: pipeId,
        stageId: stage.id,
        customerId: cust.id,
        title: `Opportunity: Bulk Order for ${cust.name}`,
        contactName: cust.name,
        contactPhone: cust.phone,
        contactEmail: cust.email,
        leadValue: (i + 1) * 15000,
        status: stage.name === 'Won' ? 'won' : 'open',
        priority: i % 2 === 0 ? 'high' : 'medium',
        assignedUserId: ownerId,
        notes: 'Customer interested in commercial bulk purchase',
        createdBy: ownerId,
      });
    }

    // 5. Purchases & Invoices (Generate historical transactions across past 60 days)
    const now = new Date();
    for (let day = 60; day >= 0; day -= 2) {
      const txDate = new Date(now.getTime() - day * 24 * 60 * 60 * 1000).toISOString();

      // Purchase Order every 6 days
      if (day % 6 === 0 && suppliers.length > 0) {
        const supp = suppliers[day % suppliers.length];
        const p1 = products[day % products.length];
        const p2 = products[(day + 1) % products.length];

        const item1Qty = 10;
        const item1Total = item1Qty * p1.purchase_price;
        const item2Qty = 5;
        const item2Total = item2Qty * p2.purchase_price;

        const grandTotal = item1Total + item2Total;
        const paid = day % 12 === 0 ? grandTotal : grandTotal * 0.5;
        const due = grandTotal - paid;

        const purId = `pur_${bizId}_day${day}`;
        purchaseRepository.create({
          id: purId,
          businessId: bizId,
          supplierId: supp.id,
          invoiceNumber: `PO-${biz.invoicePrefix}${200 + day}`,
          purchaseDate: txDate,
          subtotal: grandTotal,
          grandTotal: grandTotal,
          paidAmount: paid,
          dueAmount: due,
          paymentStatus: due === 0 ? 'paid' : paid > 0 ? 'partially_paid' : 'unpaid',
          paymentMethod: 'Bank Transfer',
          createdBy: ownerId,
        }, [
          { id: `pitm_${purId}_1`, productId: p1.id, productName: p1.name, quantity: item1Qty, purchasePrice: p1.purchase_price, total: item1Total },
          { id: `pitm_${purId}_2`, productId: p2.id, productName: p2.name, quantity: item2Qty, purchasePrice: p2.purchase_price, total: item2Total },
        ]);
      }

      // Sales Invoice every 2 days
      const cust = customers[day % customers.length];
      const prod1 = products[day % products.length];
      const prod2 = products[(day + 2) % products.length];

      const q1 = Math.floor(1 + Math.random() * 3);
      const t1 = q1 * prod1.selling_price;
      const q2 = 1;
      const t2 = q2 * prod2.selling_price;

      const grandTotal = t1 + t2;
      const isPaid = day % 4 !== 0; // some unpaid/partially paid edge cases
      const paidAmount = isPaid ? grandTotal : (day % 8 === 0 ? 0 : grandTotal * 0.4);
      const dueAmount = grandTotal - paidAmount;

      const invId = `inv_${bizId}_day${day}`;
      invoiceRepository.create({
        id: invId,
        businessId: bizId,
        invoiceNumber: `${biz.invoicePrefix}${1000 + day}`,
        customerId: cust.id,
        customerName: cust.name,
        issueDate: txDate,
        dueDate: new Date(now.getTime() - (day - 14) * 24 * 60 * 60 * 1000).toISOString(),
        subtotal: grandTotal,
        grandTotal: grandTotal,
        paidAmount: paidAmount,
        dueAmount: dueAmount,
        paymentStatus: dueAmount <= 0 ? 'paid' : paidAmount > 0 ? 'partially_paid' : 'unpaid',
        paymentMethod: day % 3 === 0 ? 'UPI' : day % 5 === 0 ? 'Card' : 'Cash',
        createdBy: ownerId,
      }, [
        { id: `iitm_${invId}_1`, productId: prod1.id, productName: prod1.name, quantity: q1, unitPrice: prod1.selling_price, total: t1 },
        { id: `iitm_${invId}_2`, productId: prod2.id, productName: prod2.name, quantity: q2, unitPrice: prod2.selling_price, total: t2 },
      ]);

      // Deduct stock for sale
      productRepository.updateStock(prod1.id, bizId, -q1);
      productRepository.updateStock(prod2.id, bizId, -q2);

      // Record Customer Balances
      customerRepository.updateBalances(cust.id, bizId, grandTotal, paidAmount);

      // Payment Entry if paid > 0
      if (paidAmount > 0) {
        paymentRepository.create({
          id: `pay_${invId}`,
          businessId: bizId,
          invoiceId: invId,
          customerId: cust.id,
          amount: paidAmount,
          paymentMethod: 'UPI',
          paymentType: 'IN',
          paymentStatus: 'completed',
          paymentDate: txDate,
          createdBy: ownerId,
        });
      }
    }
  }

  // Seed NovaTech Electronics
  await seedBusinessData(
    novaTechBiz,
    demoOwner.id,
    ['Laptops', 'Smartphones', 'Audio', 'Accessories'],
    [
      { name: 'MacBook Pro 14"', category: 'Laptops', cost: 140000, price: 169900, stock: 12, minStock: 3 },
      { name: 'iPhone 15 Pro 256GB', category: 'Smartphones', cost: 110000, price: 134900, stock: 18, minStock: 5 },
      { name: 'Sony WH-1000XM5 Headphones', category: 'Audio', cost: 22000, price: 29990, stock: 2, minStock: 5 }, // Low stock
      { name: 'Samsung Galaxy S24 Ultra', category: 'Smartphones', cost: 105000, price: 129999, stock: 8, minStock: 3 },
      { name: 'Dell XPS 15 Laptop', category: 'Laptops', cost: 125000, price: 149990, stock: 4, minStock: 2 },
      { name: 'iPad Air M2', category: 'Tablets', cost: 48000, price: 59900, stock: 15, minStock: 4 },
      { name: 'Logitech MX Master 3S Mouse', category: 'Accessories', cost: 6500, price: 8995, stock: 30, minStock: 8 },
      { name: 'Anker 65W GaN Charger', category: 'Accessories', cost: 1800, price: 2999, stock: 3, minStock: 10 }, // Low stock
      { name: 'LG UltraGear 27" Gaming Monitor', category: 'Monitors', cost: 24000, price: 32990, stock: 6, minStock: 3 },
      { name: 'Keychron K2 Mechanical Keyboard', category: 'Accessories', cost: 6000, price: 8499, stock: 14, minStock: 4 },
    ],
    [
      { name: 'Apple India Distributors', company: 'Redington India Pvt Ltd' },
      { name: 'Samsung Mobile Hub', company: 'Ingram Micro India' },
      { name: 'Sony Electronics Corp', company: 'Sony India Wholesale' },
      { name: 'Dell Commercial Partners', company: 'Neoteric Infomedia' },
    ],
    [
      'Arun Kumar', 'Priya Nair', 'CyberTech Solutions', 'Kiran Varghese',
      'Infensys Systems', 'Deepak Pillai', 'Sanjana Ramesh', 'Apex Media Works',
      'Gokul Das', 'Meera Krishnan', 'Zenith Software', 'Vivek Menon'
    ]
  );

  // Seed GreenLeaf Supermarket
  await seedBusinessData(
    greenLeafBiz,
    greenleafOwner.id,
    ['Groceries', 'Dairy', 'Snacks', 'Beverages'],
    [
      { name: 'Organic Basmati Rice 5kg', category: 'Groceries', cost: 450, price: 599, stock: 50, minStock: 15 },
      { name: 'Amul Butter 500g', category: 'Dairy', cost: 230, price: 275, stock: 4, minStock: 10 }, // Low stock
      { name: 'Fortune Sunlite Oil 1L', category: 'Groceries', cost: 120, price: 145, stock: 60, minStock: 20 },
      { name: 'Aashirvaad Whole Wheat Atta 10kg', category: 'Groceries', cost: 380, price: 460, stock: 2, minStock: 8 }, // Low stock
      { name: 'Tropicana Orange Juice 1L', category: 'Beverages', cost: 85, price: 120, stock: 24, minStock: 6 },
      { name: 'Nestle Everyday Milk Powder 1kg', category: 'Dairy', cost: 480, price: 580, stock: 18, minStock: 5 },
      { name: 'Cadbury Celebrations Pack', category: 'Snacks', cost: 160, price: 220, stock: 40, minStock: 10 },
      { name: 'Lays Potato Chips Family Pack', category: 'Snacks', cost: 25, price: 35, stock: 80, minStock: 25 },
    ],
    [
      { name: 'Kerala FMCG Distributors', company: 'Southern Wholesale Trading' },
      { name: 'Amul Dairy Co-op', company: 'Gujarat Cooperative Milk' },
      { name: 'ITC Agro Products', company: 'ITC Limited' },
    ],
    [
      'Lakshmi Amma', 'Sunil Dutt', 'Tasty Bites Cafe', 'Geetha Sundaram',
      'Bhavana Reddy', 'Rohan Kapoor', 'Daily Fresh Caterers'
    ]
  );

  // Seed UrbanCraft Furniture
  await seedBusinessData(
    urbanCraftBiz,
    urbancraftOwner.id,
    ['Seating', 'Tables', 'Beds', 'Office Decor'],
    [
      { name: 'Ergonomic Mesh Office Chair', category: 'Seating', cost: 6500, price: 11990, stock: 15, minStock: 5 },
      { name: 'Solid Teak Dining Table (6 Seater)', category: 'Tables', cost: 28000, price: 45000, stock: 3, minStock: 2 },
      { name: 'King Size Sheesham Wood Bed', category: 'Beds', cost: 22000, price: 36990, stock: 5, minStock: 2 },
      { name: 'Velvet 3-Seater Sofa Set', category: 'Seating', cost: 18000, price: 29900, stock: 1, minStock: 3 }, // Low stock
      { name: 'Minimalist Study Desk', category: 'Tables', cost: 4200, price: 7990, stock: 20, minStock: 5 },
    ],
    [
      { name: 'Karnataka Timber Works', company: 'Deccan Wood Suppliers' },
      { name: 'Steel & Mesh Hardware Corp', company: 'Godrej Hardware Wholesale' },
    ],
    [
      'DesignStudio Architect', 'Siddharth Rao', 'Skyline Infra', 'Nisha Agarwal', 'Preeti Sharma'
    ]
  );

  console.log('✅ Seeding completed successfully!');
  console.log('--------------------------------------------------');
  console.log('Demo Credentials Ready:');
  console.log('1) Business 1 (Electronics): demo@xenobiz.local / Demo@12345');
  console.log('2) Business 2 (Grocery):     greenleaf@xenobiz.local / Demo@12345');
  console.log('3) Business 3 (Furniture):   urbancraft@xenobiz.local / Demo@12345');
  console.log('4) Admin Account:            admin@xenobiz.local / Admin@12345');
  console.log('--------------------------------------------------');
}

seed().catch((err) => {
  console.error('❌ Seeding failed:', err);
  process.exit(1);
});
