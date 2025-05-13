import '../../products/models/product_model.dart';

class InventoryTransferItem {
  final int id;
  final int transferId;
  final int productId;
  final String productName;
  final int quantity;
  final Product? product;

  InventoryTransferItem({
    required this.id,
    required this.transferId,
    required this.productId,
    required this.productName,
    required this.quantity,
    this.product,
  });

  factory InventoryTransferItem.fromJson(Map<String, dynamic> json) {
    return InventoryTransferItem(
      id: json['id'] as int,
      transferId: json['transfer_id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}

class InventoryTransfer {
  final int id;
  final String transferNumber;
  final String type; // 'transfer' or 'return'
  final int fromWarehouseId;
  final String fromWarehouseName;
  final int toWarehouseId;
  final String toWarehouseName;
  final String status; // 'pending', 'completed', 'rejected'
  final String? reason;
  final String notes;
  final String createdAt;
  final String updatedAt;
  final List<InventoryTransferItem> items;

  InventoryTransfer({
    required this.id,
    required this.transferNumber,
    required this.type,
    required this.fromWarehouseId,
    required this.fromWarehouseName,
    required this.toWarehouseId,
    required this.toWarehouseName,
    required this.status,
    this.reason,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory InventoryTransfer.fromJson(Map<String, dynamic> json) {
    return InventoryTransfer(
      id: json['id'] as int,
      transferNumber: json['transfer_number'] as String,
      type: json['type'] as String,
      fromWarehouseId: json['from_warehouse_id'] as int,
      fromWarehouseName: json['from_warehouse_name'] as String,
      toWarehouseId: json['to_warehouse_id'] as int,
      toWarehouseName: json['to_warehouse_name'] as String,
      status: json['status'] as String,
      reason: json['reason'] as String?,
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) =>
                  InventoryTransferItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
