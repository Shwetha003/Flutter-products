import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, int> _items = {};

  Map<String, int> get items => _items;

  void addItem(Product product) {
    //_items.update(product.id, (existing) => existing + 1, ifAbsent: () => 1);
    _items.add(product);
    notifyListeners();
  }

  void removeItem(Product product) {
    if (!_items.containsKey(product.id)) return;
    final newQty = _items[product.id]! - 1;
    if (newQty <= 0) {
      _items.remove(product.id);
    } else {
      _items[product.id] = newQty;
    }
    notifyListeners();
  }
  /*void removeItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(product.id, (existing) => existing - 1);
      if (_items[product.id]! <= 0) {
        _items.remove(product.id);
      }
      notifyListeners();
    }
  }
  */

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int get totalItems => _items.values.fold(0, (sum, q) => sum + q);
}
