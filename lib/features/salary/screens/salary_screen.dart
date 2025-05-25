import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../cubit/salary_cubit.dart';
import '../cubit/salary_state.dart';
import '../models/salary_model.dart';

class SalaryScreen extends StatelessWidget {
  const SalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SalaryCubit>()..loadSalaries(),
      child: const SalaryScreenContent(),
    );
  }
}

class SalaryScreenContent extends StatefulWidget {
  const SalaryScreenContent({super.key});

  @override
  State<SalaryScreenContent> createState() => _SalaryScreenContentState();
}

class _SalaryScreenContentState extends State<SalaryScreenContent> {
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _bonusController = TextEditingController();
  final TextEditingController _deductionController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _salaryController.dispose();
    _bonusController.dispose();
    _deductionController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Salary Management',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          BlocBuilder<SalaryCubit, SalaryState>(
            builder: (context, state) {
              if (state is SalaryLoaded) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onSelected: (value) {
                    context.read<SalaryCubit>().selectMonth(value);
                  },
                  itemBuilder: (context) => state.availableMonths
                      .map((month) => PopupMenuItem(
                            value: month,
                            child: Text(month),
                          ))
                      .toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<SalaryCubit, SalaryState>(
        listener: (context, state) {
          if (state is SalaryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () => context.read<SalaryCubit>().loadSalaries(),
                ),
              ),
            );
          } else if (state is SalaryPaymentRequested) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment request submitted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SalaryLoading) {
            return _buildLoadingState();
          } else if (state is SalaryError) {
            return _buildErrorState(context, state);
          } else if (state is SalaryLoaded) {
            return _buildLoadedState(context, state);
          }
          return _buildLoadingState();
        },
      ),
      floatingActionButton: BlocBuilder<SalaryCubit, SalaryState>(
        builder: (context, state) {
          if (state is SalaryLoaded) {
            return FloatingActionButton.extended(
              onPressed: () => _showAddSalaryDialog(context, state),
              backgroundColor: const Color(0xFF2E7D32),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Salary',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ).animate().scale(
                  duration: 300.ms,
                  curve: Curves.easeInOut,
                );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animation/profile.json',
            width: 150.w,
            height: 150.w,
          ),
          SizedBox(height: 20.h),
          Text(
            'Loading salaries...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, SalaryError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.w,
            color: Colors.red,
          ),
          SizedBox(height: 20.h),
          Text(
            'Error Loading Salaries',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            state.message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30.h),
          ElevatedButton(
            onPressed: () => context.read<SalaryCubit>().loadSalaries(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
            ),
            child: Text(
              'Retry',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, SalaryLoaded state) {
    if (state.salaries.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SalaryCubit>().loadSalaries();
      },
      child: Column(
        children: [
          _buildSummaryCard(state),
          _buildMonthSelector(context, state),
          Expanded(
            child: _buildSalaryList(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animation/profile.json',
            width: 200.w,
            height: 200.w,
          ),
          SizedBox(height: 20.h),
          Text(
            'No Salaries Found',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Add your first salary record to get started',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30.h),
          ElevatedButton(
            onPressed: () => _showAddSalaryDialog(context, null),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
            ),
            child: Text(
              'Add First Salary',
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(SalaryLoaded state) {
    final totalSalary = state.filteredSalaries.fold<double>(
      0,
      (sum, salary) =>
          sum + salary.baseSalary + salary.bonus - salary.deductions,
    );

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Salary',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${totalSalary.toStringAsFixed(2)} SAR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Records',
                  state.filteredSalaries.length.toString(),
                  Icons.receipt,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Month',
                  DateFormat('MMM yyyy').format(state.selectedMonth),
                  Icons.calendar_month,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector(BuildContext context, SalaryLoaded state) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.availableMonths.length,
        itemBuilder: (context, index) {
          final month = state.availableMonths[index];
          final isSelected = month == state.selectedMonth;

          return Container(
            margin: EdgeInsets.only(right: 8.w),
            child: FilterChip(
              label: Text(
                month,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                context.read<SalaryCubit>().selectMonth(month);
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF2E7D32),
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSalaryList(BuildContext context, SalaryLoaded state) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: state.filteredSalaries.length,
      itemBuilder: (context, index) {
        final salary = state.filteredSalaries[index];
        return _buildSalaryCard(context, salary, state, index);
      },
    );
  }

  Widget _buildSalaryCard(
      BuildContext context, SalaryModel salary, SalaryLoaded state, int index) {
    final netSalary = salary.baseSalary + salary.bonus - salary.deductions;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => _showSalaryDetails(context, salary, state),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salary.month, // Since month is already a string
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Net: ${netSalary.toStringAsFixed(2)} SAR',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _showEditSalaryDialog(context, salary, state);
                            break;
                          case 'request_payment':
                            _showPaymentRequestDialog(context, salary);
                            break;
                          case 'delete':
                            _showDeleteConfirmation(context, salary);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'request_payment',
                          child: Row(
                            children: [
                              Icon(Icons.payment, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Request Payment'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildSalaryDetailItem(
                        'Base Salary',
                        '${salary.baseSalary.toStringAsFixed(2)} SAR',
                        Icons.attach_money,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildSalaryDetailItem(
                        'Bonus',
                        '${salary.bonus.toStringAsFixed(2)} SAR',
                        Icons.trending_up,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildSalaryDetailItem(
                        'Deduction',
                        '${salary.deductions.toStringAsFixed(2)} SAR',
                        Icons.trending_down,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                if (salary.notes != null && salary.notes!.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.grey[600], size: 16.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            salary.notes!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn();
  }

  Widget _buildSalaryDetailItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showAddSalaryDialog(BuildContext context, SalaryLoaded? state) {
    _clearControllers();
    _showSalaryDialog(
      context,
      'Add Salary',
      'Add',
      () => _addSalary(context),
    );
  }

  void _showEditSalaryDialog(
      BuildContext context, SalaryModel salary, SalaryLoaded state) {
    _salaryController.text = salary.baseSalary.toString();
    _bonusController.text = salary.bonus.toString();
    _deductionController.text = salary.deductions.toString();
    _reasonController.text = salary.notes ?? '';

    _showSalaryDialog(
      context,
      'Edit Salary',
      'Update',
      () => _updateSalary(context, salary),
    );
  }

  void _showSalaryDialog(
    BuildContext context,
    String title,
    String actionText,
    VoidCallback onAction,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'Base Salary',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _bonusController,
                decoration: const InputDecoration(
                  labelText: 'Bonus',
                  prefixIcon: Icon(Icons.trending_up),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _deductionController,
                decoration: const InputDecoration(
                  labelText: 'Deduction',
                  prefixIcon: Icon(Icons.trending_down),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (Optional)',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          BlocBuilder<SalaryCubit, SalaryState>(
            builder: (context, state) {
              final isUpdating = state is SalaryUpdating;
              return ElevatedButton(
                onPressed: isUpdating
                    ? null
                    : () {
                        onAction();
                        Navigator.of(dialogContext).pop();
                      },
                child: isUpdating
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(actionText),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSalaryDetails(
      BuildContext context, SalaryModel salary, SalaryLoaded state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Salary Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Month', salary.month), // month is already a string
            _buildDetailRow(
                'Base Salary', '${salary.baseSalary.toStringAsFixed(2)} SAR'),
            _buildDetailRow('Bonus', '${salary.bonus.toStringAsFixed(2)} SAR'),
            _buildDetailRow(
                'Deductions', '${salary.deductions.toStringAsFixed(2)} SAR'),
            _buildDetailRow('Net Salary',
                '${(salary.baseSalary + salary.bonus - salary.deductions).toStringAsFixed(2)} SAR'),
            if (salary.notes != null && salary.notes!.isNotEmpty)
              _buildDetailRow('Notes', salary.notes!),
            if (salary.createdAt != null)
              _buildDetailRow('Created',
                  DateFormat('MMM dd, yyyy HH:mm').format(salary.createdAt!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditSalaryDialog(context, salary, state);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentRequestDialog(BuildContext context, SalaryModel salary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Payment'),
        content: Text(
          'Request payment for ${salary.month} salary?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          BlocBuilder<SalaryCubit, SalaryState>(
            builder: (context, state) {
              final isRequesting = state is SalaryPaymentRequesting;
              return ElevatedButton(
                onPressed: isRequesting
                    ? null
                    : () {
                        context.read<SalaryCubit>().requestPayment(salary.id);
                        Navigator.of(context).pop();
                      },
                child: isRequesting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Request'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SalaryModel salary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Salary'),
        content: Text(
          'Are you sure you want to delete the salary record for ${salary.month}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality coming soon'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addSalary(BuildContext context) {
    final baseSalary = double.tryParse(_salaryController.text) ?? 0;
    final bonus = double.tryParse(_bonusController.text) ?? 0;
    final deduction = double.tryParse(_deductionController.text) ?? 0;
    final reason = _reasonController.text;

    if (baseSalary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid base salary'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } // Instead of creating a SalaryModel directly, call the cubit's update method
    context.read<SalaryCubit>().updateSalary(
          salaryId:
              DateTime.now().millisecondsSinceEpoch, // Generate a temporary ID
          baseSalary: baseSalary,
          bonus: bonus,
          deductions: deduction,
          month: DateFormat('yyyy-MM').format(DateTime.now()),
          notes: reason.isNotEmpty ? reason : null,
        );
    _clearControllers();
  }

  void _updateSalary(BuildContext context, SalaryModel existingSalary) {
    final baseSalary = double.tryParse(_salaryController.text) ?? 0;
    final bonus = double.tryParse(_bonusController.text) ?? 0;
    final deduction = double.tryParse(_deductionController.text) ?? 0;
    final reason = _reasonController.text;

    if (baseSalary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid base salary'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } // Instead of using copyWith, call the cubit's update method directly
    context.read<SalaryCubit>().updateSalary(
          salaryId: existingSalary.id,
          baseSalary: baseSalary,
          bonus: bonus,
          deductions: deduction,
          month: existingSalary.month,
          notes: reason.isNotEmpty ? reason : null,
        );
    _clearControllers();
  }

  void _clearControllers() {
    _salaryController.clear();
    _bonusController.clear();
    _deductionController.clear();
    _reasonController.clear();
  }
}
