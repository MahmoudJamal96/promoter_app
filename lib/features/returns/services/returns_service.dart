import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/di/injection_container.dart';
import '../models/return_model.dart';

class ReturnsService {
  final ApiClient _apiClient;

  ReturnsService({ApiClient? apiClient}) : _apiClient = apiClient ?? sl();

  Future<ReturnOrder> createReturnFromInvoice({
    required int invoiceId,
    required List<Map<String, dynamic>> items,
    String? reason,
    String? notes,
  }) async {
    final data = {
      'invoice_id': invoiceId,
      'items': items, // Each item should have product_id and quantity
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
    };

    final response = await _apiClient.post(
      '/returns/invoice',
      data: data,
    );

    return ReturnOrder.fromJson(response);
  }

  Future<ReturnOrder> createStandaloneReturn({
    required int clientId,
    required List<Map<String, dynamic>> items,
    String? reason,
    String? notes,
  }) async {
    final data = {
      'client_id': clientId,
      'items': items, // Each item should have product_id and quantity
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
    };

    final response = await _apiClient.post(
      '/returns/standalone',
      data: data,
    );

    return ReturnOrder.fromJson(response);
  }

  Future<List<ReturnOrder>> getReturns({int page = 1}) async {
    final response = await _apiClient.get(
      '/returns',
      queryParameters: {'page': page},
    );

    final List<dynamic> returns = response['data'] ?? [];
    return returns.map((json) => ReturnOrder.fromJson(json)).toList();
  }

  Future<ReturnOrder> getReturnDetails(int returnId) async {
    final response = await _apiClient.get('/returns/$returnId');
    return ReturnOrder.fromJson(response);
  }
}
