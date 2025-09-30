import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';

import 'cubit/task_cubit.dart';
import 'cubit/task_state.dart';
import 'models/task_model.dart';
import 'widgets/task_form_dialog.dart';
import 'widgets/task_item.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late TaskCubit _taskCubit;

  @override
  void initState() {
    super.initState();
    _initializeTaskCubit();
  }

  @override
  void dispose() {
    _taskCubit.close();
    super.dispose();
  }

  void _initializeTaskCubit() {
    // Get the TaskCubit from GetIt service locator
    _taskCubit = GetIt.instance<TaskCubit>();

    // Initial load of tasks
    _taskCubit.fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _taskCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مهامي', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFF148ccd),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                SoundManager().playClickSound();
                _taskCubit.fetchTasks();
              },
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusFilter(state),
                    SizedBox(height: 16.h),
                    _buildTaskCountWidget(state),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: state.status == TaskStateStatus.loading
                          ? const Center(child: CircularProgressIndicator())
                          : state.filteredTasks.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  itemCount: state.filteredTasks.length,
                                  itemBuilder: (context, index) {
                                    final task = state.filteredTasks[index];
                                    return TaskItem(
                                      task: task,
                                      onEdit: _editTask,
                                      onDelete: _deleteTask,
                                    ).animate().fadeIn(
                                          duration: 300.ms,
                                          delay: (50 * index).ms,
                                        );
                                  },
                                ),
                    ),
                    if (state.errorMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(8.w),
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                state.errorMessage,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, size: 16.sp),
                              onPressed: () {
                                SoundManager().playClickSound();
                                _taskCubit.clearError();
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatusFilter(TaskState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(TaskStatus.all, 'الكل', state),
          SizedBox(width: 8.w),
          _buildFilterChip(TaskStatus.notStarted, 'لم تبدأ', state),
          SizedBox(width: 8.w),
          _buildFilterChip(TaskStatus.inProgress, 'قيد التنفيذ', state),
          SizedBox(width: 8.w),
          _buildFilterChip(TaskStatus.completed, 'مكتملة', state),
        ],
      ),
    );
  }

  Widget _buildFilterChip(TaskStatus status, String label, TaskState state) {
    final isSelected = state.filterStatus == status;
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
          _taskCubit.setFilterStatus(status);
        }
      },
    );
  }

  Widget _buildTaskCountWidget(TaskState state) {
    final inProgressCount = state.inProgressCount;
    final completedCount = state.completedCount;
    final notStartedCount = state.notStartedCount;

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
          _buildCountItem(inProgressCount, 'قيد التنفيذ', const Color(0xFF148ccd)),
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
  // TaskItem Widget is now separated into its own file

  void _showFilterDialog() {
    SoundManager().playClickSound();
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
                leading: const Icon(Icons.schedule),
                title: const Text('الموعد النهائي'),
                onTap: () {
                  SoundManager().playClickSound();
                  Navigator.pop(context);
                  // Implement deadline filtering
                },
              ),
              ListTile(
                leading: const Icon(Icons.priority_high),
                title: const Text('الأولوية'),
                onTap: () {
                  SoundManager().playClickSound();
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
    SoundManager().playClickSound();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: _taskCubit,
        child: const TaskFormDialog(),
      ),
    );
  }

  void _editTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: _taskCubit,
        child: TaskFormDialog(task: task),
      ),
    );
  }

  void _deleteTask(String taskId) {
    _taskCubit.deleteTask(taskId);
  }
}
