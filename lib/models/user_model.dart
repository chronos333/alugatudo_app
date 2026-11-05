enum KycStatus {
  pending,
  approved,
}

extension KycStatusExt on KycStatus {
  String get label {
    switch (this) {
      case KycStatus.pending:
        return 'PENDENTE';
      case KycStatus.approved:
        return 'APROVADO';
    }
  }

  bool get isApproved => this == KycStatus.approved;
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final KycStatus kycStatus;
  final String city;
  final String neighborhood;
  final int completedRentals;
  final double rating;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.kycStatus = KycStatus.pending,
    required this.city,
    required this.neighborhood,
    this.completedRentals = 12,
    this.rating = 5.0,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    KycStatus? kycStatus,
    String? city,
    String? neighborhood,
    int? completedRentals,
    double? rating,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      kycStatus: kycStatus ?? this.kycStatus,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      completedRentals: completedRentals ?? this.completedRentals,
      rating: rating ?? this.rating,
    );
  }
}
