import '../models/user_model.dart';
import 'mock_data_service.dart';

class KycService {
  UserModel _user = MockDataService.getInitialUser();

  UserModel getCurrentUser() => _user;

  void toggleKycStatus() {
    final nextStatus = _user.kycStatus == KycStatus.approved
        ? KycStatus.pending
        : KycStatus.approved;
    _user = _user.copyWith(kycStatus: nextStatus);
  }

  Future<void> submitKycVerification() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    _user = _user.copyWith(kycStatus: KycStatus.approved);
  }

  void updateLocation(String city, String neighborhood) {
    _user = _user.copyWith(city: city, neighborhood: neighborhood);
  }
}
