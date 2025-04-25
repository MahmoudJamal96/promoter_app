import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<DeliveryOrder> _activeOrders = [
    DeliveryOrder(
      id: 'DO-7825',
      customerName: 'شركة النور للتجارة',
      customerAddress: 'شارع الملك فهد، الرياض',
      orderDate: DateTime.now().subtract(Duration(days: 2)),
      expectedDelivery: DateTime.now().add(Duration(days: 1)),
      items: [
        OrderItem(name: 'جهاز تابلت سامسونج', quantity: 5, price: 1200),
        OrderItem(name: 'بطارية خارجية', quantity: 10, price: 150),
      ],
      status: DeliveryStatus.inProgress,
      totalAmount: 7500,
    ),
    DeliveryOrder(
      id: 'DO-7830',
      customerName: 'مؤسسة الأمل',
      customerAddress: 'شارع التحلية، جدة',
      orderDate: DateTime.now().subtract(Duration(days: 1)),
      expectedDelivery: DateTime.now().add(Duration(days: 3)),
      items: [
        OrderItem(name: 'جهاز لابتوب HP', quantity: 3, price: 3500),
        OrderItem(name: 'طابعة ليزر', quantity: 2, price: 1200),
      ],
      status: DeliveryStatus.preparing,
      totalAmount: 13100,
    ),
  ];

  final List<DeliveryOrder> _completedOrders = [
    DeliveryOrder(
      id: 'DO-7810',
      customerName: 'مدارس المستقبل',
      customerAddress: 'شارع الأمير سلطان، الرياض',
      orderDate: DateTime.now().subtract(Duration(days: 10)),
      expectedDelivery: DateTime.now().subtract(Duration(days: 5)),
      actualDelivery: DateTime.now().subtract(Duration(days: 6)),
      items: [
        OrderItem(name: 'أجهزة تابلت تعليمية', quantity: 20, price: 900),
        OrderItem(name: 'حامل أجهزة', quantity: 20, price: 50),
      ],
      status: DeliveryStatus.delivered,
      totalAmount: 19000,
    ),
    DeliveryOrder(
      id: 'DO-7815',
      customerName: 'مركز الفيصل التجاري',
      customerAddress: 'شارع العليا، الرياض',
      orderDate: DateTime.now().subtract(Duration(days: 15)),
      expectedDelivery: DateTime.now().subtract(Duration(days: 10)),
      actualDelivery: DateTime.now().subtract(Duration(days: 9)),
      items: [
        OrderItem(name: 'شاشات عرض سامسونج', quantity: 5, price: 2500),
        OrderItem(name: 'جهاز استقبال', quantity: 5, price: 300),
      ],
      status: DeliveryStatus.delivered,
      totalAmount: 14000,
    ),
  ];

  final List<DeliveryOrder> _cancelledOrders = [
    DeliveryOrder(
      id: 'DO-7820',
      customerName: 'مؤسسة الرياض للتجارة',
      customerAddress: 'شارع خالد بن الوليد، الرياض',
      orderDate: DateTime.now().subtract(Duration(days: 8)),
      expectedDelivery: DateTime.now().subtract(Duration(days: 3)),
      items: [
        OrderItem(name: 'أجهزة راوتر', quantity: 10, price: 250),
      ],
      status: DeliveryStatus.cancelled,
      totalAmount: 2500,
      cancellationReason: 'طلب العميل إلغاء الطلب لعدم الحاجة للمنتجات',
    ),
    DeliveryOrder(
      id: 'DO-7822',
      customerName: 'شركة الأمانة',
      customerAddress: 'شارع الملك عبد العزيز، جدة',
      orderDate: DateTime.now().subtract(Duration(days: 5)),
      expectedDelivery: DateTime.now().subtract(Duration(days: 1)),
      items: [
        OrderItem(name: 'جهاز ماسح ضوئي', quantity: 2, price: 1800),
        OrderItem(name: 'كاميرا مراقبة', quantity: 4, price: 500),
      ],
      status: DeliveryStatus.cancelled,
      totalAmount: 5600,
      cancellationReason: 'المنتجات غير متوفرة في المخزون',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('طلبات التوصيل',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'نشط'),
            Tab(text: 'مكتمل'),
            Tab(text: 'ملغي'),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(_activeOrders, true),
          _buildOrdersList(_completedOrders, false),
          _buildOrdersList(_cancelledOrders, false),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<DeliveryOrder> orders, bool isActive) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index], isActive)
            .animate()
            .fadeIn(duration: 300.ms, delay: (50 * index).ms)
            .slide(
                begin: Offset(0, 10),
                end: Offset(0, 0),
                duration: 300.ms,
                curve: Curves.easeOut);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد طلبات توصيل',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ستظهر طلبات التوصيل هنا عند إضافتها',
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

  Widget _buildOrderCard(DeliveryOrder order, bool isActive) {
    Color statusColor;
    String statusText;

    switch (order.status) {
      case DeliveryStatus.preparing:
        statusColor = Colors.blue;
        statusText = 'قيد التحضير';
        break;
      case DeliveryStatus.inProgress:
        statusColor = Colors.orange;
        statusText = 'قيد التوصيل';
        break;
      case DeliveryStatus.delivered:
        statusColor = Colors.green;
        statusText = 'تم التوصيل';
        break;
      case DeliveryStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'ملغي';
        break;
    }

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'رقم الطلب: ${order.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(),
            SizedBox(height: 12.h),
            _buildInfoRow('العميل', order.customerName),
            SizedBox(height: 8.h),
            _buildInfoRow('العنوان', order.customerAddress),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    'تاريخ الطلب',
                    '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    order.status == DeliveryStatus.delivered
                        ? 'تاريخ التوصيل'
                        : 'تاريخ التوصيل المتوقع',
                    order.status == DeliveryStatus.delivered &&
                            order.actualDelivery != null
                        ? '${order.actualDelivery!.day}/${order.actualDelivery!.month}/${order.actualDelivery!.year}'
                        : '${order.expectedDelivery.day}/${order.expectedDelivery.month}/${order.expectedDelivery.year}',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'المنتجات:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            ...order.items.map((item) => _buildProductItem(item)),
            SizedBox(height: 16.h),
            Divider(),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إجمالي القيمة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${order.totalAmount} ريال',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            if (order.cancellationReason != null) ...[
              SizedBox(height: 16.h),
              Text(
                'سبب الإلغاء:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                order.cancellationReason!,
                style: TextStyle(
                  color: Colors.red.shade700,
                ),
              ),
            ],
            if (isActive) ...[
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (order.status == DeliveryStatus.preparing ||
                      order.status == DeliveryStatus.inProgress) ...[
                    OutlinedButton(
                      onPressed: () {
                        // Cancel order functionality
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text('إلغاء الطلب'),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  ElevatedButton(
                    onPressed: () {
                      // View order details functionality
                      _showOrderDetails(order);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('تفاصيل الطلب'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14.sp,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(OrderItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Text(
            '${item.quantity} x',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Text(
            '${item.price * item.quantity} ريال',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(DeliveryOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'تفاصيل الطلب #${order.id}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView(
                  children: [
                    _buildDetailItem('رقم الطلب', order.id),
                    _buildDetailItem('العميل', order.customerName),
                    _buildDetailItem('العنوان', order.customerAddress),
                    _buildDetailItem('تاريخ الطلب',
                        '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}'),
                    _buildDetailItem('تاريخ التوصيل المتوقع',
                        '${order.expectedDelivery.day}/${order.expectedDelivery.month}/${order.expectedDelivery.year}'),
                    if (order.actualDelivery != null)
                      _buildDetailItem('تاريخ التوصيل الفعلي',
                          '${order.actualDelivery!.day}/${order.actualDelivery!.month}/${order.actualDelivery!.year}'),
                    _buildDetailItem('الحالة', _getStatusText(order.status)),
                    if (order.cancellationReason != null)
                      _buildDetailItem(
                          'سبب الإلغاء', order.cancellationReason!),
                    SizedBox(height: 16.h),
                    Text(
                      'المنتجات',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...order.items.map((item) => _buildDetailProductItem(item)),
                    SizedBox(height: 16.h),
                    Divider(),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'إجمالي القيمة',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${order.totalAmount} ريال',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text('إغلاق'),
                ),
              ),
              if (order.status != DeliveryStatus.delivered &&
                  order.status != DeliveryStatus.cancelled) ...[
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Track order functionality
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text('تتبع الشحنة'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getStatusText(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.preparing:
        return 'قيد التحضير';
      case DeliveryStatus.inProgress:
        return 'قيد التوصيل';
      case DeliveryStatus.delivered:
        return 'تم التوصيل';
      case DeliveryStatus.cancelled:
        return 'ملغي';
    }
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailProductItem(OrderItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                '${item.quantity}x',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${item.price} ريال / قطعة',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.price * item.quantity} ريال',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

enum DeliveryStatus { preparing, inProgress, delivered, cancelled }

class DeliveryOrder {
  final String id;
  final String customerName;
  final String customerAddress;
  final DateTime orderDate;
  final DateTime expectedDelivery;
  final DateTime? actualDelivery;
  final List<OrderItem> items;
  final DeliveryStatus status;
  final double totalAmount;
  final String? cancellationReason;

  DeliveryOrder({
    required this.id,
    required this.customerName,
    required this.customerAddress,
    required this.orderDate,
    required this.expectedDelivery,
    this.actualDelivery,
    required this.items,
    required this.status,
    required this.totalAmount,
    this.cancellationReason,
  });
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}
