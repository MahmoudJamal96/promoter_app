import 'package:get_it/get_it.dart';
import 'package:promoter_app/features/menu/leave_request/controllers/leave_request_controller.dart';
import 'package:promoter_app/features/menu/leave_request/services/leave_request_service.dart';

// Extension to the existing DI container
void registerLeaveRequestDependencies() {
  final sl = GetIt.instance;

  // Register LeaveRequestService
  sl.registerLazySingleton(
    () => LeaveRequestService(apiClient: sl()),
  );

  // Register LeaveRequestController
  sl.registerLazySingleton(
    () => LeaveRequestController(leaveRequestService: sl()),
  );
}
