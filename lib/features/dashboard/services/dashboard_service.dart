import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/di/injection_container.dart';
import '../models/dashboard_info_model.dart';

class DashboardService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DashboardService({ApiClient? apiClient}) : _apiClient = apiClient ?? sl();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<DashboardInfo> getDashboardInfo() async {
    // final token = await _getToken();
    // print("Mahmoud Token : $token");
    // if (token == null) throw Exception('غير مصرح لك بإجراء هذه العملية');

    final response = await _apiClient.get(
      '/get-info',
      options: Options(headers: {'Accept': 'application/json'}),
    );

    return DashboardInfo.fromJson(response['data'] as Map<String, dynamic>);
  }
}
