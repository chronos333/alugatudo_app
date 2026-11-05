import '../models/item_model.dart';
import 'mock_data_service.dart';

class ItemService {
  List<ItemModel> _items = MockDataService.getInitialItems();

  List<ItemModel> getAllItems() {
    return List.unmodifiable(_items);
  }

  ItemModel? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  void toggleFavorite(String itemId) {
    _items = _items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isFavorite: !item.isFavorite);
      }
      return item;
    }).toList();
  }

  void addItem(ItemModel newItem) {
    _items.insert(0, newItem);
  }

  List<ItemModel> filterItems({
    required String query,
    required String category,
    required double maxRadiusKm,
  }) {
    return _items.where((item) {
      // Category filter
      if (category != 'Todas' && item.category != category) {
        return false;
      }

      // Radius filter
      if (item.distanceKm > maxRadiusKm) {
        return false;
      }

      // Query filter
      if (query.trim().isNotEmpty) {
        final q = query.toLowerCase().trim();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchDesc = item.description.toLowerCase().contains(q);
        final matchCat = item.category.toLowerCase().contains(q);
        final matchTags = item.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchTitle && !matchDesc && !matchCat && !matchTags) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
