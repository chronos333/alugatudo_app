class ItemModel {
  final String id;
  final String title;
  final String fullTitle;
  final String description;
  final String category;
  final double dailyPrice;
  final double depositAmount;
  final double distanceKm;
  final String distanceLabel;
  final String neighborhood;
  final List<String> images;
  final String ownerName;
  final String ownerFullName;
  final String ownerAvatarUrl;
  final double ownerRating;
  final int ownerReviewsCount;
  final String ownerSince;
  final bool isKycVerified;
  final bool hasEscrowGuarantee;
  final bool isQuickPickup;
  final double discountPercentFor3PlusDays;
  final String pickupLocation;
  final List<String> tags;
  bool isFavorite;

  ItemModel({
    required this.id,
    required this.title,
    required this.fullTitle,
    required this.description,
    required this.category,
    required this.dailyPrice,
    required this.depositAmount,
    required this.distanceKm,
    required this.distanceLabel,
    required this.neighborhood,
    required this.images,
    required this.ownerName,
    required this.ownerFullName,
    required this.ownerAvatarUrl,
    required this.ownerRating,
    required this.ownerReviewsCount,
    required this.ownerSince,
    this.isKycVerified = true,
    this.hasEscrowGuarantee = true,
    this.isQuickPickup = false,
    this.discountPercentFor3PlusDays = 15.0,
    required this.pickupLocation,
    required this.tags,
    this.isFavorite = false,
  });

  ItemModel copyWith({
    String? id,
    String? title,
    String? fullTitle,
    String? description,
    String? category,
    double? dailyPrice,
    double? depositAmount,
    double? distanceKm,
    String? distanceLabel,
    String? neighborhood,
    List<String>? images,
    String? ownerName,
    String? ownerFullName,
    String? ownerAvatarUrl,
    double? ownerRating,
    int? ownerReviewsCount,
    String? ownerSince,
    bool? isKycVerified,
    bool? hasEscrowGuarantee,
    bool? isQuickPickup,
    double? discountPercentFor3PlusDays,
    String? pickupLocation,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      fullTitle: fullTitle ?? this.fullTitle,
      description: description ?? this.description,
      category: category ?? this.category,
      dailyPrice: dailyPrice ?? this.dailyPrice,
      depositAmount: depositAmount ?? this.depositAmount,
      distanceKm: distanceKm ?? this.distanceKm,
      distanceLabel: distanceLabel ?? this.distanceLabel,
      neighborhood: neighborhood ?? this.neighborhood,
      images: images ?? this.images,
      ownerName: ownerName ?? this.ownerName,
      ownerFullName: ownerFullName ?? this.ownerFullName,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      ownerRating: ownerRating ?? this.ownerRating,
      ownerReviewsCount: ownerReviewsCount ?? this.ownerReviewsCount,
      ownerSince: ownerSince ?? this.ownerSince,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      hasEscrowGuarantee: hasEscrowGuarantee ?? this.hasEscrowGuarantee,
      isQuickPickup: isQuickPickup ?? this.isQuickPickup,
      discountPercentFor3PlusDays: discountPercentFor3PlusDays ?? this.discountPercentFor3PlusDays,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
