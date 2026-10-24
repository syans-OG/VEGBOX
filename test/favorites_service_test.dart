import 'package:flutter_test/flutter_test.dart';
import 'package:vegbox/models/vegetable.dart';
import 'package:vegbox/services/favorites_service.dart';

const _vegetable = Vegetable(
  id: 1,
  name: 'Bayam Hijau',
  category: 'Sayuran Daun',
  price: 3500,
  imageUrl: '',
  description: 'Bayam segar.',
);

void main() {
  test('toggle adds and removes a favorite', () {
    final favorites = FavoritesService();

    expect(favorites.isFavorite(_vegetable.id), isFalse);
    expect(favorites.count, 0);

    favorites.toggle(_vegetable);
    expect(favorites.isFavorite(_vegetable.id), isTrue);
    expect(favorites.count, 1);
    expect(favorites.items.single.name, 'Bayam Hijau');

    favorites.toggle(_vegetable);
    expect(favorites.isFavorite(_vegetable.id), isFalse);
    expect(favorites.count, 0);
  });
}
