import 'package:intl/intl.dart';

enum LeaveStatus { approved, rejected, pending }

class LeaveRequest {
  final int? id;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final DateTime createdAt;

  LeaveRequest({
    this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = LeaveStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Get the number of days between start and end date
  int get daysCount => endDate.difference(startDate).inDays + 1;

  // Get formatted date range string
  String get dateRangeString =>
      '${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}';

  // Convert status enum to string
  String get statusText {
    switch (status) {
      case LeaveStatus.approved:
        return 'تمت الموافقة';
      case LeaveStatus.rejected:
        return 'مرفوضة';
      case LeaveStatus.pending:
        return 'قيد الانتظار';
    }
  }

  // Factory method to create LeaveRequest from JSON
  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: int.parse(json['id'].toString()),
      leaveType: json['leave_type'] ?? json['type'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      reason: json['reason'] ?? json['notes'] ?? "",
      status: _parseStatus(json['status']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  // Helper method to parse status from string
  static LeaveStatus _parseStatus(String? statusStr) {
    if (statusStr == null) return LeaveStatus.pending;

    switch (statusStr.toLowerCase()) {
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      default:
        return LeaveStatus.pending;
    }
  }

  // Convert LeaveRequest to JSON
  Map<String, dynamic> toJson() {
    return {
      'leave_type': leaveType,
      'start_date': DateFormat('yyyy-MM-dd').format(startDate),
      'end_date': DateFormat('yyyy-MM-dd').format(endDate),
      'reason': reason,
    };
  }
}
