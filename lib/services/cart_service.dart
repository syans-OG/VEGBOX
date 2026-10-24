import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/vegetable.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => _items.fold(0, (sum, item) => sum + item.lineTotal);

  int quantityOf(int vegetableId) {
    for (final item in _items) {
      if (item.vegetableId == vegetableId) return item.quantity;
    }
    return 0;
  }

  void add(Vegetable vegetable, {int quantity = 1}) {
    addItem(CartItem.fromVegetable(vegetable, quantity: quantity));
  }

  void addItem(CartItem newItem) {
    final index = _items.indexWhere(
      (item) => item.vegetableId == newItem.vegetableId,
    );
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + newItem.quantity,
      );
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  void setQuantity(int vegetableId, int quantity) {
    final index = _items.indexWhere((item) => item.vegetableId == vegetableId);
    if (index < 0) return;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void remove(int vegetableId) {
    _items.removeWhere((item) => item.vegetableId == vegetableId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
