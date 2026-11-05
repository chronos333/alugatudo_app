const db = require('../database/db');

class Rental {
  static formatRow(row) {
    if (!row) return null;
    return {
      ...row,
      days_count: Number(row.days_count),
      daily_price: Number(row.daily_price),
      subtotal: Number(row.subtotal),
      discount_amount: Number(row.discount_amount),
      service_fee: Number(row.service_fee),
      freight_cost: Number(row.freight_cost),
      total_price: Number(row.total_price),
      deposit_amount: Number(row.deposit_amount)
    };
  }

  static findById(id) {
    const row = db.get(`
      SELECT rentals.*, 
             items.title as item_title, items.full_title as item_full_title, items.images_json as item_images, items.pickup_location,
             renter.name as renter_name, renter.avatar_url as renter_avatar,
             host.name as host_name, host.avatar_url as host_avatar, host.rating as host_rating
      FROM rentals
      INNER JOIN items ON items.id = rentals.item_id
      INNER JOIN users as renter ON renter.id = rentals.renter_id
      INNER JOIN users as host ON host.id = rentals.host_id
      WHERE rentals.id = ?
    `, [id]);

    if (!row) return null;
    const formatted = this.formatRow(row);
    formatted.item_images = row.item_images ? JSON.parse(row.item_images) : [];
    return formatted;
  }

  static findByUser(userId) {
    const rows = db.all(`
      SELECT rentals.*, 
             items.title as item_title, items.full_title as item_full_title, items.images_json as item_images, items.pickup_location,
             host.name as host_name, host.avatar_url as host_avatar
      FROM rentals
      INNER JOIN items ON items.id = rentals.item_id
      INNER JOIN users as host ON host.id = rentals.host_id
      WHERE rentals.renter_id = ? OR rentals.host_id = ?
      ORDER BY rentals.created_at DESC
    `, [userId, userId]);

    return rows.map(r => {
      const f = this.formatRow(r);
      f.item_images = r.item_images ? JSON.parse(r.item_images) : [];
      return f;
    });
  }

  static create(data) {
    db.run(`
      INSERT INTO rentals (
        id, item_id, renter_id, host_id, start_date, end_date, days_count, daily_price,
        subtotal, discount_amount, service_fee, freight_type, freight_cost, total_price,
        deposit_amount, payment_method, payment_status, rental_status, delivery_pin, return_pin, escrow_status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      data.id,
      data.item_id,
      data.renter_id,
      data.host_id,
      data.start_date,
      data.end_date,
      data.days_count,
      data.daily_price,
      data.subtotal,
      data.discount_amount,
      data.service_fee,
      data.freight_type,
      data.freight_cost,
      data.total_price,
      data.deposit_amount,
      data.payment_method,
      data.payment_status || 'paid',
      data.rental_status || 'paidConfirmed',
      data.delivery_pin,
      data.return_pin,
      data.escrow_status || 'held'
    ]);

    return this.findById(data.id);
  }

  static updateStatus(id, rentalStatus, escrowStatus = null) {
    if (escrowStatus) {
      db.run('UPDATE rentals SET rental_status = ?, escrow_status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?', [rentalStatus, escrowStatus, id]);
    } else {
      db.run('UPDATE rentals SET rental_status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?', [rentalStatus, id]);
    }
    return this.findById(id);
  }
}

module.exports = Rental;

