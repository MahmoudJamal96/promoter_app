import 'package:flutter/material.dart';
import '../models/task_model.dart';

/// Extensions to provide color schemes for task priorities and statuses
extension TaskPriorityExtension on TaskPriority {
  Color get color {
    switch (this) {
      case TaskPriority.high:
        return Colors.red.shade700;
      case TaskPriority.medium:
        return Colors.orange.shade700;
      case TaskPriority.low:
        return Colors.green.shade700;
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.high:
        return Icons.flag;
      case TaskPriority.medium:
        return Icons.flag_outlined;
      case TaskPriority.low:
        return Icons.outlined_flag;
    }
  }
}

extension TaskStatusExtension on TaskStatus {
  Color get color {
    switch (this) {
      case TaskStatus.completed:
        return Colors.green.shade700;
      case TaskStatus.inProgress:
        return Colors.blue.shade700;
      case TaskStatus.notStarted:
        return Colors.grey.shade700;
      case TaskStatus.all:
        return Colors.purple.shade700;
    }
  }

  IconData get icon {
    switch (this) {
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.inProgress:
        return Icons.pending;
      case TaskStatus.notStarted:
        return Icons.circle_outlined;
      case TaskStatus.all:
        return Icons.list;
    }
  }
}
