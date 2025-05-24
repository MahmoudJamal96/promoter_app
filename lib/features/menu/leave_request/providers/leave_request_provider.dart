import 'package:flutter/material.dart';
import '../controllers/leave_request_controller.dart';
import '../models/leave_request_model.dart';

enum LoadingStatus { initial, loading, loaded, error }

class LeaveRequestProvider extends ChangeNotifier {
  final LeaveRequestController _leaveRequestController;

  List<LeaveRequest> _leaveRequests = [];
  LoadingStatus _status = LoadingStatus.initial;
  String? _errorMessage;
  bool _isSubmitting = false;

  // Getters
  List<LeaveRequest> get leaveRequests => _leaveRequests;
  LoadingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;

  LeaveRequestProvider({
    required LeaveRequestController leaveRequestController,
  }) : _leaveRequestController = leaveRequestController {
    fetchLeaveRequests();
  }

  /// Fetch all leave requests
  Future<void> fetchLeaveRequests() async {
    if (_status == LoadingStatus.loading) return;

    _status = LoadingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _leaveRequests = await _leaveRequestController.getLeaveRequests();
      _status = LoadingStatus.loaded;
    } catch (e) {
      _status = LoadingStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// Submit a new leave request
  Future<bool> submitLeaveRequest({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newRequest = await _leaveRequestController.createLeaveRequest(
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );

      // Add the new request to the list
      _leaveRequests.add(newRequest);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Cancel a leave request
  Future<bool> cancelLeaveRequest(int requestId) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _leaveRequestController.cancelLeaveRequest(requestId);

      // Remove the canceled request from the list
      _leaveRequests.removeWhere((request) => request.id == requestId);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Get pending leave requests
  List<LeaveRequest> get pendingLeaveRequests {
    return _leaveRequests
        .where((request) => request.status == LeaveStatus.pending)
        .toList();
  }

  /// Get approved leave requests
  List<LeaveRequest> get approvedLeaveRequests {
    return _leaveRequests
        .where((request) => request.status == LeaveStatus.approved)
        .toList();
  }

  /// Get rejected leave requests
  List<LeaveRequest> get rejectedLeaveRequests {
    return _leaveRequests
        .where((request) => request.status == LeaveStatus.rejected)
        .toList();
  }
}
