const express = require('express');
const router = express.Router();

const authRoutes = require('./authRoutes');
const itemRoutes = require('./itemRoutes');
const rentalRoutes = require('./rentalRoutes');
const chatRoutes = require('./chatRoutes');

router.use('/auth', authRoutes);
router.use('/items', itemRoutes);
router.use('/rentals', rentalRoutes);
router.use('/chat', chatRoutes);

router.get('/health', (req, res) => {
  res.json({
    success: true,
    data: {
      status: 'online',
      platform: 'AlugaTudo P2P Platform',
      version: '1.0.0',
      timestamp: new Date().toISOString()
    }
  });
});

module.exports = router;

