import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/di/injection_container.dart';
import '../models/salary_model.dart';

class SalaryService {
  final ApiClient _apiClient;

  SalaryService({ApiClient? apiClient}) : _apiClient = apiClient ?? sl();

  /// Get all salaries with optional date filtering
  Future<List<SalaryModel>> getSalaries({
    String? startDate,
    String? endDate,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};

      if (startDate != null) queryParams['start'] = startDate;
      if (endDate != null) queryParams['end'] = endDate;

      final response = await _apiClient.get(
        '/get-salaries',
        queryParameters: queryParams,
      );

      if (response == null) {
        return _getMockSalaries(); // Return mock data for testing
      }

      // Handle different response formats
      List<dynamic> salariesData = [];

      if (response is List) {
        salariesData = response;
      } else if (response['data'] != null) {
        if (response['data'] is List) {
          salariesData = response['data'];
        } else if (response['data']['data'] is List) {
          salariesData = response['data']['data'];
        }
      }

      return salariesData.map((json) => SalaryModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting salaries: $e');
      return _getMockSalaries(); // Return mock data in case of error
    }
  }

  /// Get salary for a specific month
  Future<SalaryModel?> getSalaryByMonth(String month) async {
    try {
      final response = await _apiClient.get('/get-salaries?month=$month');

      if (response != null && response['data'] != null) {
        final salaryData = response['data'];
        if (salaryData is List && salaryData.isNotEmpty) {
          return SalaryModel.fromJson(salaryData.first);
        } else if (salaryData is Map) {
          return SalaryModel.fromJson(salaryData);
        }
      }

      return null;
    } catch (e) {
      print('Error getting salary for month $month: $e');
      return null;
    }
  }

  /// Request salary payment
  Future<bool> requestSalaryPayment({
    required int salaryId,
    String? notes,
  }) async {
    try {
      final data = {
        'salary_id': salaryId,
        if (notes != null) 'notes': notes,
      };

      await _apiClient.post('/request-salary-payment', data: data);
      return true;
    } catch (e) {
      print('Error requesting salary payment: $e');
      return false;
    }
  }

  /// Update salary details (for admin/HR)
  Future<SalaryModel?> updateSalary({
    required int salaryId,
    required SalaryRequestModel salaryRequest,
  }) async {
    try {
      final response = await _apiClient.put(
        '/salaries/$salaryId',
        data: salaryRequest.toJson(),
      );

      if (response != null) {
        return SalaryModel.fromJson(response['data'] ?? response);
      }
      return null;
    } catch (e) {
      print('Error updating salary: $e');
      return null;
    }
  }

  /// Create new salary entry (for admin/HR)
  Future<SalaryModel?> createSalary(SalaryRequestModel salaryRequest) async {
    try {
      final response = await _apiClient.post(
        '/salaries',
        data: salaryRequest.toJson(),
      );

      if (response != null) {
        return SalaryModel.fromJson(response['data'] ?? response);
      }
      return null;
    } catch (e) {
      print('Error creating salary: $e');
      return null;
    }
  }

  /// Get salary statistics
  Future<SalaryStatsModel?> getSalaryStats() async {
    try {
      final response = await _apiClient.get('/salary-stats');

      if (response != null && response['data'] != null) {
        return SalaryStatsModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error getting salary stats: $e');
      return null;
    }
  }

  /// Get salary calculation details
  Future<Map<String, dynamic>?> getSalaryCalculation(String month) async {
    try {
      final response = await _apiClient.get('/salary-calculation?month=$month');

      if (response != null) {
        return response['data'] ?? response;
      }
      return null;
    } catch (e) {
      print('Error getting salary calculation: $e');
      return null;
    }
  }

  /// Submit salary modification request
  Future<bool> submitSalaryModificationRequest({
    required String month,
    required double baseSalary,
    required double bonus,
    required double deductions,
    required String reason,
  }) async {
    try {
      final data = {
        'month': month,
        'base_salary': baseSalary,
        'bonus': bonus,
        'deductions': deductions,
        'reason': reason,
        'type': 'modification_request',
      };

      await _apiClient.post('/salary-modification-request', data: data);
      return true;
    } catch (e) {
      print('Error submitting salary modification request: $e');
      return false;
    }
  }

  /// Get user info/profile for salary context
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final response = await _apiClient.get('/get-info');

      if (response != null) {
        return response['data'] ?? response;
      }
      return null;
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

  // Mock data for testing when API is not available
  List<SalaryModel> _getMockSalaries() {
    return [
      SalaryModel(
        id: 1,
        baseSalary: 3500.0,
        bonus: 500.0,
        deductions: 200.0,
        totalSalary: 3800.0,
        status: 'pending',
        month: '2025-05',
        paymentDate: null,
        notes: 'Current month salary',
        createdAt: DateTime.now(),
      ),
      SalaryModel(
        id: 2,
        baseSalary: 3500.0,
        bonus: 500.0,
        deductions: 200.0,
        totalSalary: 3800.0,
        status: 'paid',
        month: '2025-04',
        paymentDate: '2025-04-05',
        notes: 'April salary - paid on time',
        createdAt: DateTime(2025, 4, 1),
      ),
      SalaryModel(
        id: 3,
        baseSalary: 3500.0,
        bonus: 300.0,
        deductions: 100.0,
        totalSalary: 3700.0,
        status: 'paid',
        month: '2025-03',
        paymentDate: '2025-03-05',
        notes: 'March salary with performance bonus',
        createdAt: DateTime(2025, 3, 1),
      ),
      SalaryModel(
        id: 4,
        baseSalary: 3500.0,
        bonus: 400.0,
        deductions: 150.0,
        totalSalary: 3750.0,
        status: 'paid',
        month: '2025-02',
        paymentDate: '2025-02-05',
        notes: 'February salary',
        createdAt: DateTime(2025, 2, 1),
      ),
    ];
  }
}
