import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/di/injection_container.dart';
import '../models/collection_model.dart';

class CollectionService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  CollectionService({ApiClient? apiClient}) : _apiClient = apiClient ?? sl();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Collection> createCollection({
    required int clientId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    final data = {
      'client_id': clientId,
      'amount': amount,
      'payment_method': paymentMethod,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (notes != null) 'notes': notes,
    };

    final response = await _apiClient.post(
      '/collections',
      data: data,
    );

    return Collection.fromJson(response);
  }

  Future<List<Collection>> getCollections({int page = 1, int? clientId}) async {
    final queryParams = {
      'page': page,
      if (clientId != null) 'client_id': clientId,
    };

    final response = await _apiClient.get(
      '/collections',
      queryParameters: queryParams,
    );

    final List<dynamic> collections = response['data'] ?? [];
    return collections.map((json) => Collection.fromJson(json)).toList();
  }
}
