import 'package:promoter_app/core/di/injection_container.dart';
import 'package:promoter_app/core/utils/api_error_handler.dart';

import '../services/leave_request_service.dart';
import '../models/leave_request_model.dart';

class LeaveRequestController {
  final LeaveRequestService _leaveRequestService;

  LeaveRequestController({LeaveRequestService? leaveRequestService})
      : _leaveRequestService = leaveRequestService ?? sl<LeaveRequestService>();

  /// Get all leave requests for current user
  Future<List<LeaveRequest>> getLeaveRequests() async {
    return ApiErrorHandler.call(() async {
      final leaveRequests = await _leaveRequestService.getLeaveRequests();
      return leaveRequests;
    });
  }

  /// Submit a new leave request
  Future<LeaveRequest> createLeaveRequest({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    return ApiErrorHandler.call(() async {
      final request = await _leaveRequestService.createLeaveRequest(
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );
      return request;
    });
  }

  /// Get details of a specific leave request
  Future<LeaveRequest> getLeaveRequestDetails(int requestId) async {
    return ApiErrorHandler.call(() async {
      final request =
          await _leaveRequestService.getLeaveRequestDetails(requestId);
      return request;
    });
  }

  /// Cancel a leave request
  Future<void> cancelLeaveRequest(int requestId) async {
    return ApiErrorHandler.call(() async {
      await _leaveRequestService.cancelLeaveRequest(requestId);
    });
  }
}
