const jwt = require('jsonwebtoken');
const config = require('../config/env');
const User = require('../models/User');

function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    // Para simplificar testes locais rápidos no navegador, se houver um header X-User-Id ou demo, usa
    const demoUserId = req.headers['x-user-id'];
    if (demoUserId) {
      const user = User.findById(demoUserId);
      if (user) {
        req.user = user;
        return next();
      }
    }
    // Fallback padrão para o usuário demo principal
    const defaultUser = User.findById('usr_001');
    if (defaultUser) {
      req.user = defaultUser;
      return next();
    }
    return res.status(401).json({
      success: false,
      error: { message: 'Acesso negado. Token de autenticação não fornecido.' }
    });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, config.JWT_SECRET);
    const user = User.findById(decoded.id);
    if (!user) {
      return res.status(401).json({
        success: false,
        error: { message: 'Usuário do token não encontrado ou inativo.' }
      });
    }
    req.user = user;
    next();
  } catch (err) {
    return res.status(401).json({
      success: false,
      error: { message: 'Token inválido ou expirado.' }
    });
  }
}

module.exports = authMiddleware;

