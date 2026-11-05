const express = require('express');
const router = express.Router();
const ChatController = require('../controllers/chatController');
const authMiddleware = require('../middlewares/authMiddleware');

router.get('/:rentalId', authMiddleware, ChatController.getMessages);
router.post('/:rentalId', authMiddleware, ChatController.sendMessage);
router.post('/:rentalId/inspection', authMiddleware, ChatController.addInspection);

module.exports = router;

