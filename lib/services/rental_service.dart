import '../models/rental_model.dart';
import 'mock_data_service.dart';

class RentalService {
  RentalModel _currentRental = MockDataService.getInitialRental();
  final List<RentalModel> _rentalHistory = [];

  RentalModel getCurrentRental() => _currentRental;

  List<RentalModel> getAllRentals() {
    return [_currentRental, ..._rentalHistory];
  }

  void updateFreightType(FreightType type) {
    _currentRental = _currentRental.copyWith(freightType: type);
  }

  void updateRentalStatus(RentalStatus newStatus) {
    _currentRental = _currentRental.copyWith(status: newStatus);
  }

  void updatePaymentMethod(PaymentMethodType method) {
    _currentRental = _currentRental.copyWith(paymentMethod: method);
  }

  void updateDates(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    final validDays = days > 0 ? days : 1;
    _currentRental = _currentRental.copyWith(
      startDate: start,
      endDate: end,
      daysCount: validDays,
    );
  }

  RentalModel createNewBooking({
    required String itemId,
    required String itemTitle,
    required String itemImageUrl,
    required String ownerName,
    required DateTime startDate,
    required DateTime endDate,
    required double dailyRate,
    required double depositAmount,
    FreightType freightType = FreightType.pickup,
  }) {
    final days = endDate.difference(startDate).inDays;
    final validDays = days > 0 ? days : 1;
    final subtotal = validDays * dailyRate;
    final discount = validDays >= 3 ? subtotal * 0.15 : 0.0;
    final platformFee = subtotal * 0.10;

    final newRental = RentalModel(
      id: '#${1020 + _rentalHistory.length + 1}',
      itemId: itemId,
      itemTitle: itemTitle,
      itemImageUrl: itemImageUrl,
      ownerName: ownerName,
      startDate: startDate,
      endDate: endDate,
      daysCount: validDays,
      dailyRate: dailyRate,
      discountAmount: discount,
      platformFee: platformFee,
      freightType: freightType,
      depositAmount: depositAmount,
      status: RentalStatus.requested,
      pinCode: '849-210',
      inspectionPhotos: MockDataService.getInitialRental().inspectionPhotos,
      createdAt: DateTime.now(),
    );

    _rentalHistory.insert(0, _currentRental);
    _currentRental = newRental;
    return newRental;
  }
}
