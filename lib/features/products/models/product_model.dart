class Product {
  final int id;
  final String name;
  final String sku;
  final String barcode;
  final double price;
  final int quantity;
  final String? imageUrl;
  final int categoryId;
  final String categoryName;
  final int? companyId;
  final String? companyName;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.price,
    required this.quantity,
    this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    this.companyId,
    this.companyName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      barcode: json['barcode'] ?? json['barcode_number'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? "0") ?? 0,
      quantity: int.tryParse(json['quantity']?.toString() ??
              json['stock']?.toString() ??
              json['current_stock']?.toString() ??
              '0') ??
          0,
      imageUrl: json['image_url'] as String? ?? '',
      categoryId: json['category_id'] as int? ?? 0,
      categoryName: json['category_name'] as String? ?? '',
      companyId: json['company_id'] as int?,
      companyName: json['company_name'] as String?,
      createdAt: json['created_at'] as String? ?? "",
      updatedAt: json['updated_at'] as String? ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
      'category_id': categoryId,
      'category_name': categoryName,
      'company_id': companyId,
      'company_name': companyName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ProductCategory {
  final int id;
  final String name;

  ProductCategory({
    required this.id,
    required this.name,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class ProductCompany {
  final int id;
  final String name;

  ProductCompany({
    required this.id,
    required this.name,
  });

  factory ProductCompany.fromJson(Map<String, dynamic> json) {
    return ProductCompany(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
