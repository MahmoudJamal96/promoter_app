import '../../products/models/product_model.dart';
import '../../sales_invoice/models/sales_invoice_model.dart';

class ReturnItem {
  final int id;
  final int returnId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;
  final Product? product;

  ReturnItem({
    required this.id,
    required this.returnId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.product,
  });

  factory ReturnItem.fromJson(Map<String, dynamic> json) {
    return ReturnItem(
      id: json['id'] as int,
      returnId: json['return_id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}

class ReturnOrder {
  final int id;
  final String returnNumber;
  final int? invoiceId;
  final String? invoiceNumber;
  final int clientId;
  final String clientName;
  final String status;
  final double total;
  final String? reason;
  final String notes;
  final String createdAt;
  final String updatedAt;
  final List<ReturnItem> items;
  final SalesInvoice? invoice;

  ReturnOrder({
    required this.id,
    required this.returnNumber,
    this.invoiceId,
    this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    required this.status,
    required this.total,
    this.reason,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.invoice,
  });

  factory ReturnOrder.fromJson(Map<String, dynamic> json) {
    return ReturnOrder(
      id: json['id'] as int,
      returnNumber: json['return_number'] as String,
      invoiceId: json['invoice_id'] as int?,
      invoiceNumber: json['invoice_number'] as String?,
      clientId: json['client_id'] as int,
      clientName: json['client_name'] as String,
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      reason: json['reason'] as String?,
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ReturnItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      invoice: json['invoice'] != null
          ? SalesInvoice.fromJson(json['invoice'])
          : null,
    );
  }
}
