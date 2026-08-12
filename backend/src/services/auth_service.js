const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const env = require('../config/env');
const userRepository = require('../repositories/user_repository');
const businessRepository = require('../repositories/business_repository');

class AuthService {
  async register({ email, username, fullName, phone, password, role = 'OWNER' }) {
    const cleanEmail = (email || '').trim().toLowerCase();
    const cleanPassword = (password || '').trim();
    const cleanName = (fullName || username || 'Business Owner').trim();

    if (!cleanEmail || !cleanPassword) {
      throw { statusCode: 400, message: 'Email and password are required.' };
    }

    const existingEmail = userRepository.findByEmail(cleanEmail);
    if (existingEmail) {
      throw { statusCode: 409, message: 'User with this email already exists.' };
    }

    if (username) {
      const existingUser = userRepository.findByUsername(username);
      if (existingUser) {
        throw { statusCode: 409, message: 'Username is already taken.' };
      }
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(cleanPassword, salt);

    const userId = `usr_${uuidv4().substring(0, 8)}`;
    const newUser = userRepository.create({
      id: userId,
      username: username || cleanEmail.split('@')[0],
      fullName: cleanName,
      email: cleanEmail,
      phone: phone || null,
      passwordHash,
      role,
      accountStatus: 'active',
    });

    const token = jwt.sign(
      { userId: newUser.id, email: newUser.email, role: newUser.role },
      env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    const { password_hash, ...userPayload } = newUser;
    return {
      token,
      user: userPayload,
      business: null,
    };
  }

  async login({ emailOrUsername, password }) {
    const cleanIdentifier = (emailOrUsername || '').trim();
    const cleanPassword = (password || '').trim();

    if (!cleanIdentifier || !cleanPassword) {
      throw { statusCode: 400, message: 'Email/Username and password are required.' };
    }

    let user = userRepository.findByEmail(cleanIdentifier) || userRepository.findByUsername(cleanIdentifier) || userRepository.findByPhone(cleanIdentifier);
    if (!user) {
      throw { statusCode: 404, message: 'Invalid credentials. User not found.' };
    }

    const isMatch = await bcrypt.compare(cleanPassword, user.password_hash);
    if (!isMatch) {
      throw { statusCode: 401, message: 'Invalid credentials. Incorrect password.' };
    }

    userRepository.update(user.id, { lastLogin: new Date().toISOString() });

    const business = businessRepository.findPrimaryByUserId(user.id) || null;

    const token = jwt.sign(
      { userId: user.id, email: user.email, role: user.role },
      env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    const { password_hash, ...userPayload } = user;
    return {
      token,
      user: userPayload,
      business,
    };
  }

  async getCurrentUser(userId) {
    const user = userRepository.findById(userId);
    if (!user) {
      throw { statusCode: 404, message: 'User profile not found.' };
    }

    const business = businessRepository.findPrimaryByUserId(user.id) || null;
    const { password_hash, ...userPayload } = user;

    return {
      user: userPayload,
      business,
    };
  }
}

module.exports = new AuthService();
