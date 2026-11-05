const ChatService = require('../services/chatService');

class ChatController {
  static async getMessages(req, res, next) {
    try {
      const { rentalId } = req.params;
      const messages = ChatService.getMessages(rentalId);
      res.status(200).json({
        success: true,
        data: { messages }
      });
    } catch (err) {
      next(err);
    }
  }

  static async sendMessage(req, res, next) {
    try {
      const { rentalId } = req.params;
      const { text } = req.body;
      const message = ChatService.sendMessage(req.user, rentalId, text);
      res.status(201).json({
        success: true,
        data: { message }
      });
    } catch (err) {
      next(err);
    }
  }

  static async addInspection(req, res, next) {
    try {
      const { rentalId } = req.params;
      const { title, photoUrl, step } = req.body;
      const insp = ChatService.addInspectionPhoto(req.user, rentalId, { title, photoUrl, step });
      res.status(201).json({
        success: true,
        data: { inspection: insp }
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = ChatController;

