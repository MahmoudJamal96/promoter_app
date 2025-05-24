import 'package:flutter/material.dart';

enum TaskPriority { high, medium, low }

enum TaskStatus { notStarted, inProgress, completed, all }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final TaskPriority priority;
  final TaskStatus status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      deadline:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      priority: _getPriorityFromString(json['priority'] ?? 'medium'),
      status: _getStatusFromString(json['status'] ?? 'not_started'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': deadline.toIso8601String(),
      'priority': _getPriorityString(priority),
      'status': _getStatusString(status),
    };
  }

  static TaskPriority _getPriorityFromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  static String _getPriorityString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'high';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.low:
        return 'low';
    }
  }

  static TaskStatus _getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return TaskStatus.completed;
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'not_started':
        return TaskStatus.notStarted;
      default:
        return TaskStatus.notStarted;
    }
  }

  static String _getStatusString(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.notStarted:
        return 'not_started';
      case TaskStatus.all:
        return 'all';
    }
  }
}
