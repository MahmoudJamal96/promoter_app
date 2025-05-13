class TreasuryTransfer {
  final int id;
  final int fromBranchId;
  final String fromBranchName;
  final int toBranchId;
  final String toBranchName;
  final double amount;
  final String status;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  TreasuryTransfer({
    required this.id,
    required this.fromBranchId,
    required this.fromBranchName,
    required this.toBranchId,
    required this.toBranchName,
    required this.amount,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TreasuryTransfer.fromJson(Map<String, dynamic> json) {
    return TreasuryTransfer(
      id: json['id'] as int,
      fromBranchId: json['from_branch_id'] as int,
      fromBranchName: json['from_branch_name'] as String,
      toBranchId: json['to_branch_id'] as int,
      toBranchName: json['to_branch_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}
