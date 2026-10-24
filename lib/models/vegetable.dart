import '../core/constants/app_constants.dart';

class Vegetable {
  const Vegetable({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  final int id;
  final String name;
  final String category;
  final int price;
  final String imageUrl;
  final String description;

  String? get localImage => AppConstants.imageFor(id);

  String get categoryLabel => AppConstants.categoryLabel(category);

  factory Vegetable.fromJson(Map<String, dynamic> json) {
    final id = json['id'] is num
        ? (json['id'] as num).toInt()
        : int.tryParse(json['id']?.toString() ?? '') ?? 0;
    final name = json['nama']?.toString().trim() ?? '';
    final price = json['harga'] is num
        ? (json['harga'] as num).toInt()
        : int.tryParse(json['harga']?.toString() ?? '') ?? 0;

    if (id <= 0 || name.isEmpty || price <= 0) {
      throw FormatException(
        'Data sayuran tidak valid (id: $id, nama: "$name", harga: $price).',
      );
    }

    return Vegetable(
      id: id,
      name: name,
      category: json['kategori']?.toString() ?? '',
      price: price,
      imageUrl: json['gambar']?.toString() ?? '',
      description: json['deskripsi']?.toString() ?? '',
    );
  }

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return name.toLowerCase().contains(normalized) ||
        description.toLowerCase().contains(normalized) ||
        category.toLowerCase().contains(normalized);
  }
}
