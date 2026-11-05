const db = require('../database/db');

class Item {
  static formatRow(row) {
    if (!row) return null;
    return {
      ...row,
      images: row.images_json ? JSON.parse(row.images_json) : [],
      tags: row.tags_json ? JSON.parse(row.tags_json) : [],
      is_kyc_verified: Boolean(row.is_kyc_verified),
      has_escrow_guarantee: Boolean(row.has_escrow_guarantee),
      is_quick_pickup: Boolean(row.is_quick_pickup),
      is_available: Boolean(row.is_available)
    };
  }

  static findAll({ query = '', category = 'Todas', maxRadius = 50, sort = 'recommended' } = {}) {
    let sql = 'SELECT * FROM items WHERE is_available = 1';
    const params = [];

    if (category && category !== 'Todas') {
      sql += ' AND category = ?';
      params.push(category);
    }

    if (query && query.trim().length > 0) {
      sql += ' AND (title LIKE ? OR full_title LIKE ? OR description LIKE ? OR tags_json LIKE ?)';
      const term = `%${query.trim()}%`;
      params.push(term, term, term, term);
    }

    if (maxRadius) {
      sql += ' AND distance_km <= ?';
      params.push(Number(maxRadius));
    }

    if (sort === 'price_asc') {
      sql += ' ORDER BY daily_price ASC';
    } else if (sort === 'price_desc') {
      sql += ' ORDER BY daily_price DESC';
    } else if (sort === 'distance') {
      sql += ' ORDER BY distance_km ASC';
    } else {
      sql += ' ORDER BY created_at DESC';
    }

    const rows = db.all(sql, params);
    return rows.map(this.formatRow);
  }

  static findById(id) {
    const row = db.get('SELECT * FROM items WHERE id = ?', [id]);
    return this.formatRow(row);
  }

  static create(data) {
    db.run(`
      INSERT INTO items (
        id, title, full_title, description, category, daily_price, deposit_amount,
        distance_km, distance_label, neighborhood, pickup_location, images_json,
        owner_id, owner_name, owner_avatar, owner_rating, owner_reviews_count, owner_since,
        is_kyc_verified, has_escrow_guarantee, is_quick_pickup, discount_percent_3plus,
        tags_json, is_available
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
    `, [
      data.id,
      data.title,
      data.full_title || data.title,
      data.description,
      data.category,
      Number(data.daily_price),
      Number(data.deposit_amount),
      data.distance_km || 1.0,
      data.distance_label || `${data.distance_km || 1.0} km de você`,
      data.neighborhood || 'Pinheiros, SP',
      data.pickup_location || 'A combinar',
      JSON.stringify(data.images || []),
      data.owner_id,
      data.owner_name,
      data.owner_avatar || '',
      data.owner_rating || 5.0,
      data.owner_reviews_count || 1,
      data.owner_since || 'Desde 2026',
      data.is_kyc_verified ? 1 : 0,
      data.has_escrow_guarantee !== false ? 1 : 0,
      data.is_quick_pickup ? 1 : 0,
      data.discount_percent_3plus || 15.0,
      JSON.stringify(data.tags || [])
    ]);

    return this.findById(data.id);
  }

  static toggleFavorite(userId, itemId) {
    const existing = db.get('SELECT id FROM favorites WHERE user_id = ? AND item_id = ?', [userId, itemId]);
    if (existing) {
      db.run('DELETE FROM favorites WHERE id = ?', [existing.id]);
      return { isFavorite: false };
    } else {
      db.run('INSERT INTO favorites (user_id, item_id) VALUES (?, ?)', [userId, itemId]);
      return { isFavorite: true };
    }
  }

  static getUserFavorites(userId) {
    const rows = db.all(`
      SELECT items.* FROM items
      INNER JOIN favorites ON favorites.item_id = items.id
      WHERE favorites.user_id = ?
    `, [userId]);
    return rows.map(this.formatRow);
  }
}

module.exports = Item;

