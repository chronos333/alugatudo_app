import 'package:flutter_test/flutter_test.dart';
import 'package:alugatudo_app/controllers/aluga_controller.dart';
import 'package:alugatudo_app/models/item_model.dart';
import 'package:alugatudo_app/models/rental_model.dart';
import 'package:alugatudo_app/models/chat_model.dart';

void main() {
  group('AlugaController & Business Logic Tests', () {
    late AlugaController controller;

    setUp(() {
      controller = AlugaController();
    });

    test('Initial state loads filtered items and default user', () {
      expect(controller.filteredItems.isNotEmpty, true);
      expect(controller.user.name, 'Vinicius Pini');
      expect(controller.user.kycStatus, isNotNull);
      expect(controller.selectedItem, isNotNull);
    });

    test('Category filtering updates filteredItems', () {
      controller.setSelectedCategory('Ferramentas');
      expect(controller.selectedCategory, 'Ferramentas');
      for (final item in controller.filteredItems) {
        expect(item.category, 'Ferramentas');
      }

      controller.setSelectedCategory('Todas');
      expect(controller.filteredItems.isNotEmpty, true);
    });

    test('Search query filtering works case-insensitively', () {
      controller.setSearchQuery('furadeira');
      expect(controller.searchQuery, 'furadeira');
      for (final item in controller.filteredItems) {
        final matches = item.title.toLowerCase().contains('furadeira') ||
            item.description.toLowerCase().contains('furadeira');
        expect(matches, true);
      }
    });

    test('Radius filtering restricts maximum distance', () {
      controller.setSelectedRadius(2.0);
      expect(controller.selectedRadiusKm, 2.0);
      for (final item in controller.filteredItems) {
        expect(item.distanceKm <= 2.0, true);
      }
    });

    test('Rentals state and dates update', () {
      expect(controller.allRentals.isNotEmpty, true);
      expect(controller.currentRental.status, RentalStatus.paidConfirmed);

      final start = DateTime(2026, 11, 1);
      final end = DateTime(2026, 11, 5);
      controller.updateDates(start, end);

      expect(controller.currentRental.daysCount, 4);
    });

    test('Chat messaging adds user message', () {
      final initialCount = controller.chatMessages.length;
      controller.sendMessage('Olá, confirmando o horário de retirada.');

      expect(controller.chatMessages.length, initialCount + 1);
      expect(controller.chatMessages.last.text, 'Olá, confirmando o horário de retirada.');
      expect(controller.chatMessages.last.type, MessageType.user);
    });

    test('KYC simulation toggles approval status', () {
      final initialStatus = controller.isKycApproved;
      controller.toggleKycSimulation();
      expect(controller.isKycApproved, !initialStatus);
      controller.toggleKycSimulation();
      expect(controller.isKycApproved, initialStatus);
    });

    test('Creating a new listing adds item to catalog', () {
      final newItem = ItemModel(
        id: 'item_test_new',
        title: 'Câmera Sony Alpha 7 IV',
        fullTitle: 'Câmera Sony Alpha 7 IV Full-Frame 4K',
        description: 'Sensor de 33MP e gravação 4K 60p.',
        category: 'Eletrônicos & Câmeras',
        dailyPrice: 180.0,
        depositAmount: 3000.0,
        distanceKm: 0.8,
        distanceLabel: '800 m de você',
        neighborhood: 'Pinheiros',
        images: ['https://example.com/sony.jpg'],
        ownerName: 'Você',
        ownerFullName: 'Vinicius Pini',
        ownerAvatarUrl: 'https://example.com/avatar.jpg',
        ownerRating: 5.0,
        ownerReviewsCount: 1,
        ownerSince: 'Desde 2026',
        pickupLocation: 'Pinheiros, SP',
        tags: ['Câmera', 'Sony'],
      );

      controller.createNewListing(newItem);
      controller.setSelectedCategory('Todas');
      controller.setSearchQuery('');
      controller.setSelectedRadius(20.0);
      expect(controller.filteredItems.any((it) => it.id == 'item_test_new'), true);
    });
  });
}
