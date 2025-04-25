// Model class for Products
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final String imageUrl;
  final String barcode;
  final String location;
  final String supplier;
  final DateTime lastUpdated;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.barcode,
    required this.location,
    required this.supplier,
    required this.lastUpdated,
  });

  // Copy with method for easy updates
  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? quantity,
    String? imageUrl,
    String? barcode,
    String? location,
    String? supplier,
    DateTime? lastUpdated,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      location: location ?? this.location,
      supplier: supplier ?? this.supplier,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
