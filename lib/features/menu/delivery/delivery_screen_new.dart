import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';

import '../../../core/di/injection_container.dart';
import 'models/delivery_order_model.dart';
import 'services/delivery_service.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DeliveryService _deliveryService = sl<DeliveryService>();

  List<DeliveryOrder> _activeOrders = [];
  List<DeliveryOrder> _completedOrders = [];
  List<DeliveryOrder> _cancelledOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    SoundManager().playClickSound();
    setState(() {
      _isLoading = true;
    });

    try {
      final activeOrders = await _deliveryService.getActiveOrders();
      final completedOrders = await _deliveryService.getCompletedOrders();
      final cancelledOrders = await _deliveryService.getCancelledOrders();

      setState(() {
        _activeOrders = activeOrders;
        _completedOrders = completedOrders;
        _cancelledOrders = cancelledOrders;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'إدارة التوصيل',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF148ccd),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOrders,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: 'نشطة (${_activeOrders.length})'),
            Tab(text: 'مكتملة (${_completedOrders.length})'),
            Tab(text: 'ملغاة (${_cancelledOrders.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
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
                begin: const Offset(0, 10),
                end: const Offset(0, 0),
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
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  order.id,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(Icons.person, order.customerName),
            SizedBox(height: 8.h),
            _buildInfoRow(Icons.location_on, order.customerAddress),
            if (order.customerPhone != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: _buildInfoRow(Icons.phone, order.customerPhone!),
              ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.calendar_today,
                    '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    Icons.access_time,
                    '${order.expectedDelivery.day}/${order.expectedDelivery.month}/${order.expectedDelivery.year}',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(color: Colors.grey.shade300),
            SizedBox(height: 8.h),
            ...order.items.map((item) => _buildProductItem(item)),
            Divider(color: Colors.grey.shade300),
            SizedBox(height: 8.h),
            if (order.status == DeliveryStatus.cancelled && order.notes != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سبب الإلغاء:',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      order.notes ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'المجموع: ${order.totalAmount.toStringAsFixed(2)} جنيه',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                if (isActive)
                  ElevatedButton.icon(
                    onPressed: () => _showOrderDetails(order),
                    icon: Icon(Icons.visibility, size: 16.sp),
                    label: const Text('التفاصيل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey.shade600),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(OrderItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
          Text(
            '${item.quantity} × ${item.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '${item.totalPrice.toStringAsFixed(2)} جنيه',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.preparing:
        return Colors.orange;
      case DeliveryStatus.inProgress:
        return const Color(0xFF148ccd);
      case DeliveryStatus.delivered:
        return Colors.green;
      case DeliveryStatus.cancelled:
        return Colors.red;
    }
  }

  void _showOrderDetails(DeliveryOrder order) {
    SoundManager().playClickSound();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تفاصيل الطلب',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 16.h),
              Column(
                children: [
                  _buildDetailItem('رقم الطلب', order.id),
                  _buildDetailItem('العميل', order.customerName),
                  _buildDetailItem('العنوان', order.customerAddress),
                  if (order.customerPhone != null) _buildDetailItem('الهاتف', order.customerPhone!),
                  _buildDetailItem('تاريخ الطلب',
                      '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}'),
                  _buildDetailItem('تاريخ التوصيل المتوقع',
                      '${order.expectedDelivery.day}/${order.expectedDelivery.month}/${order.expectedDelivery.year}'),
                  if (order.actualDelivery != null)
                    _buildDetailItem('تاريخ التوصيل الفعلي',
                        '${order.actualDelivery!.day}/${order.actualDelivery!.month}/${order.actualDelivery!.year}'),
                  _buildDetailItem('الحالة', order.status.displayName),
                  if (order.paymentMethod != null)
                    _buildDetailItem('طريقة الدفع', order.paymentMethod!),
                  if (order.notes != null) _buildDetailItem('ملاحظات', order.notes!),
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
              ...order.items.map((item) => _buildDetailProductItem(item)),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'المجموع الإجمالي: ${order.totalAmount.toStringAsFixed(2)} جنيه',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    SoundManager().playClickSound();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailProductItem(OrderItem item) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '${item.quantity} × ${item.price.toStringAsFixed(2)} = ${item.totalPrice.toStringAsFixed(2)} جنيه',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
