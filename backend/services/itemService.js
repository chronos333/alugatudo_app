const Item = require('../models/Item');

class ItemService {
  static getItems(filters) {
    return Item.findAll(filters);
  }

  static getItemById(id) {
    const item = Item.findById(id);
    if (!item) {
      throw new Error(`Equipamento com ID '${id}' não encontrado.`);
    }
    return item;
  }

  static createItem(user, data) {
    if (!data.title || !data.daily_price || !data.category) {
      throw new Error('Título, categoria e valor da diária são obrigatórios.');
    }

    const id = `item_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
    const images = Array.isArray(data.images) && data.images.length > 0 
      ? data.images 
      : ['https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80'];

    const newItem = Item.create({
      id,
      title: data.title,
      full_title: data.full_title || data.title,
      description: data.description || 'Equipamento disponível para locação no AlugaTudo.',
      category: data.category,
      daily_price: Number(data.daily_price),
      deposit_amount: Number(data.deposit_amount || data.daily_price * 10),
      distance_km: 1.2,
      distance_label: '1.2 km de você',
      neighborhood: user.neighborhood || 'Pinheiros, SP',
      pickup_location: data.pickup_location || user.neighborhood || 'Pinheiros, SP',
      images,
      owner_id: user.id,
      owner_name: user.name,
      owner_avatar: user.avatar_url,
      owner_rating: user.rating || 5.0,
      owner_reviews_count: user.completed_rentals || 0,
      owner_since: 'Desde 2026',
      is_kyc_verified: user.kyc_status === 'approved',
      has_escrow_guarantee: true,
      is_quick_pickup: Boolean(data.is_quick_pickup),
      discount_percent_3plus: Number(data.discount_percent_3plus || 15.0),
      tags: Array.isArray(data.tags) ? data.tags : ['Aluguel Seguro', 'Garantia Escrow']
    });

    return newItem;
  }

  static toggleFavorite(userId, itemId) {
    const item = Item.findById(itemId);
    if (!item) {
      throw new Error('Item não encontrado.');
    }
    return Item.toggleFavorite(userId, itemId);
  }

  static getUserFavorites(userId) {
    return Item.getUserFavorites(userId);
  }
}

module.exports = ItemService;

