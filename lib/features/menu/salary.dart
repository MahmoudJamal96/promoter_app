import 'package:flutter/material.dart';

class SalaryDetailsScreen extends StatelessWidget {
  const SalaryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'تفاصيل الراتب الشهري',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF148ccd),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month and Year Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo[600]!, Colors.indigo[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'يونيو 2025',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'صافي الراتب: \$4,850.00',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Basic Salary Section
            _buildSectionCard(
              title: 'الراتب الأساسي',
              icon: Icons.account_balance_wallet,
              color: Colors.green,
              children: [
                _buildDetailRow('الراتب الأساسي', '\$5,000.00'),
                _buildDetailRow('العمل الإضافي', '\$200.00'),
                _buildDetailRow('إجمالي الراتب', '\$5,200.00', isTotal: true),
              ],
            ),

            const SizedBox(height: 16),

            // Bonuses Section
            _buildSectionCard(
              title: 'المكافآت',
              icon: Icons.card_giftcard,
              color: Colors.orange,
              children: [
                _buildDetailRow('مكافأة الأداء', '\$300.00'),
                _buildDetailRow('مكافأة الحضور', '\$150.00'),
                _buildDetailRow('إنجاز المشروع', '\$250.00'),
                _buildDetailRow('إجمالي المكافآت', '\$700.00', isTotal: true),
              ],
            ),

            const SizedBox(height: 16),

            // Discounts/Deductions Section
            _buildSectionCard(
              title: 'الخصومات',
              icon: Icons.money_off,
              color: Colors.red,
              children: [
                _buildDetailRow('ضريبة الدخل', '\$520.00'),
                _buildDetailRow('الضمان الاجتماعي', '\$260.00'),
                _buildDetailRow('التأمين الصحي', '\$180.00'),
                _buildDetailRow('صندوق التقاعد', '\$90.00'),
                _buildDetailRow('إجمالي الخصومات', '\$1,050.00', isTotal: true),
              ],
            ),

            const SizedBox(height: 20),

            // Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.indigo[200]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'ملخص الراتب',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow('إجمالي الراتب', '\$5,200.00'),
                  _buildSummaryRow('إجمالي المكافآت', '\$700.00', isPositive: true),
                  _buildSummaryRow('إجمالي الخصومات', '\$1,050.00', isNegative: true),
                  const Divider(thickness: 2, color: Colors.indigo),
                  _buildSummaryRow('صافي الراتب', '\$4,850.00', isTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.indigo[800] : Colors.grey[700],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.indigo[800] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount,
      {bool isPositive = false, bool isNegative = false, bool isTotal = false}) {
    Color textColor = Colors.grey[800]!;
    if (isPositive) textColor = Colors.green[600]!;
    if (isNegative) textColor = Colors.red[600]!;
    if (isTotal) textColor = Colors.indigo[800]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: textColor,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
