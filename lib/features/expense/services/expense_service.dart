import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/di/injection_container.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ExpenseService({ApiClient? apiClient}) : _apiClient = apiClient ?? sl();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Expense> recordExpense({
    required double amount,
    required String category,
    required String description,
    String? referenceNumber,
  }) async {
    final data = {
      'amount': amount,
      'category': category,
      'description': description,
      if (referenceNumber != null) 'reference_number': referenceNumber,
    };

    final response = await _apiClient.post(
      '/expenses',
      data: data,
    );

    return Expense.fromJson(response);
  }

  Future<List<Expense>> getExpenses({int page = 1, DateTime? date}) async {
    final queryParams = <String, dynamic>{'page': page};

    if (date != null) {
      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      queryParams['date'] = formattedDate;
    }

    final response = await _apiClient.get(
      '/expenses',
      queryParameters: queryParams,
    );

    final List<dynamic> expenses = response['data'] ?? [];
    return expenses.map((json) => Expense.fromJson(json)).toList();
  }
}
