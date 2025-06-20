import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<Product, int> _items = {};

  Map<Product, int> get items => _items;

  void addItem(Product product) {
    //_items.update(product.id, (existing) => existing + 1, ifAbsent: () => 1);
    _items.update(product, (existingQty) => existingQty + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void removeItem(Product product) {
    if (!_items.containsKey(product.id)) return;
    final newQty = _items[product.id]! - 1;
    if (newQty <= 0) {
      _items.remove(product.id);
    } else {
      _items[product] = newQty;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int get totalItems => _items.values.fold(0, (sum, q) => sum + q);
}
