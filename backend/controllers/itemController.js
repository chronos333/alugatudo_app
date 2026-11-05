const ItemService = require('../services/itemService');

class ItemController {
  static async getItems(req, res, next) {
    try {
      const { query, category, maxRadius, sort } = req.query;
      const items = ItemService.getItems({
        query,
        category,
        maxRadius: maxRadius ? Number(maxRadius) : undefined,
        sort
      });

      res.status(200).json({
        success: true,
        data: {
          items,
          total: items.length
        }
      });
    } catch (err) {
      next(err);
    }
  }

  static async getItemById(req, res, next) {
    try {
      const { id } = req.params;
      const item = ItemService.getItemById(id);
      res.status(200).json({
        success: true,
        data: { item }
      });
    } catch (err) {
      next(err);
    }
  }

  static async createItem(req, res, next) {
    try {
      const newItem = ItemService.createItem(req.user, req.body);
      res.status(201).json({
        success: true,
        data: { item: newItem }
      });
    } catch (err) {
      next(err);
    }
  }

  static async toggleFavorite(req, res, next) {
    try {
      const { id } = req.params;
      const result = ItemService.toggleFavorite(req.user.id, id);
      res.status(200).json({
        success: true,
        data: result
      });
    } catch (err) {
      next(err);
    }
  }

  static async getFavorites(req, res, next) {
    try {
      const items = ItemService.getUserFavorites(req.user.id);
      res.status(200).json({
        success: true,
        data: { items }
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = ItemController;

