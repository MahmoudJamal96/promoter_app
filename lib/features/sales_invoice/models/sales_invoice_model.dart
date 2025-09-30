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
    try {
      print('=== PARSING SALES INVOICE ITEM ===');
      print('Item JSON: $json');
      return SalesInvoiceItem(
        id: json['id'] as int,
        invoiceId: json['invoice_id'] as int? ?? json['order_id'] as int? ?? 0,
        productId: json['product_id'] as int,
        productName: json['product_name']?.toString() ??
            (json['product']?['name']?.toString()) ??
            'Unknown Product',
        price: double.tryParse(json['unit_price'].toString()) ??
            double.tryParse(json['price'].toString()) ??
            double.tryParse(json['total_price'].toString()) ??
            0.0,
        quantity: json['quantity'] as int? ?? 1,
        subtotal: double.tryParse(json['total_price']?.toString() ?? "0") ?? 0.0,
        product: json['product'] != null ? Product.fromJson(json['product']) : null,
      );
    } catch (e) {
      print('=== ERROR PARSING SALES INVOICE ITEM ===');
      print('Error: $e');
      print('Item JSON: $json');
      rethrow;
    }
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
  final int? totalQuantity;

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
    this.totalQuantity,
  });
  factory SalesInvoice.fromJson(Map<String, dynamic> json) {
    try {
      print('=== PARSING SALES INVOICE FROM JSON ===');
      print('JSON Keys: ${json.keys.toList()}');
      print('Raw JSON: $json');
      return SalesInvoice(
        id: json['id'] as int,
        invoiceNumber:
            json['invoice_number'] as String? ?? json['number'] as String? ?? 'INV-${json['id']}',
        clientId: json['client_id'] as int? ?? 1,
        clientName: json['client_name'] as String? ??
            json['customer_name'] as String? ??
            json['notes']?.toString() ??
            'Unknown Customer',
        status: json['status'] as String? ?? 'pending',
        paymentMethod: json['payment_method'] as String? ?? 'cash',
        subtotal: double.tryParse(json['subtotal'].toString()) ??
            double.tryParse(json['grand_total'].toString()) ??
            0.0,
        tax: double.tryParse(json['tax'].toString()) ?? 0.0,
        discount: double.tryParse(json['subtotal'].toString()) ??
            double.tryParse(json['discount'].toString()) ??
            double.tryParse(json['discount_amount'].toString()) ??
            0.0,
        total: double.tryParse(json['total'].toString()) ??
            double.tryParse(json['grand_total'].toString()) ??
            0.0,
        notes: json['notes']?.toString() ?? '',
        createdAt: json['created_at']?.toString() ??
            json['date']?.toString() ??
            DateTime.now().toIso8601String(),
        updatedAt: json['updated_at']?.toString() ??
            json['date']?.toString() ??
            DateTime.now().toIso8601String(),
        items: (json['items'] as List<dynamic>?)?.map((e) {
              try {
                return SalesInvoiceItem.fromJson(e as Map<String, dynamic>);
              } catch (itemError) {
                print('Error parsing item: $itemError');
                print('Item data: $e');
                rethrow;
              }
            }).toList() ??
            [],
        totalQuantity: json['total_quantity'],
      );
    } catch (e) {
      print('=== ERROR PARSING SALES INVOICE ===');
      print('Error: $e');
      print('JSON: $json');
      rethrow;
    }
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
