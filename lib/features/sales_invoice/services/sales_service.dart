import '../../../core/network/api_client.dart';
import '../../../core/di/injection_container.dart';
import '../../inventory/services/inventory_service.dart' as inventory;
import '../models/sales_invoice_model.dart';

class SalesService {
  final ApiClient _apiClient;

  SalesService({ApiClient? apiClient}) : _apiClient = apiClient ?? sl();
  // Create a new sales invoice
  Future<SalesInvoice> createInvoice({
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
        case inventory.PaymentMethod.credit:
          paymentMethodStr = 'credit_card';
          break;
        case inventory.PaymentMethod.bank:
          paymentMethodStr = 'bank_transfer';
          break;
        // case inventory.PaymentMethod.:
        //   paymentMethodStr = 'check';
        //   break;
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
        throw Exception('Failed to create invoice: Empty response');
      }

      // Create a SalesInvoice from the response
      // Note: This is a simplified mapping, adjust according to your actual response format
      return SalesInvoice.fromJson(response);
    } catch (e) {
      print('Error creating invoice: $e');
      rethrow;
    }
  }

  // Get invoice by ID (Mock implementation for demo)
  Future<SalesInvoice?> getInvoiceById(String invoiceId) async {
    try {
      // For demonstration purposes, this is a mocked implementation
      // In a real application, you would make an API call to fetch the invoice
      final int id = int.tryParse(invoiceId) ?? 0;
      if (id <= 0) {
        return null;
      }

      // Create a mock invoice for demonstration
      return SalesInvoice(
        id: id,
        invoiceNumber: 'INV-$id',
        clientId: 1,
        clientName: 'عميل افتراضي',
        status: 'completed',
        paymentMethod: 'cash',
        subtotal: 1000.0,
        tax: 150.0,
        discount: 50.0,
        total: 1100.0,
        notes: 'ملاحظات افتراضية',
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
        items: [
          SalesInvoiceItem(
            id: 1,
            invoiceId: id,
            productId: 101,
            productName: 'منتج افتراضي 1',
            price: 500.0,
            quantity: 1,
            subtotal: 500.0,
          ),
          SalesInvoiceItem(
            id: 2,
            invoiceId: id,
            productId: 102,
            productName: 'منتج افتراضي 2',
            price: 300.0,
            quantity: 1,
            subtotal: 300.0,
          ),
          SalesInvoiceItem(
            id: 3,
            invoiceId: id,
            productId: 103,
            productName: 'منتج افتراضي 3',
            price: 200.0,
            quantity: 1,
            subtotal: 200.0,
          ),
        ],
      );
    } catch (e) {
      print('Error fetching invoice: $e');
      return null;
    }
  }
}
