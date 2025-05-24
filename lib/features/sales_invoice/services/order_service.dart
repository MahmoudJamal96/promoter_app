import '../../../core/network/api_client.dart';
import '../../../core/di/injection_container.dart';
import '../../inventory/services/inventory_service.dart' as inventory;
import '../models/sales_invoice_model.dart';

class OrderService {
  final ApiClient _apiClient;

  OrderService({ApiClient? apiClient}) : _apiClient = apiClient ?? sl();
  // Create a new order/invoice
  Future<SalesInvoice> createOrder({
    required List<inventory.SalesItem> items,
    required String customerName,
    required String customerPhone,
    required inventory.PaymentMethod paymentMethod,
    required double discount,
    int clientId = 1,
  }) async {
    try {
      // Format items as required by the API
      final List<Map<String, dynamic>> apiItems = items
          .map((item) => {
                'product_id': int.parse(item.product.id),
                'quantity': item.quantity
              })
          .toList(); // Set the payment method string
      String paymentMethodStr;
      switch (paymentMethod) {
        case inventory.PaymentMethod.cash:
          paymentMethodStr = 'cash';
          break;
        case inventory.PaymentMethod.creditCard:
          paymentMethodStr = 'credit_card';
          break;
        case inventory.PaymentMethod.bankTransfer:
          paymentMethodStr = 'bank_transfer';
          break;
        case inventory.PaymentMethod.check:
          paymentMethodStr = 'check';
          break;
        default:
          paymentMethodStr = 'cash'; // Default to cash
      }

      // Prepare the request data
      final Map<String, dynamic> requestData = {
        'client_id': clientId,
        'payment_method': paymentMethodStr,
        'notes': 'Customer: $customerName, Phone: $customerPhone',
        'items': apiItems,
      };

      // Make the API call
      final response = await _apiClient.post(
        '/create-order',
        data: requestData,
      );

      // Handle the response
      if (response == null) {
        throw Exception('Failed to create order: Empty response');
      }

      // For debugging
      print('Order created successfully: $response');

      // Return the created invoice
      return SalesInvoice.fromJson(response);
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  // Get an order/invoice by ID
  Future<SalesInvoice> getOrder(int orderId) async {
    try {
      final response = await _apiClient.get('/order/$orderId');

      if (response == null) {
        throw Exception('Failed to get order: Empty response');
      }

      return SalesInvoice.fromJson(response);
    } catch (e) {
      print('Error getting order details: $e');
      rethrow;
    }
  }
}
