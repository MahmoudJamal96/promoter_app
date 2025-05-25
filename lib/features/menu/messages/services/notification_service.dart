import 'package:promoter_app/core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all notifications for the current user
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.get('/notifications');

      if (response['data'] != null) {
        final List<dynamic> notificationsList =
            response['data']?['data'] ?? response['data'];
        return notificationsList
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Mark a specific notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      await _apiClient.put('/notifications/$notificationId/read');
      return true;
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      await _apiClient.put('/notifications/read-all');
      return true;
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      return notifications.where((notification) => !notification.isRead).length;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }
}
