import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/task_model.dart';

class TaskService {
  final String baseUrl;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  TaskService({required this.baseUrl});

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Task>> getAllTasks() async {
    try {
      final headers = await _getHeaders();

      // We'll use the meetings endpoint since the task API is not specified
      final response = await http.get(
        Uri.parse('$baseUrl/meetings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] is List) {
          // Convert meetings data to tasks format
          return (data['data'] as List)
              .map((item) => Task.fromJson({
                    'id': item['id'].toString(),
                    'title': item['title'] ?? '',
                    'description': item['description'] ?? '',
                    'date': item['date'],
                    // Mapping some fields to fit our task model
                    'priority': _determinePriorityFromMeeting(item),
                    'status': _determineStatusFromMeeting(item),
                  }))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  Future<Task?> getTaskById(String taskId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/meetings/$taskId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          // Convert meeting data to task format
          return Task.fromJson({
            'id': data['data']['id'].toString(),
            'title': data['data']['title'] ?? '',
            'description': data['data']['description'] ?? '',
            'date': data['data']['date'],
            'priority': _determinePriorityFromMeeting(data['data']),
            'status': _determineStatusFromMeeting(data['data']),
          });
        }
      }
      return null;
    } catch (e) {
      print('Error fetching task: $e');
      return null;
    }
  }

  Future<bool> createTask(Task task) async {
    try {
      final headers = await _getHeaders();

      // Convert task to meeting format for API
      final meetingData = {
        'client_id': 1, // Default client ID - you may want to make this dynamic
        'title': task.title,
        'date': task.deadline.toIso8601String().split('T')[0],
        'start_time': '09:00', // Default values
        'end_time': '10:00',
        'place': 'Office', // Default value
        'description': task.description,
        // You might want to add additional fields like priority or status
        // as custom fields or in description
      };

      final response = await http.post(
        Uri.parse('$baseUrl/meetings'),
        headers: headers,
        body: json.encode(meetingData),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error creating task: $e');
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    try {
      final headers = await _getHeaders();

      // Convert task to meeting format for API
      final meetingData = {
        'client_id': 1, // Default client ID - you may want to make this dynamic
        'title': task.title,
        'date': task.deadline.toIso8601String().split('T')[0],
        'start_time': '09:00', // Default values
        'end_time': '10:00',
        'place': 'Office', // Default value
        'description': task.description,
        '_method': 'PATCH',
        // Additional fields for task status and priority can be added
      };

      final response = await http.post(
        Uri.parse('$baseUrl/meetings/${task.id}'),
        headers: headers,
        body: json.encode(meetingData),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/meetings/$taskId'),
        headers: headers,
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  // Helper methods to extract task properties from meeting data
  String _determinePriorityFromMeeting(Map<String, dynamic> meetingData) {
    // You could implement logic based on date, title, or other fields
    // This is just a sample implementation
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
    // This is just a sample implementation
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
}
