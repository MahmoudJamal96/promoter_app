import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/di/injection_container.dart';
import '../models/product_model.dart';

class ProductsService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ProductsService({ApiClient? apiClient}) : _apiClient = apiClient ?? sl();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<List<Product>> getProducts(
      {int page = 1, int? categoryId, int? companyId, String? search}) async {
    final queryParams = <String, dynamic>{'page': page};

    // if (categoryId != null) queryParams['category_id'] = categoryId;
    if (companyId != null) queryParams['company_id'] = companyId;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _apiClient.get(
      categoryId != null ? '/products/$categoryId/related' : '/products',
      queryParameters: queryParams,
    );

    final List<dynamic> products = response['data'] ?? [];
    return products.map((json) => Product.fromJson(json)).toList();
  }

  /*Future<List<Product>> searchProducts(String query) async {
    final response = await _apiClient.post(
      '/products/search',
      data: {'query': query},
    );

    final List<dynamic> products = response['data'] ?? [];
    return products.map((json) => Product.fromJson(json)).toList();
  }*/
  // Scan product by barcode/sku/name
  Future<List<Product>> scanProduct(
      {String? sku, String? name, String? barcode}) async {
    final formData = <String, dynamic>{};
    if (sku != null && sku.isNotEmpty) formData['sku'] = sku;
    if (name != null && name.isNotEmpty) formData['name'] = name;
    if (barcode != null && barcode.isNotEmpty) formData['barcode'] = barcode;

    final response = await _apiClient.post(
      '/products/scan',
      data: formData,
    );

    // Check if response contains success status and data
    if (response['success'] == true && response['data'] != null) {
      // Handle case where data is a single product object
      final productData = response['data'];
      if (productData is Map<String, dynamic>) {
        // Single product returned
        return [Product.fromJson(productData)];
      } else if (productData is List) {
        // Multiple products returned (in case API changes)
        return productData.map((json) => Product.fromJson(json)).toList();
      }
    }

    // Return empty list if no valid data found
    return [];
  }

  // Get related products for a specific product
  Future<List<Product>> getRelatedProducts(int productId) async {
    final response = await _apiClient.get('/products/$productId/related');
    final List<dynamic> products = response['data'] ?? [];
    return products.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product> getProductById(int productId) async {
    final response = await _apiClient.get('/products/$productId/related');
    return Product.fromJson(response);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _apiClient.get('/get-categories');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getCompanies() async {
    final response = await _apiClient.get('/companies');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }
}
