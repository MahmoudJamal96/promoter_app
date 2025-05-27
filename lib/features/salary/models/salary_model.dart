import 'package:flutter/material.dart';

// Individual salary entry from API
class SalaryEntry {
  final int id;
  final int userId;
  final String date;
  final String type; // "salary", "bonus", "deduction"
  final double amount;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SalaryEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.type,
    required this.amount,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory SalaryEntry.fromJson(Map<dynamic, dynamic> json) {
    return SalaryEntry(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      date: json['date'] ?? '',
      type: json['type'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  // Helper getters for display
  String get formattedAmount {
    return '${amount.toStringAsFixed(0)} جنيه';
  }

  String get formattedDate {
    final dateObj = DateTime.parse(date);
    return '${dateObj.day}/${dateObj.month}/${dateObj.year}';
  }

  String get displayType {
    switch (type) {
      case 'salary':
        return 'راتب';
      case 'bonus':
        return 'مكافأة';
      case 'deduction':
        return 'خصم';
      default:
        return type;
    }
  }

  Color get typeColor {
    switch (type) {
      case 'salary':
        return const Color(0xFF148ccd);
      case 'bonus':
        return const Color(0xFF4CAF50);
      case 'deduction':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }
}

// Aggregated salary model for monthly view
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

  factory SalaryModel.fromJson(Map<dynamic, dynamic> json) {
    return SalaryModel(
      id: json['id'] ?? 0,
      baseSalary:
          double.tryParse(json['base_salary']?.toString() ?? '0') ?? 0.0,
      bonus: double.tryParse(json['bonus']?.toString() ?? '0') ?? 0.0,
      deductions: double.tryParse(json['deductions']?.toString() ?? '0') ?? 0.0,
      totalSalary:
          double.tryParse(json['total_salary']?.toString() ?? '0') ?? 0.0,
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

  // Create SalaryModel from list of salary entries
  factory SalaryModel.fromEntries(List<SalaryEntry> entries, String month) {
    if (entries.isEmpty) {
      return SalaryModel(
        id: 0,
        baseSalary: 0,
        bonus: 0,
        deductions: 0,
        totalSalary: 0,
        status: 'pending',
        month: month,
      );
    }

    double baseSalary = 0;
    double bonus = 0;
    double deductions = 0;
    String? notes;
    DateTime? latestCreatedAt;

    for (var entry in entries) {
      switch (entry.type) {
        case 'salary':
          baseSalary += entry.amount;
          break;
        case 'bonus':
          bonus += entry.amount;
          break;
        case 'deduction':
          deductions += entry.amount;
          break;
      }

      if (entry.notes != null && entry.notes!.isNotEmpty) {
        notes = entry.notes;
      }

      if (entry.createdAt != null) {
        if (latestCreatedAt == null ||
            entry.createdAt!.isAfter(latestCreatedAt)) {
          latestCreatedAt = entry.createdAt;
        }
      }
    }

    return SalaryModel(
      id: entries.first.id,
      baseSalary: baseSalary,
      bonus: bonus,
      deductions: deductions,
      totalSalary: baseSalary + bonus - deductions,
      status: 'pending',
      month: month,
      notes: notes,
      createdAt: latestCreatedAt,
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

  // Helper getters for UI display
  String get formattedAmount {
    return '${totalSalary.toStringAsFixed(0)} جنيه';
  }

  String get formattedDate {
    if (paymentDate != null) {
      final dateObj = DateTime.parse(paymentDate!);
      return '${dateObj.day}/${dateObj.month}/${dateObj.year}';
    }
    return 'غير محدد';
  }

  String get displayType {
    return 'راتب شهري';
  }

  Color get typeColor {
    switch (status) {
      case 'paid':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFF148ccd);
      case 'cancelled':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }
}

// Entry request model for creating individual salary entries
class EntryRequestModel {
  final String date;
  final String type; // 'salary', 'bonus', 'deduction'
  final double amount;
  final String? notes;

  EntryRequestModel({
    required this.date,
    required this.type,
    required this.amount,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'type': type,
      'amount': amount,
      if (notes != null) 'notes': notes,
    };
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
  final double totalSalary;
  final double totalBonus;
  final double totalDeductions;
  final double totalEarned;
  final double averageSalary;
  final int totalMonths;
  final double lastSalary;

  SalaryStatsModel({
    required this.totalSalary,
    required this.totalBonus,
    required this.totalDeductions,
    required this.totalEarned,
    required this.averageSalary,
    required this.totalMonths,
    required this.lastSalary,
  });

  factory SalaryStatsModel.fromSalaries(List<SalaryModel> salaries) {
    if (salaries.isEmpty) {
      return SalaryStatsModel(
        totalSalary: 0,
        totalBonus: 0,
        totalDeductions: 0,
        totalEarned: 0,
        averageSalary: 0,
        totalMonths: 0,
        lastSalary: 0,
      );
    }

    double totalBaseSalary = 0;
    double totalBonus = 0;
    double totalDeductions = 0;
    double totalEarned = 0;

    for (var salary in salaries) {
      totalBaseSalary += salary.baseSalary;
      totalBonus += salary.bonus;
      totalDeductions += salary.deductions;
      totalEarned += salary.totalSalary;
    }

    return SalaryStatsModel(
      totalSalary: totalBaseSalary,
      totalBonus: totalBonus,
      totalDeductions: totalDeductions,
      totalEarned: totalEarned,
      averageSalary: totalEarned / salaries.length,
      totalMonths: salaries.length,
      lastSalary: salaries.first.totalSalary,
    );
  }

  factory SalaryStatsModel.fromJson(Map<String, dynamic> json) {
    return SalaryStatsModel(
      totalSalary: (json['total_salary'] ?? 0).toDouble(),
      totalBonus: (json['total_bonus'] ?? 0).toDouble(),
      totalDeductions: (json['total_deductions'] ?? 0).toDouble(),
      totalEarned: (json['total_earned'] ?? 0).toDouble(),
      averageSalary: (json['average_salary'] ?? 0).toDouble(),
      totalMonths: json['total_months'] ?? 0,
      lastSalary: (json['last_salary'] ?? 0).toDouble(),
    );
  }
}
