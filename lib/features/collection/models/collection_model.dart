class Collection {
  final int id;
  final int clientId;
  final String clientName;
  final double amount;
  final String paymentMethod;
  final String? referenceNumber;
  final String notes;
  final String createdAt;
  final String updatedAt;

  Collection({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.amount,
    required this.paymentMethod,
    this.referenceNumber,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] as int,
      clientId: json['client_id'] as int,
      clientName: json['client_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      referenceNumber: json['reference_number'] as String?,
      notes: json['notes'] as String? ?? '',
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}
