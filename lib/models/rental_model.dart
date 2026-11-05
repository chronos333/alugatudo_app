enum RentalStatus {
  requested,
  paidConfirmed,
  inProgress,
  completed,
}

extension RentalStatusExt on RentalStatus {
  String get label {
    switch (this) {
      case RentalStatus.requested:
        return 'SOLICITADO';
      case RentalStatus.paidConfirmed:
        return 'PAGO & CONFIRMADO';
      case RentalStatus.inProgress:
        return 'EM CURSO';
      case RentalStatus.completed:
        return 'FINALIZADO';
    }
  }

  String get codeTag {
    switch (this) {
      case RentalStatus.requested:
        return '[REQUESTED]';
      case RentalStatus.paidConfirmed:
        return '[PAID_CONFIRMED]';
      case RentalStatus.inProgress:
        return '[IN_PROGRESS]';
      case RentalStatus.completed:
        return '[COMPLETED]';
    }
  }
}

enum FreightType {
  pickup,
  hostDelivery,
  courier,
}

extension FreightTypeExt on FreightType {
  String get title {
    switch (this) {
      case FreightType.pickup:
        return 'Retirada no Local';
      case FreightType.hostDelivery:
        return 'Entrega pelo Dono';
      case FreightType.courier:
        return 'Envio Uber Flash / Loggi';
    }
  }

  String get subtitle {
    switch (this) {
      case FreightType.pickup:
        return 'Estação Faria Lima (Linha Amarela)';
      case FreightType.hostDelivery:
        return 'Lucas leva em mãos até você';
      case FreightType.courier:
        return 'Coleta rápida com rastreio em tempo real';
    }
  }

  double get cost {
    switch (this) {
      case FreightType.pickup:
        return 0.0;
      case FreightType.hostDelivery:
        return 25.0;
      case FreightType.courier:
        return 35.0;
    }
  }

  String get costLabel {
    if (cost == 0) return 'Grátis';
    return '+ R\$ ${cost.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

enum PaymentMethodType {
  creditCard,
  pix,
}

class InspectionPhoto {
  final String id;
  final String title;
  final String label;
  final String imageUrl;
  final DateTime timestamp;

  InspectionPhoto({
    required this.id,
    required this.title,
    required this.label,
    required this.imageUrl,
    required this.timestamp,
  });
}

class RentalModel {
  final String id;
  final String itemId;
  final String itemTitle;
  final String itemImageUrl;
  final String ownerName;
  final DateTime startDate;
  final DateTime endDate;
  final int daysCount;
  final double dailyRate;
  final double discountAmount;
  final double platformFee;
  FreightType freightType;
  final double depositAmount;
  RentalStatus status;
  PaymentMethodType paymentMethod;
  final String pinCode;
  final List<InspectionPhoto> inspectionPhotos;
  final DateTime createdAt;

  RentalModel({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.itemImageUrl,
    required this.ownerName,
    required this.startDate,
    required this.endDate,
    required this.daysCount,
    required this.dailyRate,
    required this.discountAmount,
    required this.platformFee,
    this.freightType = FreightType.pickup,
    required this.depositAmount,
    this.status = RentalStatus.requested,
    this.paymentMethod = PaymentMethodType.creditCard,
    required this.pinCode,
    required this.inspectionPhotos,
    required this.createdAt,
  });

  double get subtotal => daysCount * dailyRate;
  double get freightCost => freightType.cost;
  double get totalAmount => subtotal - discountAmount + platformFee + freightCost;

  RentalModel copyWith({
    String? id,
    String? itemId,
    String? itemTitle,
    String? itemImageUrl,
    String? ownerName,
    DateTime? startDate,
    DateTime? endDate,
    int? daysCount,
    double? dailyRate,
    double? discountAmount,
    double? platformFee,
    FreightType? freightType,
    double? depositAmount,
    RentalStatus? status,
    PaymentMethodType? paymentMethod,
    String? pinCode,
    List<InspectionPhoto>? inspectionPhotos,
    DateTime? createdAt,
  }) {
    return RentalModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemTitle: itemTitle ?? this.itemTitle,
      itemImageUrl: itemImageUrl ?? this.itemImageUrl,
      ownerName: ownerName ?? this.ownerName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      daysCount: daysCount ?? this.daysCount,
      dailyRate: dailyRate ?? this.dailyRate,
      discountAmount: discountAmount ?? this.discountAmount,
      platformFee: platformFee ?? this.platformFee,
      freightType: freightType ?? this.freightType,
      depositAmount: depositAmount ?? this.depositAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      pinCode: pinCode ?? this.pinCode,
      inspectionPhotos: inspectionPhotos ?? this.inspectionPhotos,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
