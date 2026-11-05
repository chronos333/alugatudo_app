const db = require('../database/db');

class Chat {
  static getMessages(rentalId) {
    const rows = db.all(`
      SELECT * FROM chat_messages 
      WHERE rental_id = ? 
      ORDER BY created_at ASC
    `, [rentalId]);

    return rows.map(r => ({
      ...r,
      photo_urls: r.photo_urls_json ? JSON.parse(r.photo_urls_json) : []
    }));
  }

  static addMessage({ id, rentalId, senderId, senderName, senderType, message, photoUrls = null }) {
    db.run(`
      INSERT INTO chat_messages (id, rental_id, sender_id, sender_name, sender_type, message, photo_urls_json)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `, [
      id,
      rentalId,
      senderId,
      senderName,
      senderType,
      message,
      photoUrls ? JSON.stringify(photoUrls) : null
    ]);

    return db.get('SELECT * FROM chat_messages WHERE id = ?', [id]);
  }

  static getInspectionPhotos(rentalId) {
    return db.all('SELECT * FROM inspection_photos WHERE rental_id = ? ORDER BY created_at ASC', [rentalId]);
  }

  static addInspectionPhoto({ id, rentalId, uploadedBy, step, title, photoUrl }) {
    db.run(`
      INSERT INTO inspection_photos (id, rental_id, uploaded_by, step, title, photo_url)
      VALUES (?, ?, ?, ?, ?, ?)
    `, [id, rentalId, uploadedBy, step, title, photoUrl]);

    return db.get('SELECT * FROM inspection_photos WHERE id = ?', [id]);
  }
}

module.exports = Chat;

