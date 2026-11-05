const db = require('../database/db');

class User {
  static findById(id) {
    const row = db.get('SELECT id, name, email, avatar_url, kyc_status, city, neighborhood, completed_rentals, rating, role, created_at FROM users WHERE id = ?', [id]);
    return row;
  }

  static findByEmail(email) {
    const row = db.get('SELECT * FROM users WHERE email = ?', [email]);
    return row;
  }

  static create({ id, name, email, passwordHash, avatarUrl, city, neighborhood }) {
    db.run(`
      INSERT INTO users (id, name, email, password_hash, avatar_url, kyc_status, city, neighborhood, completed_rentals, rating, role)
      VALUES (?, ?, ?, ?, ?, 'pending', ?, ?, 0, 5.0, 'user')
    `, [id, name, email, passwordHash, avatarUrl || '', city || 'São Paulo, SP', neighborhood || 'Pinheiros']);
    return this.findById(id);
  }

  static updateKycStatus(id, status) {
    db.run('UPDATE users SET kyc_status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?', [status, id]);
    return this.findById(id);
  }

  static updateProfile(id, { name, city, neighborhood, avatarUrl }) {
    const current = this.findById(id);
    if (!current) return null;
    db.run(`
      UPDATE users 
      SET name = ?, city = ?, neighborhood = ?, avatar_url = ?, updated_at = CURRENT_TIMESTAMP 
      WHERE id = ?
    `, [
      name || current.name,
      city || current.city,
      neighborhood || current.neighborhood,
      avatarUrl || current.avatar_url,
      id
    ]);
    return this.findById(id);
  }
}

module.exports = User;

