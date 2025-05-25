class DeliveryOrder {
  final String id;
  final String customerName;
  final String customerAddress;
  final String? customerPhone;
  final DateTime orderDate;
  final DateTime expectedDelivery;
  final DateTime? actualDelivery;
  final List<OrderItem> items;
  final DeliveryStatus status;
  final double totalAmount;
  final String? notes;
  final String? paymentMethod;
  final int? clientId;

  DeliveryOrder({
    required this.id,
    required this.customerName,
    required this.customerAddress,
    this.customerPhone,
    required this.orderDate,
    required this.expectedDelivery,
    this.actualDelivery,
    required this.items,
    required this.status,
    required this.totalAmount,
    this.notes,
    this.paymentMethod,
    this.clientId,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name'] ??
          json['client_name'] ??
          json['client']?['name'] ??
          '',
      customerAddress: json['customer_address'] ?? json['client_address'] ?? '',
      customerPhone: json['customer_phone'] ??
          json['client_phone'] ??
          json['client']?['phone'],
      orderDate:
          DateTime.tryParse(json['order_date'] ?? json['created_at'] ?? '') ??
              DateTime.now(),
      expectedDelivery: DateTime.tryParse(
              json['expected_delivery'] ?? json['delivery_date'] ?? '') ??
          DateTime.now(),
      actualDelivery: json['actual_delivery'] != null
          ? DateTime.tryParse(json['actual_delivery'])
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      status: _parseStatus(json['status'] ?? ''),
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '') ??
          double.tryParse(json['total']?.toString() ?? '') ??
          double.tryParse(json['grand_total']?.toString() ?? '') ??
          0.0,
      notes: json['notes'],
      paymentMethod: json['payment_method'],
      clientId: json['client_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_address': customerAddress,
      'customer_phone': customerPhone,
      'order_date': orderDate.toIso8601String(),
      'expected_delivery': expectedDelivery.toIso8601String(),
      'actual_delivery': actualDelivery?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'status': status.name,
      'total_amount': totalAmount,
      'notes': notes,
      'payment_method': paymentMethod,
      'client_id': clientId,
    };
  }

  static DeliveryStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'preparing':
        return DeliveryStatus.preparing;
      case 'in_progress':
      case 'in_transit':
      case 'out_for_delivery':
        return DeliveryStatus.inProgress;
      case 'delivered':
      case 'completed':
        return DeliveryStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.preparing;
    }
  }

  DeliveryOrder copyWith({
    String? id,
    String? customerName,
    String? customerAddress,
    String? customerPhone,
    DateTime? orderDate,
    DateTime? expectedDelivery,
    DateTime? actualDelivery,
    List<OrderItem>? items,
    DeliveryStatus? status,
    double? totalAmount,
    String? notes,
    String? paymentMethod,
    int? clientId,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      customerPhone: customerPhone ?? this.customerPhone,
      orderDate: orderDate ?? this.orderDate,
      expectedDelivery: expectedDelivery ?? this.expectedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      items: items ?? this.items,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      clientId: clientId ?? this.clientId,
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;
  final int? productId;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.productId,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] ?? json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '') ??
          double.tryParse(json['unit_price']?.toString() ?? '') ??
          0.0,
      productId: json['product_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'product_id': productId,
    };
  }

  double get totalPrice => price * quantity;
}

enum DeliveryStatus {
  preparing,
  inProgress,
  delivered,
  cancelled,
}

extension DeliveryStatusExtension on DeliveryStatus {
  String get displayName {
    switch (this) {
      case DeliveryStatus.preparing:
        return 'قيد التحضير';
      case DeliveryStatus.inProgress:
        return 'في الطريق';
      case DeliveryStatus.delivered:
        return 'تم التوصيل';
      case DeliveryStatus.cancelled:
        return 'ملغى';
    }
  }

  String get apiValue {
    switch (this) {
      case DeliveryStatus.preparing:
        return 'preparing';
      case DeliveryStatus.inProgress:
        return 'in_progress';
      case DeliveryStatus.delivered:
        return 'delivered';
      case DeliveryStatus.cancelled:
        return 'cancelled';
    }
  }
}
