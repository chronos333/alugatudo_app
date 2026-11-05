const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require('../config/env');
const User = require('../models/User');

class AuthService {
  static generateToken(user) {
    return jwt.sign(
      {
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role
      },
      config.JWT_SECRET,
      { expiresIn: '72h' }
    );
  }

  static async register({ name, email, password, city, neighborhood }) {
    if (!name || !email || !password) {
      throw new Error('Nome, email e senha são obrigatórios.');
    }

    const existing = User.findByEmail(email.toLowerCase().trim());
    if (existing) {
      throw new Error('Este email já está cadastrado na plataforma.');
    }

    const id = `usr_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    const passwordHash = bcrypt.hashSync(password, 10);
    const avatarUrl = `https://api.dicebear.com/7.x/initials/svg?seed=${encodeURIComponent(name)}`;

    const newUser = User.create({
      id,
      name: name.trim(),
      email: email.toLowerCase().trim(),
      passwordHash,
      avatarUrl,
      city: city || 'São Paulo, SP',
      neighborhood: neighborhood || 'Pinheiros'
    });

    const token = this.generateToken(newUser);
    return { user: newUser, token };
  }

  static async login(email, password) {
    if (!email || !password) {
      throw new Error('Email e senha são obrigatórios.');
    }

    const user = User.findByEmail(email.toLowerCase().trim());
    if (!user) {
      throw new Error('Credenciais inválidas. Verifique seu email e senha.');
    }

    const isMatch = bcrypt.compareSync(password, user.password_hash);
    if (!isMatch) {
      throw new Error('Credenciais inválidas. Verifique seu email e senha.');
    }

    const { password_hash, ...safeUser } = user;
    const token = this.generateToken(safeUser);
    return { user: safeUser, token };
  }

  static getProfile(userId) {
    const user = User.findById(userId);
    if (!user) {
      throw new Error('Usuário não encontrado.');
    }
    return user;
  }

  static submitKyc(userId, { documentType, documentNumber }) {
    if (!documentType || !documentNumber) {
      throw new Error('Tipo e número do documento são obrigatórios para verificação KYC.');
    }
    // Aprovação instantânea no ambiente sandbox local
    const updated = User.updateKycStatus(userId, 'approved');
    return updated;
  }
}

module.exports = AuthService;

