import 'package:flutter/material.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF148ccd);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF148ccd),
        elevation: 0,
        title: const Text(
          'التقارير',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'المبيعات'),
            Tab(text: 'المخزون'),
            Tab(text: 'المالية'),
            Tab(text: 'العمليات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSalesReports(),
          _buildInventoryReports(),
          _buildFinancialReports(),
          _buildOperationsReports(),
        ],
      ),
    );
  }

  Widget _buildSalesReports() {
    final salesReports = [
      {
        'title': 'تقرير المبيعات التفصيلي',
        'subtitle': 'عرض تفاصيل جميع المبيعات',
        'icon': Icons.shopping_cart,
        'color': Colors.blue,
        'data': {
          'totalSales': 245000.0,
          'totalOrders': 156,
          'avgOrderValue': 1570.0,
          'growth': '+12.5%'
        }
      },
      {
        'title': 'تقرير المرتجعات',
        'subtitle': 'تفاصيل المرتجعات والاستردادات',
        'icon': Icons.keyboard_return,
        'color': Colors.orange,
        'data': {
          'totalReturns': 12500.0,
          'returnCount': 23,
          'returnRate': '14.7%',
          'avgReturnValue': 543.0
        }
      },
      {
        'title': 'تقرير المبيعات حسب العميل',
        'subtitle': 'أداء العملاء والمبيعات',
        'icon': Icons.people,
        'color': Colors.purple,
        'data': {
          'topCustomer': 'شركة النجاح',
          'customersCount': 89,
          'newCustomers': 12,
          'avgCustomerValue': 2750.0
        }
      },
      {
        'title': 'تقرير المبيعات الشهري',
        'subtitle': 'مقارنة الأداء الشهري',
        'icon': Icons.calendar_month,
        'color': Colors.indigo,
        'data': {
          'currentMonth': 245000.0,
          'lastMonth': 218000.0,
          'growth': '+12.4%',
          'target': 280000.0
        }
      },
    ];

    return _buildReportsList(salesReports);
  }

  Widget _buildInventoryReports() {
    final inventoryReports = [
      {
        'title': 'تقرير المخزون الحالي',
        'subtitle': 'حالة المخزون الحالية',
        'icon': Icons.inventory,
        'color': Colors.blue,
        'data': {
          'totalItems': 1250,
          'totalValue': 450000.0,
          'lowStockItems': 23,
          'outOfStockItems': 5
        }
      },
      {
        'title': 'تقرير نقل المخزون',
        'subtitle': 'تفاصيل عمليات نقل المخزون',
        'icon': Icons.swap_horiz,
        'color': Colors.orange,
        'data': {
          'totalTransfers': 45,
          'pendingTransfers': 8,
          'completedTransfers': 37,
          'transferValue': 125000.0
        }
      },
      {
        'title': 'تقرير المخزون المنخفض',
        'subtitle': 'المنتجات التي تحتاج إعادة طلب',
        'icon': Icons.warning,
        'color': Colors.red,
        'data': {'lowStockItems': 23, 'criticalItems': 5, 'reorderValue': 45000.0, 'suppliers': 12}
      },
      {
        'title': 'تقرير حركة المخزون',
        'subtitle': 'تتبع حركة المنتجات',
        'icon': Icons.timeline,
        'color': Colors.purple,
        'data': {'itemsIn': 156, 'itemsOut': 134, 'netMovement': 22, 'turnoverRate': '2.3x'}
      },
      {
        'title': 'تقرير تقييم المخزون',
        'subtitle': 'تقييم قيمة المخزون',
        'icon': Icons.assessment,
        'color': Colors.teal,
        'data': {'totalValue': 450000.0, 'costValue': 320000.0, 'margin': '28.9%', 'categories': 8}
      },
    ];

    return _buildReportsList(inventoryReports);
  }

  Widget _buildFinancialReports() {
    final financialReports = [
      {
        'title': 'تقرير الخزينة اليومي',
        'subtitle': 'حالة الخزينة والسيولة',
        'icon': Icons.account_balance,
        'color': Colors.blue,
        'data': {
          'totalBalance': 285000.0,
          'cashInflow': 45000.0,
          'cashOutflow': 32000.0,
          'netFlow': 13000.0
        }
      },
    ];

    return _buildReportsList(financialReports);
  }

  Widget _buildOperationsReports() {
    final operationsReports = [
      {
        'title': 'تقرير الأداء العام',
        'subtitle': 'ملخص الأداء العام للنظام',
        'icon': Icons.dashboard,
        'color': Colors.indigo,
        'data': {'overallScore': '85%', 'kpisMet': 12, 'totalKpis': 15, 'lastUpdated': 'اليوم'}
      },
    ];

    return _buildReportsList(operationsReports);
  }

  Widget _buildReportsList(List<Map<String, dynamic>> reports) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              report['color'].withOpacity(0.05),
              Colors.white,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: report['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      report['icon'],
                      color: report['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report['subtitle'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildReportData(report['data'], report['color']),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton('عرض', Icons.visibility, report['color']),
                  _buildActionButton('تصدير', Icons.download, Colors.grey),
                  _buildActionButton('طباعة', Icons.print, Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportData(Map<String, dynamic> data, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: data.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getDataLabel(entry.key),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _formatDataValue(entry.value),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color) {
    return Expanded(
        child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () => _handleReportAction(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(text, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    ));
  }

  String _getDataLabel(String key) {
    final labels = {
      'totalSales': 'إجمالي المبيعات',
      'totalOrders': 'عدد الطلبات',
      'avgOrderValue': 'متوسط قيمة الطلب',
      'growth': 'النمو',
      'totalReturns': 'إجمالي المرتجعات',
      'returnCount': 'عدد المرتجعات',
      'returnRate': 'معدل المرتجعات',
      'avgReturnValue': 'متوسط قيمة المرتجع',
      'topProduct': 'أفضل منتج',
      'topCategory': 'أفضل فئة',
      'productsCount': 'عدد المنتجات',
      'categoriesCount': 'عدد الفئات',
      'topCustomer': 'أفضل عميل',
      'customersCount': 'عدد العملاء',
      'newCustomers': 'عملاء جدد',
      'avgCustomerValue': 'متوسط قيمة العميل',
      'topBranch': 'أفضل فرع',
      'branchesCount': 'عدد الفروع',
      'totalRevenue': 'إجمالي الإيرادات',
      'avgBranchRevenue': 'متوسط إيراد الفرع',
      'currentMonth': 'الشهر الحالي',
      'lastMonth': 'الشهر الماضي',
      'target': 'الهدف',
      'totalItems': 'إجمالي الأصناف',
      'totalValue': 'إجمالي القيمة',
      'lowStockItems': 'أصناف منخفضة',
      'outOfStockItems': 'أصناف منتهية',
      'totalTransfers': 'إجمالي التحويلات',
      'pendingTransfers': 'تحويلات معلقة',
      'completedTransfers': 'تحويلات مكتملة',
      'transferValue': 'قيمة التحويلات',
      'warehouseTransfers': 'تحويلات المستودع',
      'criticalItems': 'أصناف حرجة',
      'reorderValue': 'قيمة إعادة الطلب',
      'suppliers': 'الموردين',
      'itemsIn': 'أصناف داخلة',
      'itemsOut': 'أصناف خارجة',
      'netMovement': 'صافي الحركة',
      'turnoverRate': 'معدل الدوران',
      'costValue': 'قيمة التكلفة',
      'margin': 'الهامش',
      'categories': 'الفئات',
      'totalBalance': 'إجمالي الرصيد',
      'cashInflow': 'التدفق الداخل',
      'cashOutflow': 'التدفق الخارج',
      'netFlow': 'صافي التدفق',
      'revenue': 'الإيرادات',
      'expenses': 'المصروفات',
      'netProfit': 'صافي الربح',
      'profitMargin': 'هامش الربح',
      'totalReceivables': 'إجمالي المستحقات',
      'overdueAmount': 'مبلغ متأخر',
      'avgPaymentDays': 'متوسط أيام الدفع',
      'totalPayables': 'إجمالي المدفوعات',
      'operatingCashFlow': 'التدفق التشغيلي',
      'investingCashFlow': 'التدفق الاستثماري',
      'financingCashFlow': 'التدفق التمويلي',
      'netCashFlow': 'صافي التدفق النقدي',
      'totalAssets': 'إجمالي الأصول',
      'totalLiabilities': 'إجمالي الخصوم',
      'equity': 'حقوق الملكية',
      'debtRatio': 'نسبة الديون',
      'totalPurchases': 'إجمالي المشتريات',
      'purchaseOrders': 'أوامر الشراء',
      'totalSuppliers': 'إجمالي الموردين',
      'activeSuppliers': 'موردين نشطين',
      'topSupplier': 'أفضل مورد',
      'avgDeliveryTime': 'متوسط وقت التسليم',
      'totalEmployees': 'إجمالي الموظفين',
      'salesStaff': 'موظفي المبيعات',
      'topSalesperson': 'أفضل بائع',
      'avgSalesPerEmployee': 'متوسط مبيعات الموظف',
      'totalBranches': 'إجمالي الفروع',
      'activeBranches': 'فروع نشطة',
      'totalActivities': 'إجمالي الأنشطة',
      'todayActivities': 'أنشطة اليوم',
      'userActions': 'إجراءات المستخدم',
      'systemActions': 'إجراءات النظام',
      'overallScore': 'النتيجة العامة',
      'kpisMet': 'مؤشرات محققة',
      'totalKpis': 'إجمالي المؤشرات',
      'lastUpdated': 'آخر تحديث',
    };
    return labels[key] ?? key;
  }

  String _formatDataValue(dynamic value) {
    if (value is double) {
      return '${value.toStringAsFixed(0)} ج.م';
    } else if (value is int) {
      return value.toString();
    } else {
      return value.toString();
    }
  }

  void _handleReportAction(String action) {
    SoundManager().playClickSound();
    String message = '';
    switch (action) {
      case 'عرض':
        message = 'جاري عرض التقرير...';
        break;
      case 'تصدير':
        message = 'جاري تصدير التقرير...';
        break;
      case 'طباعة':
        message = 'جاري طباعة التقرير...';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
