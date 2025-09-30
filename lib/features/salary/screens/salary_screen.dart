import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../core/di/injection_container.dart';
import '../cubit/salary_cubit.dart';
import '../cubit/salary_state.dart';
import '../models/salary_model.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SalaryCubit>()..loadSalaries(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF148ccd),
          title: const Text(
            'إدارة الراتب',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevation: 0,
          centerTitle: true,
        ),
        body: BlocBuilder<SalaryCubit, SalaryState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const _LoadingWidget();
            }

            if (state.errorMessage != null) {
              return _ErrorWidget(
                message: state.errorMessage!,
                onRetry: () {
                  SoundManager().playClickSound();
                  context.read<SalaryCubit>().loadSalaries();
                },
              );
            }

            return Column(
              children: [
                _MonthSelector(
                  selectedMonth: state.selectedMonth,
                  onMonthChanged: (month) => context.read<SalaryCubit>().changeMonth(month),
                ),
                if (state.stats != null) _StatsCards(stats: state.stats!),
                Expanded(
                  child: _SalaryList(salaries: state.salaries),
                ),
              ],
            );
          },
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => _showAddSalaryDialog(context),
        //   backgroundColor: const Color(0xFF148ccd),
        //   child: const Icon(Icons.add, color: Colors.white),
        // ),
      ),
    );
  }

  void _showAddSalaryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SalaryCubit>(),
        child: const _AddSalaryDialog(),
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        padding: const EdgeInsets.all(20),
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 100,
              showLabels: false,
              showTicks: false,
              axisLineStyle: const AxisLineStyle(
                thickness: 0.2,
                color: Color(0xFFE0E0E0),
                thicknessUnit: GaugeSizeUnit.factor,
              ),
              pointers: const <GaugePointer>[
                RangePointer(
                  value: 75,
                  cornerStyle: CornerStyle.bothCurve,
                  width: 0.2,
                  sizeUnit: GaugeSizeUnit.factor,
                  color: Color(0xFF148ccd),
                  enableAnimation: true,
                  animationDuration: 1500,
                  animationType: AnimationType.ease,
                ),
              ],
              annotations: const <GaugeAnnotation>[
                GaugeAnnotation(
                  positionFactor: 0.1,
                  angle: 90,
                  widget: Text(
                    'جاري التحميل...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF148ccd),
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
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFF44336),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF148ccd),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final int selectedMonth;
  final Function(int) onMonthChanged;

  const _MonthSelector({
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedMonth,
          isExpanded: true,
          hint: const Text('اختر الشهر'),
          items: List.generate(12, (index) {
            final month = index + 1;
            return DropdownMenuItem(
              value: month,
              child: Text(
                context.read<SalaryCubit>().getMonthName(month),
                style: const TextStyle(fontSize: 16),
              ),
            );
          }),
          onChanged: (month) {
            if (month != null) onMonthChanged(month);
          },
        ),
      ),
    );
  }
}

class _StatsCards extends StatelessWidget {
  final SalaryStatsModel stats;

  const _StatsCards({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'الراتب الإجمالي',
              value: stats.totalSalary,
              color: const Color(0xFF148ccd),
              icon: Icons.account_balance_wallet,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              title: 'المكافآت',
              value: stats.totalBonus,
              color: const Color(0xFF4CAF50),
              icon: Icons.star,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              title: 'الخصومات',
              value: stats.totalDeductions,
              color: const Color(0xFFF44336),
              icon: Icons.remove_circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(0)} جنيه',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalaryList extends StatelessWidget {
  final List<SalaryModel> salaries;

  const _SalaryList({required this.salaries});

  @override
  Widget build(BuildContext context) {
    if (salaries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Color(0xFF757575),
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد بيانات راتب لهذا الشهر',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: salaries.length,
      itemBuilder: (context, index) {
        final salary = salaries[index];
        return _SalaryCard(salary: salary);
      },
    );
  }
}

class _SalaryCard extends StatelessWidget {
  final SalaryModel salary;

  const _SalaryCard({required this.salary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: salary.typeColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: salary.typeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  salary.displayType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                salary.formattedAmount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: salary.typeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Color(0xFF757575),
              ),
              const SizedBox(width: 8),
              Text(
                salary.formattedDate,
                style: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (salary.notes != null && salary.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.note,
                  size: 16,
                  color: Color(0xFF757575),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    salary.notes!,
                    style: const TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AddSalaryDialog extends StatefulWidget {
  const _AddSalaryDialog();

  @override
  State<_AddSalaryDialog> createState() => _AddSalaryDialogState();
}

class _AddSalaryDialogState extends State<_AddSalaryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedType = 'salary';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'إضافة راتب جديد',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'النوع',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'salary', child: Text('راتب')),
                  DropdownMenuItem(value: 'bonus', child: Text('مكافأة')),
                  DropdownMenuItem(value: 'deduction', child: Text('خصم')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'المبلغ',
                  border: OutlineInputBorder(),
                  suffixText: 'جنيه',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المبلغ';
                  }
                  if (double.tryParse(value) == null) {
                    return 'يرجى إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('التاريخ'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            SoundManager().playClickSound();
            Navigator.of(context).pop();
          },
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF148ccd),
            foregroundColor: Colors.white,
          ),
          child: const Text('إضافة'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    SoundManager().playClickSound();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      SoundManager().playClickSound();
      final request = EntryRequestModel(
        date: _selectedDate.toIso8601String().split('T')[0],
        type: _selectedType,
        amount: double.parse(_amountController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      context.read<SalaryCubit>().addSalaryEntry(request);
      Navigator.of(context).pop();
    }
  }
}
