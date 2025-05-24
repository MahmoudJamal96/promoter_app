import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/task_model.dart';
import '../utils/task_colors.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(Task) onEdit;
  final Function(String) onDelete;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Use the extension methods to get colors and icons
    final priorityColor = task.priority.color;
    final statusColor = task.status.color;
    final statusIcon = task.status.icon;

    final daysLeft = task.deadline.difference(DateTime.now()).inDays;

    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('حذف المهمة'),
              content: Text('هل أنت متأكد من حذف هذه المهمة؟'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('حذف', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        onDelete(task.id);
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 2,
        child: InkWell(
          onTap: () => onEdit(task),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: priorityColor,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(statusIcon, color: statusColor, size: 18),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  task.description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          '${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    daysLeft < 0
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'متأخرة',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : daysLeft == 0
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'اليوم',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(
                                  'متبقي $daysLeft يوم',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
