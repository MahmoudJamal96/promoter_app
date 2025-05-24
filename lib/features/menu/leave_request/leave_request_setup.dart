import 'package:flutter/material.dart';
import 'package:promoter_app/core/di/injection_container.dart';
import 'package:promoter_app/features/menu/leave_request/controllers/leave_request_controller.dart';
import 'package:promoter_app/features/menu/leave_request/leave_request_screen_new.dart';
import 'package:promoter_app/features/menu/leave_request/services/leave_request_service.dart';

/// Register all leave request dependencies at app startup
void registerLeaveRequestDependencies() {
  // Register Leave Request Service
  sl.registerLazySingleton(
    () => LeaveRequestService(apiClient: sl()),
  );

  // Register Leave Request Controller
  sl.registerLazySingleton(
    () => LeaveRequestController(leaveRequestService: sl()),
  );
}

/// Use this to navigate to the leave request screen
void navigateToLeaveRequest(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => LeaveRequestScreen(),
    ),
  );
}
