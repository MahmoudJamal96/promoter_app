import 'package:flutter/material.dart';
import 'package:promoter_app/features/menu/leave_request/leave_request_screen_new.dart';
import 'package:provider/provider.dart';
import '../../../core/di/injection_container.dart';
import 'controllers/leave_request_controller.dart';
import 'providers/leave_request_provider.dart';
import 'leave_request_screen_new.dart' as new_screen;

/// The main entry point for the leave request module.
/// This provides the provider and navigation to the leave request screen.
class LeaveRequestModule extends StatelessWidget {
  const LeaveRequestModule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeaveRequestProvider(
        leaveRequestController: sl<LeaveRequestController>(),
      ),
      child: const LeaveRequestScreen(),
    );
  }

  /// Use this method to navigate to the leave request screen
  static void navigate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LeaveRequestModule(),
      ),
    );
  }
}
