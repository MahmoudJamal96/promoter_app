import 'package:bloc/bloc.dart';
import '../repositories/task_repository.dart';
import './task_state.dart';
import '../models/task_model.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository _repository;

  TaskCubit({required TaskRepository repository})
      : _repository = repository,
        super(const TaskState());

  Future<void> fetchTasks() async {
    emit(state.copyWith(status: TaskStateStatus.loading));

    final result = await _repository.getAllTasks();

    result.fold(
      (failure) => emit(state.copyWith(
        status: TaskStateStatus.error,
        errorMessage: failure.toString(),
      )),
      (tasks) => emit(state.copyWith(
        status: TaskStateStatus.loaded,
        tasks: tasks,
        errorMessage: '',
      )),
    );
  }

  Future<void> getTaskById(String taskId) async {
    emit(state.copyWith(status: TaskStateStatus.loading));

    final result = await _repository.getTaskById(taskId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: TaskStateStatus.error,
        errorMessage: failure.toString(),
      )),
      (task) {
        final updatedTasks = List<Task>.from(state.tasks);
        final index = updatedTasks.indexWhere((t) => t.id == task.id);

        if (index >= 0) {
          updatedTasks[index] = task;
        } else {
          updatedTasks.add(task);
        }

        emit(state.copyWith(
          status: TaskStateStatus.loaded,
          tasks: updatedTasks,
          errorMessage: '',
        ));
      },
    );
  }

  Future<void> createTask(Task task) async {
    emit(state.copyWith(status: TaskStateStatus.loading));

    final result = await _repository.createTask(task);

    result.fold(
      (failure) => emit(state.copyWith(
        status: TaskStateStatus.error,
        errorMessage: failure.toString(),
      )),
      (success) {
        // Fetch tasks after successful creation to get the server-generated ID
        fetchTasks();
      },
    );
  }

  Future<void> updateTask(Task task) async {
    emit(state.copyWith(status: TaskStateStatus.loading));

    final result = await _repository.updateTask(task);

    result.fold(
      (failure) => emit(state.copyWith(
        status: TaskStateStatus.error,
        errorMessage: failure.toString(),
      )),
      (success) {
        final updatedTasks = List<Task>.from(state.tasks);
        final index = updatedTasks.indexWhere((t) => t.id == task.id);

        if (index >= 0) {
          updatedTasks[index] = task;

          emit(state.copyWith(
            status: TaskStateStatus.loaded,
            tasks: updatedTasks,
            errorMessage: '',
          ));
        } else {
          // If the task wasn't found, refresh the whole list
          fetchTasks();
        }
      },
    );
  }

  Future<void> deleteTask(String taskId) async {
    emit(state.copyWith(status: TaskStateStatus.loading));

    final result = await _repository.deleteTask(taskId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: TaskStateStatus.error,
        errorMessage: failure.toString(),
      )),
      (success) {
        final updatedTasks = List<Task>.from(state.tasks)
          ..removeWhere((task) => task.id == taskId);

        emit(state.copyWith(
          status: TaskStateStatus.loaded,
          tasks: updatedTasks,
          errorMessage: '',
        ));
      },
    );
  }

  void setFilterStatus(TaskStatus status) {
    emit(state.copyWith(filterStatus: status));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: ''));
  }
}
