const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const env = require('../config/env');
const shopRepository = require('../repositories/shop_repository');
const subscriptionRepository = require('../repositories/subscription_repository');
const planRepository = require('../repositories/plan_repository');

class AuthService {
  async register({
    shopName,
    ownerName,
    email,
    phone,
    loginId,
    username,
    fullName,
    password,
    address,
    city,
    state,
    country,
    postalCode,
    gstNumber,
    businessType,
    role = 'OWNER',
  }) {
    const cleanLoginId = (loginId || username || (email && email.includes('@') ? email.split('@')[0] : phone) || `merchant_${uuidv4().substring(0, 6)}`).trim().toLowerCase();
    const cleanEmail = (email || (phone ? `${phone}@xenobiz.local` : `${cleanLoginId}@xenobiz.local`)).trim().toLowerCase();
    const cleanPassword = (password || '').trim();
    const cleanShopName = (shopName || 'New Shop').trim();
    const cleanOwnerName = (ownerName || fullName || username || 'Shop Owner').trim();

    if (!cleanEmail || !cleanPassword) {
      throw { statusCode: 400, message: 'Email/Username and password are required.' };
    }

    const existingEmail = await shopRepository.findByEmail(cleanEmail);
    if (existingEmail) {
      throw { statusCode: 409, message: 'Shop with this email already exists.' };
    }

    const existingLoginId = await shopRepository.findByLoginId(cleanLoginId);
    if (existingLoginId) {
      throw { statusCode: 409, message: 'Login ID / Username is already taken.' };
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(cleanPassword, salt);

    const shopId = `shop_${uuidv4().substring(0, 8)}`;
    const newShop = await shopRepository.create({
      id: shopId,
      shopName: cleanShopName,
      ownerName: cleanOwnerName,
      email: cleanEmail,
      phone: phone || null,
      address: address || null,
      city: city || null,
      state: state || null,
      country: country || 'India',
      postalCode: postalCode || null,
      gstNumber: gstNumber || null,
      businessType: businessType || null,
      loginId: cleanLoginId,
      passwordHash,
      status: 'active',
      isVerified: true,
      role,
    });

    // Automatically assign default Free Plan subscription
    const allPlans = await planRepository.findAll();
    const freePlan = (await planRepository.findByName('Free')) || allPlans[0];
    if (freePlan) {
      const now = new Date();
      const endDate = new Date();
      endDate.setDate(endDate.getDate() + 14); // 14-day trial/free access

      await subscriptionRepository.create({
        id: `sub_${uuidv4().substring(0, 8)}`,
        shopId: newShop.id,
        planId: freePlan.id,
        planName: freePlan.name,
        status: 'trial',
        startDate: now.toISOString(),
        endDate: endDate.toISOString(),
        renewalDate: endDate.toISOString(),
        billingCycle: freePlan.billing_cycle || 'monthly',
        amount: freePlan.price || 0.0,
        currency: freePlan.currency || 'INR',
        autoRenew: true,
        provider: 'system',
      });
    }

    const token = jwt.sign(
      { shopId: newShop.id, userId: newShop.id, email: newShop.email, role: newShop.role },
      env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    const { password_hash, ...shopPayload } = newShop;

    return {
      token,
      shop: shopPayload,
      user: {
        id: newShop.id,
        username: newShop.login_id,
        fullName: newShop.owner_name,
        email: newShop.email,
        phone: newShop.phone,
        role: newShop.role,
        accountStatus: newShop.status,
      },
      business: {
        id: newShop.id,
        name: newShop.shop_name,
        ownerName: newShop.owner_name,
        email: newShop.email,
        phone: newShop.phone,
        city: newShop.city,
        state: newShop.state,
      },
    };
  }

  async login({ emailOrUsername, identifier, password }) {
    const cleanIdentifier = (identifier || emailOrUsername || '').trim();
    const cleanPassword = (password || '').trim();

    if (!cleanIdentifier || !cleanPassword) {
      throw { statusCode: 400, message: 'Email/Login ID and password are required.' };
    }

    const shop = await shopRepository.findByEmailOrLoginId(cleanIdentifier);
    if (!shop) {
      throw { statusCode: 404, message: 'Invalid credentials. Shop account not found.' };
    }

    const isMatch = await bcrypt.compare(cleanPassword, shop.password_hash);
    if (!isMatch) {
      throw { statusCode: 401, message: 'Invalid credentials. Incorrect password.' };
    }

    if (shop.status !== 'active') {
      throw { statusCode: 403, message: `Account is ${shop.status}. Please contact support.` };
    }

    await shopRepository.update(shop.id, { lastLoginAt: new Date().toISOString() });

    const subscription = await subscriptionRepository.findByShopId(shop.id);

    const token = jwt.sign(
      { shopId: shop.id, userId: shop.id, email: shop.email, role: shop.role },
      env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    const { password_hash, ...shopPayload } = shop;

    return {
      token,
      shop: shopPayload,
      subscription,
      user: {
        id: shop.id,
        username: shop.login_id,
        fullName: shop.owner_name,
        email: shop.email,
        phone: shop.phone,
        role: shop.role,
        accountStatus: shop.status,
      },
      business: {
        id: shop.id,
        name: shop.shop_name,
        ownerName: shop.owner_name,
        email: shop.email,
        phone: shop.phone,
        city: shop.city,
        state: shop.state,
      },
    };
  }

  async getCurrentShop(shopId) {
    const shop = await shopRepository.findById(shopId);
    if (!shop) {
      throw { statusCode: 404, message: 'Shop profile not found.' };
    }

    const subscription = await subscriptionRepository.findByShopId(shop.id);
    const { password_hash, ...shopPayload } = shop;

    return {
      shop: shopPayload,
      subscription,
      user: {
        id: shop.id,
        username: shop.login_id,
        fullName: shop.owner_name,
        email: shop.email,
        phone: shop.phone,
        role: shop.role,
        accountStatus: shop.status,
      },
      business: {
        id: shop.id,
        name: shop.shop_name,
        ownerName: shop.owner_name,
        email: shop.email,
        phone: shop.phone,
        city: shop.city,
        state: shop.state,
      },
    };
  }
}

module.exports = new AuthService();
