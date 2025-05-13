class TreasuryReport {
  final double openingBalance;
  final double closingBalance;
  final double totalCollections;
  final double totalExpenses;
  final double totalSales;
  final double totalReturns;
  final double totalTransfers;
  final String date;
  final List<TreasuryTransaction> transactions;

  TreasuryReport({
    required this.openingBalance,
    required this.closingBalance,
    required this.totalCollections,
    required this.totalExpenses,
    required this.totalSales,
    required this.totalReturns,
    required this.totalTransfers,
    required this.date,
    required this.transactions,
  });

  factory TreasuryReport.fromJson(Map<String, dynamic> json) {
    return TreasuryReport(
      openingBalance: (json['opening_balance'] as num).toDouble(),
      closingBalance: (json['closing_balance'] as num).toDouble(),
      totalCollections: (json['total_collections'] as num).toDouble(),
      totalExpenses: (json['total_expenses'] as num).toDouble(),
      totalSales: (json['total_sales'] as num).toDouble(),
      totalReturns: (json['total_returns'] as num).toDouble(),
      totalTransfers: (json['total_transfers'] as num).toDouble(),
      date: json['date'] as String,
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => TreasuryTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TreasuryTransaction {
  final int id;
  final String type;
  final double amount;
  final String description;
  final String createdAt;

  TreasuryTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  factory TreasuryTransaction.fromJson(Map<String, dynamic> json) {
    return TreasuryTransaction(
      id: json['id'] as int,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}
