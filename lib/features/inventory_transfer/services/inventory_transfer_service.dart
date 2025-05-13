import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/di/injection_container.dart';
import '../models/inventory_transfer_model.dart';

class InventoryTransferService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  InventoryTransferService({ApiClient? apiClient})
      : _apiClient = apiClient ?? sl();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<InventoryTransfer> requestTransfer({
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    final data = {
      'items': items, // Each item should have product_id and quantity
      if (notes != null) 'notes': notes,
    };

    final response = await _apiClient.post(
      '/inventory/request-transfer',
      data: data,
    );

    return InventoryTransfer.fromJson(response);
  }

  Future<InventoryTransfer> requestReturn({
    required List<Map<String, dynamic>> items,
    String? reason,
    String? notes,
  }) async {
    final data = {
      'items': items, // Each item should have product_id and quantity
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
    };

    final response = await _apiClient.post(
      '/inventory/request-return',
      data: data,
    );

    return InventoryTransfer.fromJson(response);
  }

  Future<List<InventoryTransfer>> getPendingRequests({int page = 1}) async {
    final response = await _apiClient.get(
      '/inventory/pending-requests',
      queryParameters: {'page': page},
    );

    final List<dynamic> transfers = response['data'] ?? [];
    return transfers.map((json) => InventoryTransfer.fromJson(json)).toList();
  }

  Future<List<InventoryTransfer>> getAllTransfers({
    int page = 1,
    String? status,
    String? type,
  }) async {
    final queryParams = <String, dynamic>{'page': page};

    if (status != null) queryParams['status'] = status;
    if (type != null) queryParams['type'] = type;

    final response = await _apiClient.get(
      '/inventory/transfers',
      queryParameters: queryParams,
    );

    final List<dynamic> transfers = response['data'] ?? [];
    return transfers.map((json) => InventoryTransfer.fromJson(json)).toList();
  }
}
