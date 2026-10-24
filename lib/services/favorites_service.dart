import 'package:flutter/foundation.dart';

import '../models/vegetable.dart';

class FavoritesService extends ChangeNotifier {
  final Map<int, Vegetable> _items = {};

  List<Vegetable> get items => List.unmodifiable(_items.values);

  int get count => _items.length;

  bool isFavorite(int id) => _items.containsKey(id);

  void toggle(Vegetable vegetable) {
    if (_items.remove(vegetable.id) == null) {
      _items[vegetable.id] = vegetable;
    }
    notifyListeners();
  }
}
