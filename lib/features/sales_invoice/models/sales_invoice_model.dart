import '../../products/models/product_model.dart';

enum InvoiceStatus { pending, completed, cancelled }

enum PaymentMethod { cash, creditCard, bankTransfer }

class SalesInvoiceItem {
  final int id;
  final int invoiceId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;
  final Product? product;

  SalesInvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.product,
  });

  factory SalesInvoiceItem.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceItem(
      id: json['id'] as int,
      invoiceId: json['invoice_id'] as int,
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

class SalesInvoice {
  final int id;
  final String invoiceNumber;
  final int clientId;
  final String clientName;
  final String status;
  final String paymentMethod;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String notes;
  final String createdAt;
  final String updatedAt;
  final List<SalesInvoiceItem> items;

  SalesInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    required this.status,
    required this.paymentMethod,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory SalesInvoice.fromJson(Map<String, dynamic> json) {
    return SalesInvoice(
      id: json['id'] as int,
      invoiceNumber: json['invoice_number'] as String,
      clientId: json['client_id'] as int,
      clientName: json['client_name'] as String,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => SalesInvoiceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// For creating a new invoice
class SalesInvoiceRequest {
  final int clientId;
  final String paymentMethod;
  final String? notes;
  final List<SalesInvoiceItemRequest> items;

  SalesInvoiceRequest({
    required this.clientId,
    required this.paymentMethod,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'payment_method': paymentMethod,
      if (notes != null) 'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class SalesInvoiceItemRequest {
  final int productId;
  final int quantity;
  final double price;

  SalesInvoiceItemRequest({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}
