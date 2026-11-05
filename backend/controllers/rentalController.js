const RentalService = require('../services/rentalService');

class RentalController {
  static async createRental(req, res, next) {
    try {
      const rental = await RentalService.createRental(req.user, req.body);
      res.status(201).json({
        success: true,
        data: { rental }
      });
    } catch (err) {
      next(err);
    }
  }

  static async getRentals(req, res, next) {
    try {
      const rentals = RentalService.getUserRentals(req.user.id);
      res.status(200).json({
        success: true,
        data: { rentals }
      });
    } catch (err) {
      next(err);
    }
  }

  static async getRentalById(req, res, next) {
    try {
      const { id } = req.params;
      const rental = RentalService.getRentalById(id);
      res.status(200).json({
        success: true,
        data: { rental }
      });
    } catch (err) {
      next(err);
    }
  }

  static async verifyDeliveryPin(req, res, next) {
    try {
      const { id } = req.params;
      const { pin } = req.body;
      const updated = RentalService.verifyDeliveryPin(id, pin);
      res.status(200).json({
        success: true,
        data: {
          message: 'PIN de entrega validado com sucesso! Locação em curso.',
          rental: updated
        }
      });
    } catch (err) {
      next(err);
    }
  }

  static async completeRental(req, res, next) {
    try {
      const { id } = req.params;
      const { returnPin } = req.body;
      const updated = RentalService.completeRental(id, returnPin);
      res.status(200).json({
        success: true,
        data: {
          message: 'Locação finalizada e caução escrow estornada com sucesso!',
          rental: updated
        }
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = RentalController;

