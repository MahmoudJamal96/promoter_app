import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:promoter_app/core/di/injection_container.dart';
import 'package:promoter_app/core/network/api_client.dart';
import '../models/delivery_order_model.dart';

class DeliveryService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DeliveryService({ApiClient? apiClient}) : _apiClient = apiClient ?? sl();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Get all delivery orders from the API
  Future<List<DeliveryOrder>> getOrders({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        '/get-orders',
        queryParameters: {'page': page},
      );

      if (response == null) {
        return _getMockOrders(); // Fallback to mock data
      }

      // Handle different response formats
      List<dynamic> ordersData = [];

      if (response is List) {
        ordersData = response;
      } else if (response['data'] != null) {
        if (response['data'] is List) {
          ordersData = response['data'];
        } else if (response['data']['data'] is List) {
          ordersData = response['data']['data'];
        }
      }

      final orders =
          ordersData.map((json) => DeliveryOrder.fromJson(json)).toList();

      // If no orders from API, return mock data for demo
      return orders.isEmpty ? _getMockOrders() : orders;
    } catch (e) {
      print('Error getting delivery orders: $e');
      // Return mock data on error for demo purposes
      return _getMockOrders();
    }
  }

  /// Get orders by status
  Future<List<DeliveryOrder>> getOrdersByStatus(DeliveryStatus status,
      {int page = 1}) async {
    try {
      final response = await _apiClient.get(
        '/get-orders',
        queryParameters: {
          'page': page,
          'status': status.apiValue,
        },
      );

      if (response == null) {
        return _getMockOrdersByStatus(status);
      }

      List<dynamic> ordersData = [];

      if (response is List) {
        ordersData = response;
      } else if (response['data'] != null) {
        if (response['data'] is List) {
          ordersData = response['data'];
        } else if (response['data']['data'] is List) {
          ordersData = response['data']['data'];
        }
      }

      final orders =
          ordersData.map((json) => DeliveryOrder.fromJson(json)).toList();
      return orders.isEmpty ? _getMockOrdersByStatus(status) : orders;
    } catch (e) {
      print('Error getting orders by status: $e');
      return _getMockOrdersByStatus(status);
    }
  }

  /// Get a specific order by ID
  Future<DeliveryOrder?> getOrderById(String orderId) async {
    try {
      final response = await _apiClient.get('/order/$orderId');

      if (response == null) {
        return null;
      }

      return DeliveryOrder.fromJson(response);
    } catch (e) {
      print('Error getting order by ID: $e');
      return null;
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, DeliveryStatus status) async {
    try {
      final response = await _apiClient.put(
        '/orders/$orderId/status',
        data: {'status': status.apiValue},
      );

      return response != null;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  /// Mock data for demonstration when API is not available
  List<DeliveryOrder> _getMockOrders() {
    return [
      DeliveryOrder(
        id: 'DO-7825',
        customerName: 'شركة النور للتجارة',
        customerAddress: 'شارع الملك فهد، الرياض',
        customerPhone: '0501234567',
        orderDate: DateTime.now().subtract(Duration(days: 2)),
        expectedDelivery: DateTime.now().add(Duration(days: 1)),
        items: [
          OrderItem(
              name: 'جهاز تابلت سامسونج',
              quantity: 5,
              price: 1200,
              productId: 1),
          OrderItem(
              name: 'بطارية خارجية', quantity: 10, price: 150, productId: 2),
        ],
        status: DeliveryStatus.inProgress,
        totalAmount: 7500,
        paymentMethod: 'cash',
        clientId: 1,
      ),
      DeliveryOrder(
        id: 'DO-7830',
        customerName: 'مؤسسة الأمل',
        customerAddress: 'شارع التحلية، جدة',
        customerPhone: '0509876543',
        orderDate: DateTime.now().subtract(Duration(days: 1)),
        expectedDelivery: DateTime.now().add(Duration(days: 3)),
        items: [
          OrderItem(
              name: 'جهاز لابتوب HP', quantity: 3, price: 3500, productId: 3),
          OrderItem(name: 'طابعة ليزر', quantity: 2, price: 1200, productId: 4),
        ],
        status: DeliveryStatus.preparing,
        totalAmount: 13100,
        paymentMethod: 'credit_card',
        clientId: 2,
      ),
      DeliveryOrder(
        id: 'DO-7810',
        customerName: 'مدارس المستقبل',
        customerAddress: 'شارع الأمير سلطان، الرياض',
        customerPhone: '0501122334',
        orderDate: DateTime.now().subtract(Duration(days: 10)),
        expectedDelivery: DateTime.now().subtract(Duration(days: 5)),
        actualDelivery: DateTime.now().subtract(Duration(days: 6)),
        items: [
          OrderItem(
              name: 'أجهزة تابلت تعليمية',
              quantity: 20,
              price: 900,
              productId: 5),
          OrderItem(name: 'حامل أجهزة', quantity: 20, price: 50, productId: 6),
        ],
        status: DeliveryStatus.delivered,
        totalAmount: 19000,
        paymentMethod: 'bank_transfer',
        clientId: 3,
      ),
      DeliveryOrder(
        id: 'DO-7820',
        customerName: 'مؤسسة الرياض للتجارة',
        customerAddress: 'شارع خالد بن الوليد، الرياض',
        customerPhone: '0505544332',
        orderDate: DateTime.now().subtract(Duration(days: 8)),
        expectedDelivery: DateTime.now().subtract(Duration(days: 3)),
        items: [
          OrderItem(
              name: 'أجهزة راوتر', quantity: 10, price: 250, productId: 7),
        ],
        status: DeliveryStatus.cancelled,
        totalAmount: 2500,
        paymentMethod: 'cash',
        clientId: 4,
      ),
    ];
  }

  /// Get mock orders filtered by status
  List<DeliveryOrder> _getMockOrdersByStatus(DeliveryStatus status) {
    final allOrders = _getMockOrders();
    return allOrders.where((order) => order.status == status).toList();
  }

  /// Get active orders (preparing and in progress)
  Future<List<DeliveryOrder>> getActiveOrders({int page = 1}) async {
    try {
      final allOrders = await getOrders(page: page);
      return allOrders
          .where((order) =>
              order.status == DeliveryStatus.preparing ||
              order.status == DeliveryStatus.inProgress)
          .toList();
    } catch (e) {
      print('Error getting active orders: $e');
      return _getMockOrders()
          .where((order) =>
              order.status == DeliveryStatus.preparing ||
              order.status == DeliveryStatus.inProgress)
          .toList();
    }
  }

  /// Get completed orders
  Future<List<DeliveryOrder>> getCompletedOrders({int page = 1}) async {
    try {
      final allOrders = await getOrders(page: page);
      return allOrders
          .where((order) => order.status == DeliveryStatus.delivered)
          .toList();
    } catch (e) {
      print('Error getting completed orders: $e');
      return _getMockOrders()
          .where((order) => order.status == DeliveryStatus.delivered)
          .toList();
    }
  }

  /// Get cancelled orders
  Future<List<DeliveryOrder>> getCancelledOrders({int page = 1}) async {
    try {
      final allOrders = await getOrders(page: page);
      return allOrders
          .where((order) => order.status == DeliveryStatus.cancelled)
          .toList();
    } catch (e) {
      print('Error getting cancelled orders: $e');
      return _getMockOrders()
          .where((order) => order.status == DeliveryStatus.cancelled)
          .toList();
    }
  }
}
