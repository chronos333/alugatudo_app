const express = require('express');
const router = express.Router();
const ItemController = require('../controllers/itemController');
const authMiddleware = require('../middlewares/authMiddleware');

router.get('/', ItemController.getItems);
router.get('/favorites', authMiddleware, ItemController.getFavorites);
router.get('/:id', ItemController.getItemById);
router.post('/', authMiddleware, ItemController.createItem);
router.post('/:id/favorite', authMiddleware, ItemController.toggleFavorite);

module.exports = router;

