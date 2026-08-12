const { db } = require('../db/database');

class UserRepository {
  findById(id) {
    return db.prepare('SELECT * FROM users WHERE id = ?').get(id);
  }

  findByEmail(email) {
    if (!email) return null;
    return db.prepare('SELECT * FROM users WHERE LOWER(email) = LOWER(?)').get(email);
  }

  findByPhone(phone) {
    if (!phone) return null;
    return db.prepare('SELECT * FROM users WHERE phone = ?').get(phone);
  }

  findByUsername(username) {
    if (!username) return null;
    return db.prepare('SELECT * FROM users WHERE LOWER(username) = LOWER(?)').get(username);
  }

  create(user) {
    const stmt = db.prepare(`
      INSERT INTO users (id, username, full_name, email, phone, password_hash, profile_image, role, account_status, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);
    const now = new Date().toISOString();
    stmt.run(
      user.id,
      user.username || null,
      user.fullName || user.full_name || null,
      user.email,
      user.phone || null,
      user.passwordHash || user.password_hash,
      user.profileImage || user.profile_image || null,
      user.role || 'OWNER',
      user.accountStatus || user.account_status || 'active',
      user.createdAt || now,
      user.updatedAt || now
    );
    return this.findById(user.id);
  }

  update(id, updates) {
    const fields = [];
    const values = [];
    const now = new Date().toISOString();

    if (updates.username !== undefined) { fields.push('username = ?'); values.push(updates.username); }
    if (updates.fullName !== undefined || updates.full_name !== undefined) {
      fields.push('full_name = ?');
      values.push(updates.fullName || updates.full_name);
    }
    if (updates.email !== undefined) { fields.push('email = ?'); values.push(updates.email); }
    if (updates.phone !== undefined) { fields.push('phone = ?'); values.push(updates.phone); }
    if (updates.passwordHash !== undefined) { fields.push('password_hash = ?'); values.push(updates.passwordHash); }
    if (updates.profileImage !== undefined) { fields.push('profile_image = ?'); values.push(updates.profileImage); }
    if (updates.role !== undefined) { fields.push('role = ?'); values.push(updates.role); }
    if (updates.accountStatus !== undefined) { fields.push('account_status = ?'); values.push(updates.accountStatus); }
    if (updates.lastLogin !== undefined) { fields.push('last_login = ?'); values.push(updates.lastLogin); }

    fields.push('updated_at = ?');
    values.push(now);

    values.push(id);

    db.prepare(`UPDATE users SET ${fields.join(', ')} WHERE id = ?`).run(...values);
    return this.findById(id);
  }

  findAll() {
    return db.prepare('SELECT id, username, full_name, email, phone, profile_image, role, account_status, created_at, last_login FROM users ORDER BY created_at DESC').all();
  }
}

module.exports = new UserRepository();
