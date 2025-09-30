import '../../../core/di/injection_container.dart';
import '../../../core/network/api_client.dart';
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
          .map((item) => {'product_id': int.parse(item.product.id), 'quantity': item.quantity})
          .toList(); // Set the payment method string
      String paymentMethodStr;
      switch (paymentMethod) {
        case inventory.PaymentMethod.cash:
          paymentMethodStr = 'cash';
          break;
        case inventory.PaymentMethod.credit:
          paymentMethodStr = 'deferred';
          break;
        case inventory.PaymentMethod.bank:
          paymentMethodStr = 'bank_transfer';
          break;
        default:
          paymentMethodStr = 'cash'; // Default to cash
      }

      // Prepare the request data
      final Map<String, dynamic> requestData = {
        'client_id': clientId,
        'payment_method': paymentMethodStr,
        'notes': customerName,
        'items': apiItems,
      };

      // Make the API call
      final response = await _apiClient.post(
        '/create-order',
        data: requestData,
      ); // Handle the response
      if (response == null) {
        throw Exception('Failed to create order: Empty response');
      }

      // Enhanced logging for debugging
      print('=== ORDER CREATION RESPONSE ===');
      print('Full API Response: $response');
      print('Response Type: ${response.runtimeType}');

      // Log request details
      print('=== ORDER REQUEST DETAILS ===');
      print('Items Count: ${items.length}');
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        print(
            'Item ${i + 1}: ${item.product.name} - Qty: ${item.quantity} - Price: ${item.product.price}');
      }
      print('Customer: $customerName');
      print('Phone: $customerPhone');
      print('Payment Method: $paymentMethodStr');
      print('Discount: $discount');
      print('Client ID: $clientId');

      // Log cost breakdown
      double subtotal = items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
      print('=== COST BREAKDOWN ===');
      print('Subtotal: $subtotal');
      print('Discount: $discount');
      print('Total: ${subtotal - discount}');

      // Parse the response - handle if API returns order wrapper
      Map<String, dynamic> orderData;
      if (response.containsKey('order')) {
        print('Response contains "order" wrapper, extracting...');
        orderData = response['order'] as Map<String, dynamic>;
      } else {
        print('Response is direct order data');
        orderData = response;
      }

      print('=== PARSED ORDER DATA ===');
      print('Order Data: $orderData');
      orderData['total_quantity'] = items.fold(0, (sum, item) => sum + item.quantity);
      // Return the created invoice
      return SalesInvoice.fromJson(orderData);
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
