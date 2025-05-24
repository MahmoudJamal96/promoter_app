import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:promoter_app/core/network/api_client.dart';
import 'package:promoter_app/core/di/injection_container.dart';
import '../models/leave_request_model.dart';

class LeaveRequestService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  LeaveRequestService({ApiClient? apiClient}) : _apiClient = apiClient ?? sl();

  /// Get all leave requests for the current user
  Future<List<LeaveRequest>> getLeaveRequests() async {
    try {
      final response = await _apiClient.get('/vacations');

      if (response == null) {
        return []; // Return mock data for testing
      }

      final List<dynamic> leaveRequests = response['data'] ?? [];
      final list = leaveRequests.map((json) => LeaveRequest.fromJson(json)).toList();
      return list;
    } catch (e) {
      print('Error getting leave requests: $e');
      return []; // Return mock data in case of error
    }
  }

  /// Submit a new leave request
  Future<LeaveRequest> createLeaveRequest({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    try {
      final data = {
        'leave_type': leaveType,
        'type': leaveType,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'reason': reason,
      };

      final response = await _apiClient.post(
        '/vacations',
        data: data,
      );

      if (response == null) {
        // Return a mock response for testing
        return LeaveRequest(
          id: DateTime
              .now()
              .millisecondsSinceEpoch,
          leaveType: leaveType,
          startDate: startDate,
          endDate: endDate,
          reason: reason,
          status: LeaveStatus.pending,
        );
      }

      return LeaveRequest.fromJson(response['data']);
    } catch (e) {
      print('Error creating leave request: $e');

      // Return a mock leave request for testing
      return LeaveRequest(
        id: DateTime
            .now()
            .millisecondsSinceEpoch,
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        status: LeaveStatus.pending,
      );
    }
  }

  /// Get leave request details
  Future<LeaveRequest> getLeaveRequestDetails(int requestId) async {
    try {
      final response = await _apiClient.get('/vacations/$requestId');

      if (response == null) {
        throw Exception(
            'API returned null response for leave request $requestId');
      }

      return LeaveRequest.fromJson(response['data']);
    } catch (e) {
      print('Error getting leave request details: $e');
      rethrow;
    }
  }

  /// Cancel a leave request
  Future<void> cancelLeaveRequest(int requestId) async {
    try {
      await _apiClient.delete('/vacations/$requestId');
    } catch (e) {
      print('Error cancelling leave request: $e');
      rethrow;
    }
  }
}