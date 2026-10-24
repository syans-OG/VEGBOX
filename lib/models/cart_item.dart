import 'vegetable.dart';

class CartItem {
  const CartItem({
    required this.vegetableId,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.imageAsset,
    required this.imageUrl,
  });

  final int vegetableId;
  final String name;
  final String category;
  final int price;
  final int quantity;
  final String? imageAsset;
  final String imageUrl;

  int get lineTotal => price * quantity;

  factory CartItem.fromVegetable(Vegetable vegetable, {int quantity = 1}) {
    return CartItem(
      vegetableId: vegetable.id,
      name: vegetable.name,
      category: vegetable.category,
      price: vegetable.price,
      quantity: quantity,
      imageAsset: vegetable.localImage,
      imageUrl: vegetable.imageUrl,
    );
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      vegetableId: vegetableId,
      name: name,
      category: category,
      price: price,
      quantity: quantity ?? this.quantity,
      imageAsset: imageAsset,
      imageUrl: imageUrl,
    );
  }
}
