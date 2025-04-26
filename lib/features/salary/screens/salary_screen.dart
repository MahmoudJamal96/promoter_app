import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:lottie/lottie.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _bonusController = TextEditingController();
  final TextEditingController _deductionController = TextEditingController();
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  // Sample salary data - in a real app, this would come from a service or API
  final Map<String, dynamic> _salaryData = {
    'baseSalary': 3500.0,
    'bonus': 500.0,
    'deductions': 200.0,
    'totalSalary': 3800.0,
    'status': 'pending', // 'paid', 'pending', 'processing'
    'history': [
      {
        'month': '2025-04',
        'baseSalary': 3500.0,
        'bonus': 500.0,
        'deductions': 200.0,
        'totalSalary': 3800.0,
        'status': 'paid',
        'paymentDate': '2025-04-05',
      },
      {
        'month': '2025-03',
        'baseSalary': 3500.0,
        'bonus': 300.0,
        'deductions': 100.0,
        'totalSalary': 3700.0,
        'status': 'paid',
        'paymentDate': '2025-03-05',
      },
      {
        'month': '2025-02',
        'baseSalary': 3500.0,
        'bonus': 400.0,
        'deductions': 150.0,
        'totalSalary': 3750.0,
        'status': 'paid',
        'paymentDate': '2025-02-05',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _salaryController.text = _salaryData['baseSalary'].toString();
    _bonusController.text = _salaryData['bonus'].toString();
    _deductionController.text = _salaryData['deductions'].toString();
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _bonusController.dispose();
    _deductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المرتب', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month selector and status
                    _buildMonthSelector(),

                    SizedBox(height: 24.h),

                    // Current Salary Card
                    _buildSalaryCard()
                        .animate()
                        .fade(duration: 500.ms)
                        .scale(begin: 0.9),

                    SizedBox(height: 24.h),

                    // Salary Components
                    Text(
                      'تفاصيل الراتب',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ).animate().fade(duration: 500.ms),

                    SizedBox(height: 16.h),

                    // Editable salary components
                    _buildSalaryComponents().animate().fade(duration: 500.ms),

                    SizedBox(height: 24.h),

                    // Salary History
                    Text(
                      'سجل الرواتب',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ).animate().fade(duration: 500.ms),

                    SizedBox(height: 16.h),

                    // History list
                    _buildHistoryList().animate().fade(duration: 500.ms),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomBar().animate().fade(duration: 500.ms),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: _showMonthPicker,
          icon: Icon(Icons.calendar_month),
          label: Text(DateFormat('MMMM y').format(_selectedMonth)),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
        _buildStatusChip(_salaryData['status']),
      ],
    ).animate().fade(duration: 500.ms);
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'paid':
        chipColor = Colors.green;
        statusText = 'تم الدفع';
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        chipColor = Colors.amber;
        statusText = 'قيد الانتظار';
        statusIcon = Icons.access_time;
        break;
      case 'processing':
        chipColor = Colors.blue;
        statusText = 'قيد المعالجة';
        statusIcon = Icons.sync;
        break;
      default:
        chipColor = Colors.grey;
        statusText = 'غير معروف';
        statusIcon = Icons.help;
    }

    return Chip(
      avatar: Icon(statusIcon, color: Colors.white, size: 16),
      label: Text(
        statusText,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }

  Widget _buildSalaryCard() {
    final totalSalary = _salaryData['totalSalary'] as double;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              'إجمالي الراتب',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '$totalSalary ج.م',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSalaryDetail(
                    'الأساسي', '${_salaryData['baseSalary']} ج.م'),
                _buildSalaryDetail('المكافآت', '${_salaryData['bonus']} ج.م'),
                _buildSalaryDetail(
                    'الخصومات', '${_salaryData['deductions']} ج.م'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryDetail(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryComponents() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            _buildTextField(
                'المرتب الأساسي', _salaryController, TextInputType.number),
            SizedBox(height: 16.h),
            _buildTextField('المكافآت', _bonusController, TextInputType.number),
            SizedBox(height: 16.h),
            _buildTextField(
                'الخصومات', _deductionController, TextInputType.number),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _updateSalary,
              icon: Icon(Icons.save),
              label: Text('تحديث البيانات'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      TextInputType keyboardType) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        suffixText: 'ج.م',
      ),
    );
  }

  Widget _buildHistoryList() {
    final history = _salaryData['history'] as List;

    return history.isEmpty
        ? Center(child: Text('لا يوجد سجل للرواتب'))
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
                child: ListTile(
                  title: Text(
                    DateFormat('MMMM y')
                        .format(DateTime.parse('${item['month']}-01')),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('تاريخ الدفع: ${item['paymentDate']}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item['totalSalary']} ج.م',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      _buildStatusChip(item['status']),
                    ],
                  ),
                  onTap: () => _showHistoryDetails(item),
                ),
              )
                  .animate(delay: Duration(milliseconds: index * 100))
                  .fade(duration: 300.ms);
            },
          );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: ElevatedButton.icon(
          onPressed: _requestSalaryPayment,
          icon: Icon(Icons.request_page),
          label: Text('طلب دفع الراتب'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            minimumSize: Size.fromHeight(50.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ),
    );
  }

  void _showMonthPicker() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('اختر الشهر',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('إغلاق'),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(12, (index) {
                    final month = DateTime(
                        DateTime.now().year, DateTime.now().month - index);
                    return ListTile(
                      title: Text(DateFormat('MMMM y').format(month)),
                      trailing: _selectedMonth.month == month.month &&
                              _selectedMonth.year == month.year
                          ? Icon(Icons.check,
                              color: Theme.of(context).primaryColor)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedMonth = month;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
    );
  }

  void _updateSalary() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _salaryData['baseSalary'] =
            double.tryParse(_salaryController.text) ?? 0.0;
        _salaryData['bonus'] = double.tryParse(_bonusController.text) ?? 0.0;
        _salaryData['deductions'] =
            double.tryParse(_deductionController.text) ?? 0.0;
        _salaryData['totalSalary'] = _salaryData['baseSalary'] +
            _salaryData['bonus'] -
            _salaryData['deductions'];
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث بيانات الراتب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _showHistoryDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              'تفاصيل راتب ${DateFormat('MMMM y').format(DateTime.parse('${item['month']}-01'))}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('المرتب الأساسي', '${item['baseSalary']} ج.م'),
              _buildDetailRow('المكافآت', '${item['bonus']} ج.م'),
              _buildDetailRow('الخصومات', '${item['deductions']} ج.م'),
              Divider(),
              _buildDetailRow('الإجمالي', '${item['totalSalary']} ج.م',
                  isTotal: true),
              SizedBox(height: 16),
              _buildDetailRow('تاريخ الدفع', item['paymentDate']),
              _buildDetailRow('الحالة', _getStatusText(item['status'])),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16.sp : 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'تم الدفع';
      case 'pending':
        return 'قيد الانتظار';
      case 'processing':
        return 'قيد المعالجة';
      default:
        return 'غير معروف';
    }
  }

  void _requestSalaryPayment() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _salaryData['status'] = 'processing';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال طلب دفع الراتب'),
          backgroundColor: Colors.blue,
        ),
      );
    });
  }

  Widget _buildDashboardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'لوحة التحكم',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        )
            .animate()
            .fade(duration: 500.ms)
            .move(begin: Offset(0, 20), end: Offset(0, 0)),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          children: [
            _buildDashboardButton(
              'حاسبة الراتب',
              Icons.calculate,
              Colors.blue.shade700,
              'assets/animation/invoice.json',
              onTap: () {
                // Calculator action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('فتح حاسبة الراتب')),
                );
              },
            ),
            _buildDashboardButton(
              'سجل الحضور',
              Icons.schedule,
              Colors.green.shade700,
              'assets/animation/profile.json',
              onTap: () {
                // Attendance action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('فتح سجل الحضور')),
                );
              },
            ),
            _buildDashboardButton(
              'تقارير الأداء',
              Icons.insert_chart,
              Colors.purple.shade700,
              'assets/animation/scan.json',
              onTap: () {
                // Reports action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('فتح تقارير الأداء')),
                );
              },
            ),
            _buildDashboardButton(
              'المستندات',
              Icons.description,
              Colors.orange.shade700,
              'assets/animation/single_invoice.json',
              onTap: () {
                // Documents action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('فتح المستندات')),
                );
              },
            ),
          ],
        ).animate(delay: 200.ms).fade(duration: 600.ms),
      ],
    );
  }

  Widget _buildDashboardButton(
      String title, IconData icon, Color color, String lottieAsset,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60.h,
              width: 60.w,
              child: Lottie.asset(
                lottieAsset,
                fit: BoxFit.contain,
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .shimmer(delay: 1.seconds, duration: 1.seconds),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      )
          .animate()
          .scale(begin: 1, end: 0.95, duration: 100.ms)
          .then(delay: 100.ms)
          .scale(begin: 0.95, end: 1, duration: 100.ms),
    );
  }
}
