import 'package:equatable/equatable.dart';
import '../models/task_model.dart';

enum TaskStateStatus { initial, loading, loaded, error }

class TaskState extends Equatable {
  final List<Task> tasks;
  final TaskStatus filterStatus;
  final TaskStateStatus status;
  final String errorMessage;

  const TaskState({
    this.tasks = const [],
    this.filterStatus = TaskStatus.all,
    this.status = TaskStateStatus.initial,
    this.errorMessage = '',
  });

  List<Task> get filteredTasks {
    if (filterStatus == TaskStatus.all) {
      return tasks;
    }
    return tasks.where((task) => task.status == filterStatus).toList();
  }

  int get notStartedCount =>
      tasks.where((task) => task.status == TaskStatus.notStarted).length;
  int get inProgressCount =>
      tasks.where((task) => task.status == TaskStatus.inProgress).length;
  int get completedCount =>
      tasks.where((task) => task.status == TaskStatus.completed).length;

  TaskState copyWith({
    List<Task>? tasks,
    TaskStatus? filterStatus,
    TaskStateStatus? status,
    String? errorMessage,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      filterStatus: filterStatus ?? this.filterStatus,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [tasks, filterStatus, status, errorMessage];
}
