import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:promoter_app/qara_ksa.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/di/injection_container.dart';
import '../models/treasury_model.dart';
import '../models/transfer_model.dart';

class TreasuryService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  TreasuryService({ApiClient? apiClient}) : _apiClient = apiClient ?? sl();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<TreasuryReport> getDailyReport({DateTime? date}) async {
    final token = await _getToken();
    if (token == null) throw Exception('غير مصرح لك بإجراء هذه العملية');

    final queryParams = <String, dynamic>{};

    if (date != null) {
      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      queryParams['date'] = formattedDate;
    }

    final response = await _apiClient.get(
      '/treasury/daily-report',
      queryParameters: queryParams.isEmpty ? null : queryParams,
      options: date != null
          ? Options(headers: {'Accept': 'application/json'})
          : null,
      // headers: {
      //   'Authorization': 'Bearer $token',
      // },
    );

    return TreasuryReport.fromJson(response);
  }

  Future<TreasuryTransfer> transferFunds({
    required double amount,
    required int fromBranchId,
    required int toBranchId,
    String? notes,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('غير مصرح لك بإجراء هذه العملية');

    final data = {
      'amount': amount,
      'from_branch_id': fromBranchId,
      'to_branch_id': toBranchId,
      if (notes != null) 'notes': notes,
    };

    final response = await _apiClient.post(
      '/treasury/transfer',
      data: data,
      options: Options(headers: {'Accept': 'application/json'}),
    );

    return TreasuryTransfer.fromJson(response);
  }

  Future<List<TreasuryTransfer>> getTransfers({int page = 1}) async {
    final token = await _getToken();
    if (token == null) throw Exception('غير مصرح لك بإجراء هذه العملية');

    final response = await _apiClient.get(
      '/treasury/transfers',
      queryParameters: {'page': page},
      options: Options(headers: {'Accept': 'application/json'}),
    );

    final List<dynamic> transfers = response['data'] ?? [];
    return transfers.map((json) => TreasuryTransfer.fromJson(json)).toList();
  }
}
