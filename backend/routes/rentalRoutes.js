const express = require('express');
const router = express.Router();
const RentalController = require('../controllers/rentalController');
const authMiddleware = require('../middlewares/authMiddleware');

router.post('/', authMiddleware, RentalController.createRental);
router.get('/', authMiddleware, RentalController.getRentals);
router.get('/:id', authMiddleware, RentalController.getRentalById);
router.post('/:id/verify-pin', authMiddleware, RentalController.verifyDeliveryPin);
router.post('/:id/complete', authMiddleware, RentalController.completeRental);

module.exports = router;

