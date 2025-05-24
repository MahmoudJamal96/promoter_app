import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import '../cubit/task_cubit.dart';

class TaskFormDialog extends StatefulWidget {
  final Task? task; // If provided, we are editing. If null, we are adding.

  const TaskFormDialog({Key? key, this.task}) : super(key: key);

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TaskPriority _selectedPriority;
  late TaskStatus _selectedStatus;

  @override
  void initState() {
    super.initState();

    // Initialize with task data if editing, or with defaults if creating
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _selectedDate =
        widget.task?.deadline ?? DateTime.now().add(const Duration(days: 1));
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _selectedStatus = widget.task?.status ?? TaskStatus.notStarted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final taskCubit = context.read<TaskCubit>();

    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      deadline: _selectedDate,
      priority: _selectedPriority,
      status: _selectedStatus,
    );

    if (widget.task == null) {
      // Adding new task
      taskCubit.createTask(task);
    } else {
      // Updating existing task
      taskCubit.updateTask(task);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.task == null ? 'إضافة مهمة جديدة' : 'تعديل المهمة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان المهمة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال عنوان للمهمة';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'وصف المهمة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16.h),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'الموعد النهائي',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<TaskPriority>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'الأولوية',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: TaskPriority.high,
                      child: Text('عالية'),
                    ),
                    DropdownMenuItem(
                      value: TaskPriority.medium,
                      child: Text('متوسطة'),
                    ),
                    DropdownMenuItem(
                      value: TaskPriority.low,
                      child: Text('منخفضة'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    }
                  },
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<TaskStatus>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'الحالة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: TaskStatus.notStarted,
                      child: Text('لم تبدأ'),
                    ),
                    DropdownMenuItem(
                      value: TaskStatus.inProgress,
                      child: Text('قيد التنفيذ'),
                    ),
                    DropdownMenuItem(
                      value: TaskStatus.completed,
                      child: Text('مكتملة'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null && value != TaskStatus.all) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('إلغاء'),
                    ),
                    SizedBox(width: 16.w),
                    ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(widget.task == null ? 'إضافة' : 'تعديل'),
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
