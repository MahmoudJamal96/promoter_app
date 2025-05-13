import '../../../core/network/api_client.dart';
import '../../../core/di/injection_container.dart';
import '../models/sales_invoice_model.dart';

class SalesInvoiceService {
  final ApiClient _apiClient;

  SalesInvoiceService({ApiClient? apiClient}) : _apiClient = apiClient ?? sl();
  Future<Map<String, dynamic>> createInvoice({
    required int clientId,
    required String paymentMethod,
    required String notes,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final data = {
        'client_id': clientId,
        'payment_method': paymentMethod,
        'notes': notes,
        'items': items,
      };

      final response = await _apiClient.post(
        '/create-order',
        data: data,
      );

      return response;
    } catch (e) {
      print('Error creating invoice: $e');
      rethrow;
    }
  }

  Future<List<SalesInvoice>> getInvoices({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        '/orders',
        queryParameters: {'page': page},
      );

      if (response == null) {
        print('API returned null response for getInvoices');
        return [];
      }

      final List<dynamic> invoices = response['data'] ?? [];
      return invoices.map((json) => SalesInvoice.fromJson(json)).toList();
    } catch (e) {
      print('Error getting invoices: $e');
      rethrow;
    }
  }

  Future<SalesInvoice> getInvoiceDetails(int invoiceId) async {
    try {
      final response = await _apiClient.get('/order/$invoiceId');

      if (response == null) {
        throw Exception('API returned null response for invoice $invoiceId');
      }

      return SalesInvoice.fromJson(response);
    } catch (e) {
      print('Error getting invoice details: $e');
      rethrow;
    }
  }
}
