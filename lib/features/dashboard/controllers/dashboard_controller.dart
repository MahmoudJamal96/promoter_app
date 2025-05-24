import '../services/dashboard_service.dart';
import '../models/dashboard_info_model.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/api_error_handler.dart';

class DashboardController {
  final DashboardService _dashboardService;

  DashboardController({DashboardService? dashboardService})
      : _dashboardService = dashboardService ?? sl();

  Future<DashboardInfo> getDashboardInfo() async {
    return ApiErrorHandler.call(() async {
      final dashboardInfo = await _dashboardService.getDashboardInfo();
      return dashboardInfo;
    });
  }
}
