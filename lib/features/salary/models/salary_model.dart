class SalaryModel {
  final int id;
  final double baseSalary;
  final double bonus;
  final double deductions;
  final double totalSalary;
  final String status;
  final String month;
  final String? paymentDate;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SalaryModel({
    required this.id,
    required this.baseSalary,
    required this.bonus,
    required this.deductions,
    required this.totalSalary,
    required this.status,
    required this.month,
    this.paymentDate,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory SalaryModel.fromJson(Map<String, dynamic> json) {
    return SalaryModel(
      id: json['id'] ?? 0,
      baseSalary: (json['base_salary'] ?? json['baseSalary'] ?? 0).toDouble(),
      bonus: (json['bonus'] ?? 0).toDouble(),
      deductions: (json['deductions'] ?? 0).toDouble(),
      totalSalary:
          (json['total_salary'] ?? json['totalSalary'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      month: json['month'] ?? '',
      paymentDate: json['payment_date'] ?? json['paymentDate'],
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'base_salary': baseSalary,
      'bonus': bonus,
      'deductions': deductions,
      'total_salary': totalSalary,
      'status': status,
      'month': month,
      'payment_date': paymentDate,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SalaryModel copyWith({
    int? id,
    double? baseSalary,
    double? bonus,
    double? deductions,
    double? totalSalary,
    String? status,
    String? month,
    String? paymentDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalaryModel(
      id: id ?? this.id,
      baseSalary: baseSalary ?? this.baseSalary,
      bonus: bonus ?? this.bonus,
      deductions: deductions ?? this.deductions,
      totalSalary: totalSalary ?? this.totalSalary,
      status: status ?? this.status,
      month: month ?? this.month,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Salary request model for creating/updating salary
class SalaryRequestModel {
  final double baseSalary;
  final double bonus;
  final double deductions;
  final String month;
  final String? notes;

  SalaryRequestModel({
    required this.baseSalary,
    required this.bonus,
    required this.deductions,
    required this.month,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'base_salary': baseSalary,
      'bonus': bonus,
      'deductions': deductions,
      'month': month,
      'total_salary': baseSalary + bonus - deductions,
      if (notes != null) 'notes': notes,
    };
  }
}

// Salary statistics model for dashboard info
class SalaryStatsModel {
  final double totalEarned;
  final double averageSalary;
  final int totalMonths;
  final double lastSalary;

  SalaryStatsModel({
    required this.totalEarned,
    required this.averageSalary,
    required this.totalMonths,
    required this.lastSalary,
  });

  factory SalaryStatsModel.fromJson(Map<String, dynamic> json) {
    return SalaryStatsModel(
      totalEarned: (json['total_earned'] ?? 0).toDouble(),
      averageSalary: (json['average_salary'] ?? 0).toDouble(),
      totalMonths: json['total_months'] ?? 0,
      lastSalary: (json['last_salary'] ?? 0).toDouble(),
    );
  }
}
