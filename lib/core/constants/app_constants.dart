class AppConstants {
  static const String promoCode = 'PAYDAY';
  static const double promoDiscount = 0.10;
  static const int deliveryFee = 12000;
  static const int freeDeliveryMinimum = 100000;

  static const String defaultAddressLabel = 'Kost athena';
  static const String defaultAddressDetail = 'Jl. Imam Bonjol No. 5, Semarang';

  static const Map<int, String> vegetableImages = {
    1: 'asset/image/vegetables/1.jpg',
    2: 'asset/image/vegetables/2.jpg',
    3: 'asset/image/vegetables/3.jpg',
    4: 'asset/image/vegetables/4.jpg',
    5: 'asset/image/vegetables/5.jpg',
    6: 'asset/image/vegetables/6.jpg',
    7: 'asset/image/vegetables/7.jpg',
    8: 'asset/image/vegetables/8.jpg',
    9: 'asset/image/vegetables/9.jpg',
    10: 'asset/image/vegetables/10.jpg',
    11: 'asset/image/vegetables/11.jpg',
    12: 'asset/image/vegetables/12.jpg',
    13: 'asset/image/vegetables/13.jpg',
    14: 'asset/image/vegetables/14.jpg',
    15: 'asset/image/vegetables/15.jpg',
  };

  static const Map<String, String> categoryLabels = {
    'Sayuran Daun': 'Leafy greens',
    'Sayuran Buah': 'Fruit veggies',
    'Sayuran Umbi': 'Root veggies',
    'Sayuran Polong': 'Pods',
  };

  static const Map<String, String> categoryShortLabels = {
    'Sayuran Daun': 'Leafy',
    'Sayuran Buah': 'Fruit',
    'Sayuran Umbi': 'Root',
    'Sayuran Polong': 'Pods',
  };

  static const List<String> categories = [
    'Sayuran Daun',
    'Sayuran Buah',
    'Sayuran Umbi',
    'Sayuran Polong',
  ];

  static String? imageFor(int id) => vegetableImages[id];

  static String categoryLabel(String category) =>
      categoryLabels[category] ?? category;

  static String categoryShortLabel(String category) =>
      categoryShortLabels[category] ?? category;
}
