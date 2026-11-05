const db = require('./db');
const bcrypt = require('bcryptjs');

async function seedDatabase() {
  await db.init();
  console.log('Populando banco de dados com dados iniciais do Stitch...');

  const passwordHash = bcrypt.hashSync('123456', 10);

  // 1. Usuários
  const users = [
    {
      id: 'usr_001',
      name: 'Vinicius Pini',
      email: 'vinicius.pini@email.com',
      avatar_url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      kyc_status: 'approved',
      city: 'São Paulo, SP',
      neighborhood: 'Pinheiros',
      completed_rentals: 14,
      rating: 4.95,
      role: 'user'
    },
    {
      id: 'usr_002',
      name: 'Lucas Mendes',
      email: 'lucas.mendes@email.com',
      avatar_url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      kyc_status: 'approved',
      city: 'São Paulo, SP',
      neighborhood: 'Pinheiros',
      completed_rentals: 42,
      rating: 4.9,
      role: 'user'
    },
    {
      id: 'usr_003',
      name: 'Carla Souza',
      email: 'carla.souza@email.com',
      avatar_url: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      kyc_status: 'approved',
      city: 'São Paulo, SP',
      neighborhood: 'Vila Madalena',
      completed_rentals: 19,
      rating: 5.0,
      role: 'user'
    },
    {
      id: 'usr_004',
      name: 'Roberto Silva',
      email: 'roberto.silva@email.com',
      avatar_url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      kyc_status: 'approved',
      city: 'São Paulo, SP',
      neighborhood: 'Moema',
      completed_rentals: 28,
      rating: 4.8,
      role: 'user'
    }
  ];

  for (const u of users) {
    db.run(`
      INSERT OR REPLACE INTO users (id, name, email, password_hash, avatar_url, kyc_status, city, neighborhood, completed_rentals, rating, role)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [u.id, u.name, u.email, passwordHash, u.avatar_url, u.kyc_status, u.city, u.neighborhood, u.completed_rentals, u.rating, u.role]);
  }

  // 2. Itens do Catálogo Stitch
  const items = [
    {
      id: 'item_01',
      title: 'Câmera Sony A7 III + Lente 28-70mm',
      full_title: 'Câmera Sony Alpha A7 III Full Frame + Lente 28-70mm + 2 Baterias',
      description: 'Câmera profissional mirrorless ideal para produções audiovisuais, filmagens em 4K HDR e ensaios fotográficos de altíssima fidelidade. Acompanha carregador duplo, duas baterias originais Sony e cartão SD Sandisk Extreme Pro 128GB.',
      category: 'Eletrônicos & Câmeras',
      daily_price: 130.0,
      deposit_amount: 1500.0,
      distance_km: 1.2,
      distance_label: '1.2 km de você',
      neighborhood: 'Pinheiros, SP',
      pickup_location: 'Estação Faria Lima (Linha Amarela)',
      images: [
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1512790182412-b19e6d62bc39?auto=format&fit=crop&w=800&q=80'
      ],
      owner_id: 'usr_002',
      owner_name: 'Lucas Mendes',
      owner_avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      owner_rating: 4.9,
      owner_reviews_count: 42,
      owner_since: 'Desde 2023',
      is_kyc_verified: 1,
      has_escrow_guarantee: 1,
      is_quick_pickup: 0,
      discount_percent_3plus: 15.0,
      tags: ['Full Frame', '4K 60fps', 'Estabilizador', 'SD 128GB']
    },
    {
      id: 'item_02',
      title: 'Parafusadeira de Impacto DeWalt 20V',
      full_title: 'Parafusadeira e Furadeira de Impacto DeWalt 20V MAX Íon de Lítio',
      description: 'Potente ferramenta para reformas, montagem de móveis e marcenaria. Acompanha 2 baterias de 20V, carregador bivolt rápido, jogo com 10 bits de ponta magnética e maleta reforçada TSTAK.',
      category: 'Ferramentas',
      daily_price: 45.0,
      deposit_amount: 300.0,
      distance_km: 0.8,
      distance_label: '800 m de você',
      neighborhood: 'Pinheiros, SP',
      pickup_location: 'Rua Fradique Coutinho, 120',
      images: [
        'https://images.unsplash.com/photo-1504148455328-c376907d081c?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1572981779307-38b8cabb2407?auto=format&fit=crop&w=800&q=80'
      ],
      owner_id: 'usr_003',
      owner_name: 'Carla Souza',
      owner_avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      owner_rating: 5.0,
      owner_reviews_count: 19,
      owner_since: 'Desde 2024',
      is_kyc_verified: 1,
      has_escrow_guarantee: 1,
      is_quick_pickup: 1,
      discount_percent_3plus: 10.0,
      tags: ['Sem Fio', 'Bateria Dupla', 'Impacto', 'Bivolt']
    },
    {
      id: 'item_03',
      title: 'Smart Projetor Samsung The Freestyle FHD',
      full_title: 'Smart Projetor Portátil Samsung The Freestyle 100 polegadas',
      description: 'Projetor smart portátil de altíssima definição 1080p com sistema Tizen integrado (Netflix, YouTube, Prime), auto foco imediato, nivelamento automático de imagem e som 360 graus.',
      category: 'Eletrônicos & Câmeras',
      daily_price: 85.0,
      deposit_amount: 900.0,
      distance_km: 2.5,
      distance_label: '2.5 km de você',
      neighborhood: 'Vila Madalena, SP',
      pickup_location: 'Estação Vila Madalena',
      images: [
        'https://images.unsplash.com/photo-1535016120720-40c646be5580?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&w=800&q=80'
      ],
      owner_id: 'usr_004',
      owner_name: 'Roberto Silva',
      owner_avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      owner_rating: 4.8,
      owner_reviews_count: 28,
      owner_since: 'Desde 2023',
      is_kyc_verified: 1,
      has_escrow_guarantee: 1,
      is_quick_pickup: 0,
      discount_percent_3plus: 15.0,
      tags: ['Smart TV', 'Full HD', 'Som 360', 'Portátil']
    },
    {
      id: 'item_04',
      title: 'Caixa de Som JBL PartyBox 310 Bluetooth',
      full_title: 'Caixa de Som Amplificada JBL PartyBox 310 com Luzes LED e Rodinhas',
      description: 'Caixa de som com 240W RMS de som potente JBL Pro Sound, show de luzes dinâmico sincronizado no ritmo da música, bateria com até 18 horas de autonomia e entradas para microfone e guitarra.',
      category: 'Festas & Eventos',
      daily_price: 95.0,
      deposit_amount: 800.0,
      distance_km: 1.8,
      distance_label: '1.8 km de você',
      neighborhood: 'Pinheiros, SP',
      pickup_location: 'Próximo ao Largo da Batata',
      images: [
        'https://images.unsplash.com/photo-1545454675-3531b543be5d?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=800&q=80'
      ],
      owner_id: 'usr_002',
      owner_name: 'Lucas Mendes',
      owner_avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      owner_rating: 4.9,
      owner_reviews_count: 42,
      owner_since: 'Desde 2023',
      is_kyc_verified: 1,
      has_escrow_guarantee: 1,
      is_quick_pickup: 1,
      discount_percent_3plus: 15.0,
      tags: ['240W RMS', 'Bluetooth', '18h Bateria', 'Luzes RGB']
    },
    {
      id: 'item_05',
      title: 'Tenda de Camping Coleman 4 Pessoas Impermeável',
      full_title: 'Barraca de Acampamento Coleman WeatherTec 4 Pessoas com Avanço',
      description: 'Tenda de acampamento robusta com sistema impermeável exclusivo WeatherTec suportando chuvas fortes, montagem rápida em 10 minutos, sobreteto ventilado e bolsa de transporte inclusa.',
      category: 'Esportes',
      daily_price: 50.0,
      deposit_amount: 350.0,
      distance_km: 3.1,
      distance_label: '3.1 km de você',
      neighborhood: 'Jardins, SP',
      pickup_location: 'Alameda Santos, 800',
      images: [
        'https://images.unsplash.com/photo-1510312305653-8ed496efae75?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?auto=format&fit=crop&w=800&q=80'
      ],
      owner_id: 'usr_003',
      owner_name: 'Carla Souza',
      owner_avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      owner_rating: 5.0,
      owner_reviews_count: 19,
      owner_since: 'Desde 2024',
      is_kyc_verified: 1,
      has_escrow_guarantee: 1,
      is_quick_pickup: 0,
      discount_percent_3plus: 10.0,
      tags: ['Camping', 'Impermeável', '4 Pessoas', 'Coleman']
    },
    {
      id: 'item_06',
      title: 'Estabilizador Gimbal DJI Ronin RS 3',
      full_title: 'Gimbal DJI RS 3 Pro Estabilizador de 3 Eixos para Câmeras DSLR',
      description: 'Estabilizador gimbal profissional de 3 eixos para câmeras pesadas de até 3kg. Travas automáticas de eixo, tela touch OLED colorida de 1.8" e algoritmo de estabilização de terceira geração.',
      category: 'Eletrônicos & Câmeras',
      daily_price: 90.0,
      deposit_amount: 1100.0,
      distance_km: 1.5,
      distance_label: '1.5 km de você',
      neighborhood: 'Pinheiros, SP',
      pickup_location: 'Estação Faria Lima',
      images: [
        'https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80'
      ],
      owner_id: 'usr_002',
      owner_name: 'Lucas Mendes',
      owner_avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      owner_rating: 4.9,
      owner_reviews_count: 42,
      owner_since: 'Desde 2023',
      is_kyc_verified: 1,
      has_escrow_guarantee: 1,
      is_quick_pickup: 1,
      discount_percent_3plus: 15.0,
      tags: ['Gimbal 3 Eixos', 'DJI Pro', 'OLED Touch', '3kg Payload']
    }
  ];

  for (const it of items) {
    db.run(`
      INSERT OR REPLACE INTO items (
        id, title, full_title, description, category, daily_price, deposit_amount,
        distance_km, distance_label, neighborhood, pickup_location, images_json,
        owner_id, owner_name, owner_avatar, owner_rating, owner_reviews_count, owner_since,
        is_kyc_verified, has_escrow_guarantee, is_quick_pickup, discount_percent_3plus,
        tags_json, is_available
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      it.id,
      it.title,
      it.full_title,
      it.description,
      it.category,
      it.daily_price,
      it.deposit_amount,
      it.distance_km,
      it.distance_label,
      it.neighborhood,
      it.pickup_location,
      JSON.stringify(it.images),
      it.owner_id,
      it.owner_name,
      it.owner_avatar,
      it.owner_rating,
      it.owner_reviews_count,
      it.owner_since,
      it.is_kyc_verified,
      it.has_escrow_guarantee,
      it.is_quick_pickup,
      it.discount_percent_3plus,
      JSON.stringify(it.tags),
      1
    ]);
  }

  // 3. Reserva Exemplo
  db.run(`
    INSERT OR REPLACE INTO rentals (
      id, item_id, renter_id, host_id, start_date, end_date, days_count, daily_price,
      subtotal, discount_amount, service_fee, freight_type, freight_cost, total_price,
      deposit_amount, payment_method, payment_status, rental_status, delivery_pin, return_pin, escrow_status
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `, [
    'rent_demo_01',
    'item_01',
    'usr_001',
    'usr_002',
    '2026-11-06',
    '2026-11-09',
    3,
    130.0,
    390.0,
    58.5,
    33.15,
    'pickup',
    0.0,
    364.65,
    1500.0,
    'creditCard',
    'paid',
    'paidConfirmed',
    '482910',
    '819203',
    'held'
  ]);

  // 4. Mensagens do Chat
  db.run(`
    INSERT OR REPLACE INTO chat_messages (id, rental_id, sender_id, sender_name, sender_type, message, photo_urls_json)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `, [
    'msg_01',
    'rent_demo_01',
    'usr_002',
    'Lucas Mendes',
    'host',
    'Olá Vinicius! Reserva confirmada. O kit já está com as 2 baterias totalmente carregadas.',
    null
  ]);

  db.run(`
    INSERT OR REPLACE INTO chat_messages (id, rental_id, sender_id, sender_name, sender_type, message, photo_urls_json)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `, [
    'msg_02',
    'rent_demo_01',
    'usr_001',
    'Vinicius Pini',
    'user',
    'Excelente Lucas! Posso retirar amanhã por volta das 10h na Estação Faria Lima?',
    null
  ]);

  db.run(`
    INSERT OR REPLACE INTO chat_messages (id, rental_id, sender_id, sender_name, sender_type, message, photo_urls_json)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `, [
    'msg_03',
    'rent_demo_01',
    'usr_002',
    'Lucas Mendes',
    'host',
    'Perfeito! Estarei na saída principal da catraca às 10h pontualmente com a maleta.',
    null
  ]);

  // 5. Vistoria Fotográfica
  db.run(`
    INSERT OR REPLACE INTO inspection_photos (id, rental_id, uploaded_by, step, title, photo_url)
    VALUES (?, ?, ?, ?, ?, ?)
  `, [
    'insp_01',
    'rent_demo_01',
    'usr_002',
    'pre_delivery',
    'Sensor e Lente Impecáveis',
    'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=400&q=80'
  ]);

  console.log('Banco de dados semeado com sucesso!');
}

if (require.main === module) {
  seedDatabase().catch(err => {
    console.error('Erro ao semear:', err);
    process.exit(1);
  });
}

module.exports = seedDatabase;
