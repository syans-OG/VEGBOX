import 'package:flutter/material.dart';
import 'package:vegbox/core/di/injection.dart';
import 'package:vegbox/models/cart_item.dart';
import 'package:vegbox/models/vegetable.dart';
import 'package:vegbox/ui/theme.dart';

const testVegetable = Vegetable(
  id: 1,
  name: 'Bayam Hijau',
  category: 'Sayuran Daun',
  price: 3500,
  imageUrl: '',
  description: 'Bayam segar dari petani lokal.',
);

const testCartItem = CartItem(
  vegetableId: 1,
  name: 'Bayam Hijau',
  category: 'Sayuran Daun',
  price: 3500,
  quantity: 2,
  imageAsset: 'asset/image/vegetables/1.jpg',
  imageUrl: '',
);

Future<void> resetApp() async {
  await getIt.reset();
  setupLocator();
}

Widget appWith(Widget home) {
  return MaterialApp(theme: buildAppTheme(), home: home);
}
