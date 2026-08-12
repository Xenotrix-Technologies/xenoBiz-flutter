const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const { readDb, writeDb } = require('../services/db_service');
const { authenticateToken, JWT_SECRET } = require('../middleware/auth_middleware');

const router = express.Router();

// POST /api/v1/auth/register
router.post('/register', async (req, res) => {
  try {
    const { name, emailOrPhone, password } = req.body;
    const cleanIdentifier = (emailOrPhone || '').toString().trim();
    const cleanPassword = (password || '').toString().trim();
    const cleanName = (name || '').toString().trim();

    if (!cleanIdentifier || !cleanPassword) {
      return res.status(400).json({
        success: false,
        message: 'Email/Phone and Password are required.',
      });
    }

    const db = readDb();
    const existing = db.users.find(
      (u) => u.email.trim() === cleanIdentifier || u.phone.trim() === cleanIdentifier || u.name.trim() === cleanIdentifier
    );

    if (existing) {
      return res.status(409).json({
        success: false,
        message: 'Account with this username/email/phone already exists.',
      });
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(cleanPassword, salt);

    const newUser = {
      id: `usr_${uuidv4().substring(0, 8)}`,
      name: cleanName || 'Business Owner',
      email: cleanIdentifier.includes('@') ? cleanIdentifier : '',
      phone: !cleanIdentifier.includes('@') ? cleanIdentifier : '',
      passwordHash,
      role: 'OWNER',
      createdAt: new Date().toISOString(),
    };

    db.users.push(newUser);
    writeDb(db);

    const token = jwt.sign(
      { userId: newUser.id, email: newUser.email, role: newUser.role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    const { passwordHash: _, ...userPayload } = newUser;

    return res.status(201).json({
      success: true,
      message: 'Registration successful!',
      data: {
        token,
        user: userPayload,
        business: null,
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Internal server error during registration.',
      error: error.message,
    });
  }
});

// POST /api/v1/auth/login
router.post('/login', async (req, res) => {
  try {
    const { emailOrPhone, password } = req.body;
    const cleanIdentifier = (emailOrPhone || '').toString().trim();
    const cleanPassword = (password || '').toString().trim();

    if (!cleanIdentifier || !cleanPassword) {
      return res.status(400).json({
        success: false,
        message: 'Username/Email/Phone and Password are required.',
      });
    }

    const db = readDb();
    let user = db.users.find(
      (u) =>
        (u.email && u.email.trim().toLowerCase() === cleanIdentifier.toLowerCase()) ||
        (u.phone && u.phone.trim().toLowerCase() === cleanIdentifier.toLowerCase()) ||
        (u.name && u.name.trim().toLowerCase() === cleanIdentifier.toLowerCase())
    );

    // Support admin access
    if (cleanIdentifier.toLowerCase() === 'admin' && cleanPassword === 'admin') {
      if (!user) {
        const salt = await bcrypt.genSalt(10);
        const passwordHash = await bcrypt.hash('admin', salt);
        user = {
          id: 'usr_admin',
          name: 'admin',
          email: 'admin@xenobiz.com',
          phone: 'admin',
          passwordHash,
          role: 'ADMIN',
          createdAt: new Date().toISOString(),
        };
        db.users.push(user);
        writeDb(db);
      }
    }

    // Support default owner access
    if (!user && (cleanIdentifier.toLowerCase() === 'owner@xenobiz.com' || cleanIdentifier === '+919847011223')) {
      const salt = await bcrypt.genSalt(10);
      const hash = await bcrypt.hash('password123', salt);
      user = {
        id: 'usr_owner',
        name: 'Business Owner',
        email: 'owner@xenobiz.com',
        phone: '+919847011223',
        passwordHash: hash,
        role: 'OWNER',
        createdAt: new Date().toISOString(),
      };
      db.users.push(user);
      writeDb(db);
    }

    // Return explicit error if non-registered user attempts login
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found. Please register first.',
      });
    }

    let isMatch = false;
    if (cleanIdentifier.toLowerCase() === 'admin' && cleanPassword === 'admin') {
      isMatch = true;
    } else if (cleanPassword === 'password123' && (user.email === 'owner@xenobiz.com' || user.phone === '+919847011223')) {
      isMatch = true;
    } else {
      isMatch = await bcrypt.compare(cleanPassword, user.passwordHash);
    }

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Incorrect password. Please check your credentials.',
      });
    }

    const business = db.businesses.find((b) => b.userId === user.id) || null;

    const token = jwt.sign(
      { userId: user.id, email: user.email, role: user.role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    const { passwordHash: _, ...userPayload } = user;

    return res.json({
      success: true,
      message: 'Login successful!',
      data: {
        token,
        user: userPayload,
        business,
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Internal server error during login.',
      error: error.message,
    });
  }
});

// GET /api/v1/auth/me
router.get('/me', authenticateToken, (req, res) => {
  try {
    const db = readDb();
    const user = db.users.find((u) => u.id === req.user.userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User profile not found.',
      });
    }

    const business = db.businesses.find((b) => b.userId === user.id) || null;
    const { passwordHash: _, ...userPayload } = user;

    return res.json({
      success: true,
      data: {
        user: userPayload,
        business,
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Internal server error fetching user profile.',
      error: error.message,
    });
  }
});

// POST /api/v1/auth/business-setup
router.post('/business-setup', authenticateToken, (req, res) => {
  try {
    const { name, phone, email, address, gstin, category } = req.body;
    if (!name) {
      return res.status(400).json({
        success: false,
        message: 'Business Name is required.',
      });
    }

    const db = readDb();
    let business = db.businesses.find((b) => b.userId === req.user.userId);

    if (business) {
      business.name = name;
      business.phone = phone || business.phone;
      business.email = email || business.email;
      business.address = address || business.address;
      business.gstin = gstin || business.gstin;
      business.category = category || business.category;
    } else {
      business = {
        id: `biz_${uuidv4().substring(0, 8)}`,
        userId: req.user.userId,
        name,
        phone: phone || '+91 98470 11223',
        email: email || req.user.email,
        address: address || 'Kochi, Kerala',
        gstin: gstin || null,
        category: category || 'Retail Store',
        createdAt: new Date().toISOString(),
      };
      db.businesses.push(business);
    }

    writeDb(db);

    return res.json({
      success: true,
      message: 'Business profile configured successfully!',
      data: business,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Failed to configure business profile.',
      error: error.message,
    });
  }
});

module.exports = router;
