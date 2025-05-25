import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promoter_app/core/di/injection_container.dart';
import 'cubit/notification_cubit.dart';
import 'models/notification_model.dart';
import 'services/notification_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NotificationCubit(sl<NotificationService>())..loadNotifications(),
      child: Scaffold(
        appBar: AppBar(
          title:
              Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded && state.unreadCount > 0) {
                  return PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'mark_all_read') {
                        context.read<NotificationCubit>().markAllAsRead();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'mark_all_read',
                        child: Text('تسجيل الكل كمقروء'),
                      ),
                    ],
                  );
                }
                return IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    context.read<NotificationCubit>().refreshNotifications();
                  },
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<NotificationCubit, NotificationState>(
            listener: (context, state) {
              if (state is NotificationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is NotificationMarkAsReadSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تسجيل الإشعار كمقروء'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is NotificationMarkAllAsReadSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تسجيل جميع الإشعارات كمقروءة'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is NotificationLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is NotificationLoaded) {
                if (state.notifications.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<NotificationCubit>().refreshNotifications();
                  },
                  child: Column(
                    children: [
                      if (state.unreadCount > 0)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Text(
                            'لديك ${state.unreadCount} إشعار غير مقروء',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(8.w),
                          itemCount: state.notifications.length,
                          itemBuilder: (context, index) {
                            return _buildNotificationTile(
                              context,
                              state.notifications[index],
                            )
                                .animate()
                                .fadeIn(
                                  duration: 300.ms,
                                  delay: (50 * index).ms,
                                )
                                .slide(
                                    begin: Offset(.1, 0),
                                    end: Offset(0, 0),
                                    duration: 300.ms,
                                    curve: Curves.easeOut);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is NotificationError) {
                return _buildErrorState(state.message);
              }
              return _buildEmptyState();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ستظهر الإشعارات الجديدة هنا',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationCubit>().loadNotifications();
            },
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
      BuildContext context, NotificationModel notification) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: CircleAvatar(
          backgroundColor: notification.isRead
              ? Colors.grey
              : Theme.of(context).primaryColor,
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight:
                      notification.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            Text(
              _formatTime(notification.createdAt),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        subtitle: Text(
          notification.message,
          style: TextStyle(
            color: notification.isRead ? Colors.grey : Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationCubit>().markAsRead(notification.id);
          }
          _showNotificationDetails(context, notification);
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'message':
        return Icons.message;
      case 'leave':
        return Icons.event_busy;
      case 'task':
        return Icons.task;
      case 'meeting':
        return Icons.event;
      case 'delivery':
        return Icons.local_shipping;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  void _showNotificationDetails(
      BuildContext context, NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text('إغلاق', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
