class Expense {
  final int id;
  final double amount;
  final String category;
  final String description;
  final String? referenceNumber;
  final String createdAt;
  final String updatedAt;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    this.referenceNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String,
      referenceNumber: json['reference_number'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}

// Common categories for expenses
class ExpenseCategories {
  static const String commission = 'commission';
  static const String transportation = 'transportation';
  static const String meals = 'meals';
  static const String accommodation = 'accommodation';
  static const String office = 'office';
  static const String other = 'other';

  static List<String> get all => [
        commission,
        transportation,
        meals,
        accommodation,
        office,
        other,
      ];

  static String getLocalizedName(String category) {
    switch (category) {
      case commission:
        return 'عمولة';
      case transportation:
        return 'مواصلات';
      case meals:
        return 'وجبات';
      case accommodation:
        return 'إقامة';
      case office:
        return 'مستلزمات مكتبية';
      case other:
        return 'أخرى';
      default:
        return category;
    }
  }
}
