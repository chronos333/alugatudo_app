-- Schema do banco de dados relacional SQLite para a Plataforma AlugaTudo P2P

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  avatar_url TEXT,
  kyc_status TEXT DEFAULT 'pending',
  city TEXT DEFAULT 'São Paulo, SP',
  neighborhood TEXT DEFAULT 'Pinheiros',
  completed_rentals INTEGER DEFAULT 0,
  rating REAL DEFAULT 5.0,
  role TEXT DEFAULT 'user',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS items (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  full_title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  daily_price REAL NOT NULL,
  deposit_amount REAL NOT NULL,
  distance_km REAL DEFAULT 1.0,
  distance_label TEXT,
  neighborhood TEXT NOT NULL,
  pickup_location TEXT NOT NULL,
  images_json TEXT NOT NULL,
  owner_id TEXT NOT NULL,
  owner_name TEXT NOT NULL,
  owner_avatar TEXT,
  owner_rating REAL DEFAULT 5.0,
  owner_reviews_count INTEGER DEFAULT 0,
  owner_since TEXT DEFAULT 'Desde 2024',
  is_kyc_verified INTEGER DEFAULT 1,
  has_escrow_guarantee INTEGER DEFAULT 1,
  is_quick_pickup INTEGER DEFAULT 0,
  discount_percent_3plus REAL DEFAULT 15.0,
  tags_json TEXT,
  is_available INTEGER DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS favorites (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  item_id TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, item_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS rentals (
  id TEXT PRIMARY KEY,
  item_id TEXT NOT NULL,
  renter_id TEXT NOT NULL,
  host_id TEXT NOT NULL,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  days_count INTEGER NOT NULL,
  daily_price REAL NOT NULL,
  subtotal REAL NOT NULL,
  discount_amount REAL DEFAULT 0.0,
  service_fee REAL NOT NULL,
  freight_type TEXT NOT NULL,
  freight_cost REAL DEFAULT 0.0,
  total_price REAL NOT NULL,
  deposit_amount REAL NOT NULL,
  payment_method TEXT NOT NULL,
  payment_status TEXT DEFAULT 'paid',
  rental_status TEXT DEFAULT 'paidConfirmed',
  delivery_pin TEXT NOT NULL,
  return_pin TEXT NOT NULL,
  escrow_status TEXT DEFAULT 'held',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE RESTRICT,
  FOREIGN KEY (renter_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (host_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS chat_messages (
  id TEXT PRIMARY KEY,
  rental_id TEXT NOT NULL,
  sender_id TEXT NOT NULL,
  sender_name TEXT NOT NULL,
  sender_type TEXT NOT NULL,
  message TEXT NOT NULL,
  photo_urls_json TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (rental_id) REFERENCES rentals(id) ON DELETE CASCADE,
  FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS inspection_photos (
  id TEXT PRIMARY KEY,
  rental_id TEXT NOT NULL,
  uploaded_by TEXT NOT NULL,
  step TEXT NOT NULL,
  title TEXT NOT NULL,
  photo_url TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (rental_id) REFERENCES rentals(id) ON DELETE CASCADE,
  FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS kyc_verifications (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  document_type TEXT NOT NULL,
  document_number TEXT NOT NULL,
  document_front_url TEXT,
  document_back_url TEXT,
  selfie_url TEXT,
  status TEXT DEFAULT 'approved',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

