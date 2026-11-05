import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../models/rental_model.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../services/item_service.dart';
import '../services/rental_service.dart';
import '../services/chat_service.dart';
import '../services/kyc_service.dart';

enum ViewMode { list, map }

class AlugaController extends ChangeNotifier {
  final ItemService _itemService = ItemService();
  final RentalService _rentalService = RentalService();
  final ChatService _chatService = ChatService();
  final KycService _kycService = KycService();

  // Navigation State
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  // Search & Filter State
  String _searchQuery = '';
  String _selectedCategory = 'Todas';
  double _selectedRadiusKm = 5.0;
  ViewMode _viewMode = ViewMode.list;
  bool _showSkeletonPreview = false;

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  double get selectedRadiusKm => _selectedRadiusKm;
  ViewMode get viewMode => _viewMode;
  bool get showSkeletonPreview => _showSkeletonPreview;

  // Detail View State
  ItemModel? _selectedItem;
  ItemModel? get selectedItem => _selectedItem;

  // User & KYC
  UserModel get user => _kycService.getCurrentUser();
  bool get isKycApproved => user.kycStatus.isApproved;

  // Rental & Checkout
  RentalModel get currentRental => _rentalService.getCurrentRental();
  List<RentalModel> get allRentals => _rentalService.getAllRentals();

  // Chat
  List<ChatMessage> get chatMessages => _chatService.getMessages();

  // Checkout Loading
  bool _isProcessingCheckout = false;
  bool get isProcessingCheckout => _isProcessingCheckout;

  // Categories list
  final List<String> categories = const [
    'Todas',
    'Ferramentas',
    'Eletrônicos & Câmeras',
    'Festas & Eventos',
    'Esportes',
    'Moda',
  ];

  // Available Radius options
  final List<double> radiusOptions = const [2.0, 5.0, 10.0, 20.0];

  AlugaController() {
    _selectedItem = _itemService.getItemById('item_01');
  }

  // Filtered Items
  List<ItemModel> get filteredItems {
    return _itemService.filterItems(
      query: _searchQuery,
      category: _selectedCategory,
      maxRadiusKm: _selectedRadiusKm,
    );
  }

  // Tab Navigation
  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Filter Actions
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedRadius(double radiusKm) {
    _selectedRadiusKm = radiusKm;
    notifyListeners();
  }

  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void toggleSkeletonPreview() {
    _showSkeletonPreview = !_showSkeletonPreview;
    notifyListeners();
  }

  // Item Selection & Wishlist
  void selectItem(ItemModel item) {
    _selectedItem = item;
    notifyListeners();
  }

  void toggleFavorite(String itemId) {
    _itemService.toggleFavorite(itemId);
    if (_selectedItem?.id == itemId) {
      _selectedItem = _selectedItem!.copyWith(
        isFavorite: !_selectedItem!.isFavorite,
      );
    }
    notifyListeners();
  }

  void createNewListing(ItemModel newItem) {
    _itemService.addItem(newItem);
    notifyListeners();
  }

  // Logistics & Pricing
  void updateFreightType(FreightType type) {
    _rentalService.updateFreightType(type);
    notifyListeners();
  }

  void updateDates(DateTime start, DateTime end) {
    _rentalService.updateDates(start, end);
    notifyListeners();
  }

  void updatePaymentMethod(PaymentMethodType method) {
    _rentalService.updatePaymentMethod(method);
    notifyListeners();
  }

  // KYC Flow
  void toggleKycSimulation() {
    _kycService.toggleKycStatus();
    notifyListeners();
  }

  Future<void> submitKycVerification() async {
    await _kycService.submitKycVerification();
    notifyListeners();
  }

  void updateLocation(String city, String neighborhood) {
    _kycService.updateLocation(city, neighborhood);
    notifyListeners();
  }

  // Checkout Execution
  Future<bool> processCheckout() async {
    _isProcessingCheckout = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1400));

    _rentalService.updateRentalStatus(RentalStatus.paidConfirmed);
    _isProcessingCheckout = false;
    notifyListeners();
    return true;
  }

  // Chat Actions
  void sendMessage(String text) {
    _chatService.addUserMessage(text);
    notifyListeners();

    // Friendly automated host response after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (text.toLowerCase().contains('horário') ||
          text.toLowerCase().contains('horas') ||
          text.toLowerCase().contains('estação')) {
        _chatService.addHostResponse(
          'Combinado! Estarei na catraca principal da Estação Pinheiros às 10h pontualmente.',
        );
      } else {
        _chatService.addHostResponse(
          'Entendido! Qualquer dúvida adicional pode me chamar por aqui.',
        );
      }
      notifyListeners();
    });
  }

  void sendInspectionPhoto() {
    _chatService.addInspectionPhotoMessage();
    notifyListeners();
  }
}
