import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/product_model.dart';
import '../services/inventory_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetails() async {
    try {
      final product = await InventoryService.getProductById(widget.productId);

      setState(() {
        _product = product;
        if (product != null) {
          _quantityController.text = product.quantity.toString();
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('حدث خطأ أثناء تحميل بيانات المنتج');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _updateProductQuantity() async {
    if (_product == null) return;

    final newQuantity = int.tryParse(_quantityController.text);
    if (newQuantity == null) {
      _showErrorSnackBar('الرجاء إدخال رقم صحيح');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await InventoryService.updateProductQuantity(
        _product!.id,
        newQuantity,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        _showSuccessSnackBar('تم تحديث الكمية بنجاح');
        _loadProductDetails(); // Reload product details
      } else {
        _showErrorSnackBar('فشل تحديث الكمية');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('حدث خطأ أثناء تحديث الكمية');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المنتج'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المنتج'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 72.sp,
                color: Colors.red,
              ),
              SizedBox(height: 16.h),
              Text(
                'لم يتم العثور على المنتج',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('العودة'),
              ),
            ],
          ),
        ),
      );
    }

    // Determine stock status
    String stockStatus;
    Color stockStatusColor;

    if (_product!.quantity > 20) {
      stockStatus = 'متوفر';
      stockStatusColor = Colors.green;
    } else if (_product!.quantity > 5) {
      stockStatus = 'مخزون منخفض';
      stockStatusColor = Colors.orange;
    } else if (_product!.quantity > 0) {
      stockStatus = 'مخزون منخفض جداً';
      stockStatusColor = Colors.red;
    } else {
      stockStatus = 'غير متوفر';
      stockStatusColor = Colors.grey;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Product image and app bar
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_image_${_product!.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _product!.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16.h,
                      left: 16.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '${_product!.price.toStringAsFixed(2)} ر.س',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.primary,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.share,
                    color: theme.colorScheme.primary,
                  ),
                ),
                onPressed: () {
                  // TODO: Share product
                },
              ),
              SizedBox(width: 8.w),
            ],
          ),

          // Product details
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name and category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _product!.name,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fade(duration: 300.ms).slide(
                            begin: const Offset(0, 0.5),
                            end: const Offset(0, 0)),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          _product!.category,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Stock status
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: stockStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border:
                          Border.all(color: stockStatusColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _product!.quantity > 0
                              ? Icons.check_circle
                              : Icons.remove_circle,
                          color: stockStatusColor,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          stockStatus,
                          style: TextStyle(
                            color: stockStatusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '(${_product!.quantity} قطعة)',
                          style: TextStyle(
                            color: stockStatusColor,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Divider
                  Divider(color: Colors.grey.shade300),

                  SizedBox(height: 16.h),

                  // Product details section
                  Text(
                    'معلومات المنتج',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(duration: 300.ms, delay: 200.ms),

                  SizedBox(height: 16.h),

                  // Product information list
                  _buildInfoItem(
                    icon: Icons.qr_code,
                    label: 'الباركود',
                    value: _product!.barcode,
                  ),

                  _buildInfoItem(
                    icon: Icons.location_on,
                    label: 'الموقع',
                    value: _product!.location,
                  ),

                  _buildInfoItem(
                    icon: Icons.business,
                    label: 'المورد',
                    value: _product!.supplier,
                  ),

                  _buildInfoItem(
                    icon: Icons.access_time,
                    label: 'آخر تحديث',
                    value:
                        '${_product!.lastUpdated.day}/${_product!.lastUpdated.month}/${_product!.lastUpdated.year}',
                  ),

                  SizedBox(height: 24.h),

                  // Update quantity section
                  Text(
                    'تحديث الكمية',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade(duration: 300.ms, delay: 400.ms),

                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'الكمية الجديدة',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _updateProductQuantity,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'تحديث',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fade(duration: 300.ms, delay: 500.ms),

                  SizedBox(height: 16.h),

                  // Quick adjust buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAdjustButton(
                        label: '+1',
                        onPressed: () {
                          final currentValue =
                              int.tryParse(_quantityController.text) ?? 0;
                          _quantityController.text =
                              (currentValue + 1).toString();
                        },
                      ),
                      SizedBox(width: 8.w),
                      _buildAdjustButton(
                        label: '+5',
                        onPressed: () {
                          final currentValue =
                              int.tryParse(_quantityController.text) ?? 0;
                          _quantityController.text =
                              (currentValue + 5).toString();
                        },
                      ),
                      SizedBox(width: 8.w),
                      _buildAdjustButton(
                        label: '+10',
                        onPressed: () {
                          final currentValue =
                              int.tryParse(_quantityController.text) ?? 0;
                          _quantityController.text =
                              (currentValue + 10).toString();
                        },
                      ),
                      SizedBox(width: 8.w),
                      _buildAdjustButton(
                        label: '-1',
                        onPressed: () {
                          final currentValue =
                              int.tryParse(_quantityController.text) ?? 0;
                          if (currentValue > 0) {
                            _quantityController.text =
                                (currentValue - 1).toString();
                          }
                        },
                      ),
                      SizedBox(width: 8.w),
                      _buildAdjustButton(
                        label: '-5',
                        onPressed: () {
                          final currentValue =
                              int.tryParse(_quantityController.text) ?? 0;
                          _quantityController.text =
                              (currentValue - 5 > 0 ? currentValue - 5 : 0)
                                  .toString();
                        },
                      ),
                    ],
                  ).animate().fade(duration: 300.ms, delay: 600.ms),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12.sp,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(
          duration: 300.ms,
          delay: Duration(milliseconds: 200 + (_buildInfoItemIndex++ * 100)),
        );
  }

  int _buildInfoItemIndex = 0;

  Widget _buildAdjustButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isPositive = label.startsWith('+');

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isPositive
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isPositive
                ? theme.colorScheme.primary.withOpacity(0.5)
                : Colors.red.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isPositive ? theme.colorScheme.primary : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
