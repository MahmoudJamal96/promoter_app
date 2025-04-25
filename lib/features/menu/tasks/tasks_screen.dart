import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> tasks = [
    Task(
      id: '1',
      title: 'زيارة عميل الشركة الكبرى',
      description: 'متابعة طلب عميل الشركة الكبرى وتقديم عرض جديد',
      deadline: DateTime.now().add(Duration(days: 2)),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
    ),
    Task(
      id: '2',
      title: 'إعداد تقرير المبيعات الشهري',
      description: 'تجهيز وتقديم تقرير المبيعات الشهري للمدير',
      deadline: DateTime.now().add(Duration(days: 5)),
      priority: TaskPriority.medium,
      status: TaskStatus.notStarted,
    ),
    Task(
      id: '3',
      title: 'متابعة طلب السوبر ماركت',
      description: 'متابعة الطلب والتأكد من وصول البضاعة',
      deadline: DateTime.now().add(Duration(days: 1)),
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
    ),
    Task(
      id: '4',
      title: 'تحديث قائمة العملاء',
      description: 'تحديث معلومات العملاء وإضافة العملاء الجدد',
      deadline: DateTime.now().add(Duration(days: 7)),
      priority: TaskPriority.low,
      status: TaskStatus.notStarted,
    ),
    Task(
      id: '5',
      title: 'تقديم تقرير الزيارات الأسبوعي',
      description: 'إعداد وتقديم تقرير الزيارات الأسبوعي للمشرف',
      deadline: DateTime.now(),
      priority: TaskPriority.medium,
      status: TaskStatus.completed,
    ),
  ];

  TaskStatus _selectedFilterStatus = TaskStatus.all;

  List<Task> get filteredTasks {
    if (_selectedFilterStatus == TaskStatus.all) {
      return tasks;
    }
    return tasks.where((task) => task.status == _selectedFilterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مهامي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusFilter(),
              SizedBox(height: 16.h),
              _buildTaskCountWidget(),
              SizedBox(height: 16.h),
              Expanded(
                child: filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskItem(filteredTasks[index])
                              .animate()
                              .fadeIn(
                                duration: 300.ms,
                                delay: (50 * index).ms,
                              );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(TaskStatus.all, 'الكل'),
          SizedBox(width: 8.w),
          _buildFilterChip(TaskStatus.notStarted, 'لم تبدأ'),
          SizedBox(width: 8.w),
          _buildFilterChip(TaskStatus.inProgress, 'قيد التنفيذ'),
          SizedBox(width: 8.w),
          _buildFilterChip(TaskStatus.completed, 'مكتملة'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(TaskStatus status, String label) {
    final isSelected = _selectedFilterStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilterStatus = status;
          });
        }
      },
    );
  }

  Widget _buildTaskCountWidget() {
    final inProgressCount =
        tasks.where((task) => task.status == TaskStatus.inProgress).length;
    final completedCount =
        tasks.where((task) => task.status == TaskStatus.completed).length;
    final notStartedCount =
        tasks.where((task) => task.status == TaskStatus.notStarted).length;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCountItem(notStartedCount, 'لم تبدأ', Colors.orange),
          _buildCountItem(inProgressCount, 'قيد التنفيذ', Colors.blue),
          _buildCountItem(completedCount, 'مكتملة', Colors.green),
        ],
      ),
    );
  }

  Widget _buildCountItem(int count, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد مهام',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'اضغط على زر الإضافة لإنشاء مهمة جديدة',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = Colors.red;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.low:
        priorityColor = Colors.green;
        break;
    }

    IconData statusIcon;
    Color statusColor;
    switch (task.status) {
      case TaskStatus.completed:
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        break;
      case TaskStatus.inProgress:
        statusIcon = Icons.timelapse;
        statusColor = Colors.blue;
        break;
      case TaskStatus.notStarted:
        statusIcon = Icons.pending;
        statusColor = Colors.orange;
        break;
      default:
        statusIcon = Icons.circle;
        statusColor = Colors.grey;
    }

    final daysLeft = task.deadline.difference(DateTime.now()).inDays;

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 2,
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
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
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
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey),
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
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تصفية المهام',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: Icon(Icons.schedule),
                title: Text('الموعد النهائي'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement deadline filtering
                },
              ),
              ListTile(
                leading: Icon(Icons.priority_high),
                title: Text('الأولوية'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement priority filtering
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة مهمة جديدة'),
        content: Text('سيتم إضافة ميزة إنشاء المهام قريباً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

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
}
