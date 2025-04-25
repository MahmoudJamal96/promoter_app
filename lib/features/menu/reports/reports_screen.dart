import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التقارير', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إحصائيات عامة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView(
                    children: [
                  _buildReportCard(
                    title: 'تقرير المبيعات الشهرية',
                    icon: Icons.bar_chart,
                    color: Colors.blue,
                    onTap: () {
                      // Navigate to monthly sales report
                    },
                  ),
                  _buildReportCard(
                    title: 'تقرير الزيارات',
                    icon: Icons.location_on,
                    color: Colors.green,
                    onTap: () {
                      // Navigate to visits report
                    },
                  ),
                  _buildReportCard(
                    title: 'تقرير الأداء',
                    icon: Icons.trending_up,
                    color: Colors.purple,
                    onTap: () {
                      // Navigate to performance report
                    },
                  ),
                  _buildReportCard(
                    title: 'تقرير العملاء',
                    icon: Icons.people,
                    color: Colors.orange,
                    onTap: () {
                      // Navigate to customers report
                    },
                  ),
                ].animate(interval: 50.ms).fadeIn(duration: 300.ms)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
