import 'package:get_it/get_it.dart';
import 'package:promoter_app/features/menu/tasks/di/task_dependencies.dart';

// Register all tasks feature dependencies
void setupTasksDependencies() {
  final sl = GetIt.instance;

  // Register task dependencies
  TaskDependencies.register(sl);
}
