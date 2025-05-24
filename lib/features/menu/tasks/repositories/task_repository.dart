import 'package:dartz/dartz.dart' hide Task;
import 'package:promoter_app/core/network/api_client.dart';
import 'package:promoter_app/core/error/failures.dart';
import '../models/task_model.dart';

class TaskRepository {
  final ApiClient _apiClient;

  TaskRepository(this._apiClient);
  Future<Either<Failure, List<Task>>> getAllTasks() async {
    try {
      // Use the meetings endpoint since we're adapting it for tasks
      final response = await _apiClient.get('/meetings');

      if (response is Map<String, dynamic> && response.containsKey('error')) {
        return Left(ServerFailure(
            message: response['error']?.toString() ?? 'Unknown error'));
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        final tasks = (response['data'] as List)
            .map((item) => Task.fromJson({
                  'id': item['id'].toString(),
                  'title': item['title'] ?? '',
                  'description': item['description'] ?? '',
                  'date': item['date'],
                  'priority': _determinePriorityFromMeeting(item),
                  'status': _determineStatusFromMeeting(item),
                }))
            .toList();

        return Right(tasks);
      }

      return Right([]);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Task>> getTaskById(String taskId) async {
    try {
      final response = await _apiClient.get('/meetings/$taskId');

      if (response['data'] != null) {
        final task = Task.fromJson({
          'id': response['data']['id'].toString(),
          'title': response['data']['title'] ?? '',
          'description': response['data']['description'] ?? '',
          'date': response['data']['date'],
          'priority': _determinePriorityFromMeeting(response['data']),
          'status': _determineStatusFromMeeting(response['data']),
        });

        return Right(task);
      }

      return Left(ServerFailure(message: 'Task not found'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> createTask(Task task) async {
    try {
      // Convert task to meeting format for API
      final meetingData = {
        'client_id': 1, // Default client ID - you may want to make this dynamic
        'title': task.title,
        'date': task.deadline.toIso8601String().split('T')[0],
        'start_time': '09:00', // Default values
        'end_time': '10:00',
        'place': 'Office', // Default value
        'description': task.description,
        'status':
            _getStatusForAPI(task.status), // Add the required status field
      };

      final response = await _apiClient.post('/meetings', data: meetingData);

      if (response is Map<String, dynamic> && response.containsKey('error')) {
        return Left(ServerFailure(
            message: response['error']?.toString() ?? 'Unknown error'));
      }

      return Right(true);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> updateTask(Task task) async {
    try {
      // Convert task to meeting format for API
      final meetingData = {
        'client_id': 1, // Default client ID - you may want to make this dynamic
        'title': task.title,
        'date': task.deadline.toIso8601String().split('T')[0],
        'start_time': '09:00', // Default values
        'end_time': '10:00',
        'place': 'Office', // Default value
        'description': task.description,
        'status':
            _getStatusForAPI(task.status), // Add the required status field
        '_method': 'PATCH',
      };

      final response =
          await _apiClient.post('/meetings/${task.id}', data: meetingData);

      if (response is Map<String, dynamic> && response.containsKey('error')) {
        return Left(ServerFailure(
            message: response['error']?.toString() ?? 'Unknown error'));
      }

      return Right(true);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> deleteTask(String taskId) async {
    try {
      final response = await _apiClient.delete('/meetings/$taskId');

      // Check if the response contains an error message
      if (response is Map<String, dynamic> &&
          response.containsKey('error') &&
          response['error'] != null) {
        return Left(ServerFailure(message: response['error'].toString()));
      }

      return Right(true);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // Helper methods to extract task properties from meeting data
  String _determinePriorityFromMeeting(Map<String, dynamic> meetingData) {
    // You could implement logic based on date, title, or other fields
    final title = meetingData['title']?.toString().toLowerCase() ?? '';
    if (title.contains('urgent') || title.contains('هام')) {
      return 'high';
    } else if (title.contains('medium') || title.contains('متوسط')) {
      return 'medium';
    } else {
      return 'low';
    }
  }

  String _determineStatusFromMeeting(Map<String, dynamic> meetingData) {
    // You could implement logic based on date or other fields
    final date = meetingData['date'] != null
        ? DateTime.parse(meetingData['date'])
        : null;

    if (date == null) return 'not_started';

    final now = DateTime.now();
    if (date.isBefore(now)) {
      // Meeting date has passed
      return 'completed';
    } else if (date.difference(now).inDays <= 2) {
      // Meeting is coming up soon
      return 'in_progress';
    } else {
      return 'not_started';
    }
  }

  // Helper method to convert our TaskStatus enum to the API's expected status values
  String _getStatusForAPI(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.notStarted:
        return 'not_started';
      case TaskStatus.all: // This is for filtering, not an actual status
        return 'not_started'; // Default to not_started for new tasks
    }
  }
}
