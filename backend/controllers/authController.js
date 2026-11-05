const AuthService = require('../services/authService');

class AuthController {
  static async register(req, res, next) {
    try {
      const { name, email, password, city, neighborhood } = req.body;
      const result = await AuthService.register({ name, email, password, city, neighborhood });
      res.status(201).json({
        success: true,
        data: result
      });
    } catch (err) {
      next(err);
    }
  }

  static async login(req, res, next) {
    try {
      const { email, password } = req.body;
      const result = await AuthService.login(email, password);
      res.status(200).json({
        success: true,
        data: result
      });
    } catch (err) {
      next(err);
    }
  }

  static async me(req, res, next) {
    try {
      const user = AuthService.getProfile(req.user.id);
      res.status(200).json({
        success: true,
        data: { user }
      });
    } catch (err) {
      next(err);
    }
  }

  static async submitKyc(req, res, next) {
    try {
      const { documentType, documentNumber } = req.body;
      const updatedUser = AuthService.submitKyc(req.user.id, { documentType, documentNumber });
      res.status(200).json({
        success: true,
        data: {
          message: 'Documento recebido e verificação KYC aprovada com sucesso!',
          user: updatedUser
        }
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = AuthController;

