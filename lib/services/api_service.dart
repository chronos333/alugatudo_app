import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import '../models/rental_model.dart';
import '../models/chat_model.dart';
import 'mock_data_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  static final http.Client _client = http.Client();

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-User-Id': 'usr_001',
      };

  // 1. Catálogo de Itens
  static Future<List<ItemModel>> getItems({
    String query = '',
    String category = 'Todas',
    double maxRadius = 50.0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/items').replace(queryParameters: {
        if (query.isNotEmpty) 'query': query,
        if (category != 'Todas') 'category': category,
        'maxRadius': maxRadius.toString(),
      });

      final response = await _client.get(uri, headers: _headers).timeout(
            const Duration(seconds: 4),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data']['items'] != null) {
          final List list = data['data']['items'];
          return list.map((jsonItem) => _parseItem(jsonItem)).toList();
        }
      }
    } catch (_) {
      // Fallback seguro offline
    }
    return MockDataService.getInitialItems();
  }

  // 2. Criar Nova Reserva & Escrow
  static Future<RentalModel?> createRental({
    required String itemId,
    required DateTime startDate,
    required DateTime endDate,
    required FreightType freightType,
    required PaymentMethodType paymentMethod,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/rentals'),
        headers: _headers,
        body: json.encode({
          'itemId': itemId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
          'freightType': freightType.name,
          'paymentMethod': paymentMethod.name,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return _parseRental(data['data']['rental']);
        }
      }
    } catch (_) {
      // Fallback
    }
    return null;
  }

  // 3. Validar PIN de Entrega
  static Future<bool> verifyDeliveryPin(String rentalId, String pin) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/rentals/$rentalId/verify-pin'),
        headers: _headers,
        body: json.encode({'pin': pin}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (_) {
      // Fallback
    }
    return false;
  }

  // 4. Mensagens do Chat
  static Future<List<ChatMessage>> getChatMessages(String rentalId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/chat/$rentalId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data']['messages'] != null) {
          final List list = data['data']['messages'];
          return list.map((m) => _parseChatMessage(m)).toList();
        }
      }
    } catch (_) {
      // Fallback
    }
    return [];
  }

  static Future<bool> sendChatMessage(String rentalId, String text) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/chat/$rentalId'),
        headers: _headers,
        body: json.encode({'text': text}),
      );
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // Parsers
  static ItemModel _parseItem(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['images'] is List) {
      images = List<String>.from(json['images']);
    } else if (json['images_json'] is String) {
      try {
        images = List<String>.from(jsonDecode(json['images_json']));
      } catch (_) {}
    }

    return ItemModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      fullTitle: json['full_title'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Ferramentas',
      dailyPrice: (json['daily_price'] as num?)?.toDouble() ?? 50.0,
      depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 500.0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 1.0,
      distanceLabel: json['distance_label'] ?? '1 km de você',
      neighborhood: json['neighborhood'] ?? 'Pinheiros, SP',
      images: images.isNotEmpty ? images : ['https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80'],
      ownerName: json['owner_name'] ?? 'Lucas Mendes',
      ownerFullName: json['owner_name'] ?? 'Lucas Mendes',
      ownerAvatarUrl: json['owner_avatar'] ?? '',
      ownerRating: (json['owner_rating'] as num?)?.toDouble() ?? 5.0,
      ownerReviewsCount: (json['owner_reviews_count'] as num?)?.toInt() ?? 10,
      ownerSince: json['owner_since'] ?? 'Desde 2024',
      isKycVerified: json['is_kyc_verified'] == true || json['is_kyc_verified'] == 1,
      hasEscrowGuarantee: json['has_escrow_guarantee'] != false && json['has_escrow_guarantee'] != 0,
      isQuickPickup: json['is_quick_pickup'] == true || json['is_quick_pickup'] == 1,
      discountPercentFor3PlusDays: (json['discount_percent_3plus'] as num?)?.toDouble() ?? 15.0,
      pickupLocation: json['pickup_location'] ?? 'Pinheiros, SP',
      tags: json['tags'] is List ? List<String>.from(json['tags']) : ['Aluguel Seguro'],
    );
  }

  static RentalModel _parseRental(Map<String, dynamic> json) {
    FreightType freight = FreightType.pickup;
    if (json['freight_type'] == 'hostDelivery') freight = FreightType.hostDelivery;
    if (json['freight_type'] == 'courier') freight = FreightType.courier;

    RentalStatus status = RentalStatus.paidConfirmed;
    if (json['rental_status'] == 'inProgress') status = RentalStatus.inProgress;
    if (json['rental_status'] == 'completed') status = RentalStatus.completed;

    return RentalModel(
      id: json['id'] ?? 'rent_01',
      itemId: json['item_id'] ?? 'item_01',
      itemTitle: json['item_title'] ?? 'Equipamento',
      itemImageUrl: json['item_images'] != null && (json['item_images'] as List).isNotEmpty
          ? (json['item_images'] as List).first
          : 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80',
      ownerName: json['host_name'] ?? 'Lucas Mendes',
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now().add(const Duration(days: 3)),
      daysCount: (json['days_count'] as num?)?.toInt() ?? 3,
      dailyRate: (json['daily_price'] as num?)?.toDouble() ?? 100.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['service_fee'] as num?)?.toDouble() ?? 10.0,
      freightType: freight,
      depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 1000.0,
      status: status,
      paymentMethod: json['payment_method'] == 'pix' ? PaymentMethodType.pix : PaymentMethodType.creditCard,
      pinCode: json['delivery_pin'] ?? '482910',
      inspectionPhotos: [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  static ChatMessage _parseChatMessage(Map<String, dynamic> json) {
    MessageType type = MessageType.user;
    if (json['sender_type'] == 'host') type = MessageType.host;
    if (json['sender_type'] == 'system') type = MessageType.system;
    if (json['sender_type'] == 'inspectionCard') type = MessageType.inspectionCard;

    return ChatMessage(
      id: json['id'] ?? '',
      type: type,
      senderName: json['sender_name'] ?? 'Sistema',
      text: json['message'] ?? '',
      timestamp: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
