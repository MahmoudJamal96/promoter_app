import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/product_model.dart';
import '../services/inventory_service.dart';
import '../../../core/constants/strings.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;
  bool _isLoading = false;
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _quantityController.text = _product.quantity.toString();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
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
    final newQuantity = int.tryParse(_quantityController.text);
    if (newQuantity == null) {
      _showErrorSnackBar('الرجاء إدخال رقم صحيح');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await InventoryService.updateProductQuantity(
        _product.id,
        newQuantity,
      );

      // Update the local product object
      setState(() {
        _product = _product.copyWith(quantity: newQuantity);
        _isLoading = false;
      });

      _showSuccessSnackBar('تم تحديث الكمية بنجاح');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('فشل في تحديث الكمية');
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المنتج'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildProductImage(),
            SizedBox(height: 24.h),
            _buildProductInfo(),
            SizedBox(height: 24.h),
            _buildProductDetails(),
            SizedBox(height: 24.h),
            _buildQuantityUpdateSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Hero(
          tag: 'product_image_${_product.id}',
          child: Image.asset(
            _product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${_product.price.toStringAsFixed(2)} ${Strings.CURRENCY}',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              _buildStockIndicator(),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            _product.name,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _product.category,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 20.sp,
                color: _getStockColor(),
              ),
              SizedBox(width: 8.w),
              Text(
                _product.quantity > 0 ? 'متوفر في المخزن' : 'غير متوفر',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: _getStockColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '(${_product.quantity} قطعة)',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockIndicator() {
    Color color = _getStockColor();
    String text = _getStockText();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStockColor() {
    if (_product.quantity > 20) {
      return Colors.green;
    } else if (_product.quantity > 5) {
      return Colors.orange;
    } else if (_product.quantity > 0) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  String _getStockText() {
    if (_product.quantity > 20) {
      return 'مخزون جيد';
    } else if (_product.quantity > 5) {
      return 'مخزون منخفض';
    } else if (_product.quantity > 0) {
      return 'مخزون محدود';
    } else {
      return 'نفذ المخزون';
    }
  }

  Widget _buildProductDetails() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل المنتج',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
            'الباركود',
            value: _product.barcode,
          ),
          _buildDetailRow(
            'الموقع',
            value: _product.location,
          ),
          _buildDetailRow(
            'المورد',
            value: _product.supplier,
          ),
          _buildDetailRow(
            'آخر تحديث',
            value:
                '${_product.lastUpdated.day}/${_product.lastUpdated.month}/${_product.lastUpdated.year}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, {required String value}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityUpdateSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تحديث الكمية',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'الكمية الجديدة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    suffixText: 'قطعة',
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Column(
                children: [
                  _buildQuantityButton(
                    icon: Icons.add,
                    onPressed: () {
                      final currentQuantity =
                          int.tryParse(_quantityController.text) ?? 0;
                      _quantityController.text =
                          (currentQuantity + 1).toString();
                    },
                  ),
                  SizedBox(height: 8.h),
                  _buildQuantityButton(
                    icon: Icons.remove,
                    onPressed: () {
                      final currentQuantity =
                          int.tryParse(_quantityController.text) ?? 0;
                      _quantityController.text = (currentQuantity - 1)
                          .clamp(0, double.infinity)
                          .toString();
                    },
                  ),
                  SizedBox(height: 8.h),
                  _buildQuantityButton(
                    icon: Icons.add,
                    onPressed: () {
                      final currentQuantity =
                          int.tryParse(_quantityController.text) ?? 0;

                      _quantityController.text =
                          (currentQuantity + 10).toString();
                    },
                  ),
                  SizedBox(height: 8.h),
                  _buildQuantityButton(
                    icon: Icons.exposure_minus_1,
                    onPressed: () {
                      final currentQuantity =
                          int.tryParse(_quantityController.text) ?? 0;
                      _quantityController.text = (currentQuantity - 10)
                          .clamp(0, double.infinity)
                          .toString();
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _updateProductQuantity,
              icon: _isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _isLoading ? 'جاري التحديث...' : 'حفظ التغييرات',
                style: TextStyle(fontSize: 16.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 40.w,
      height: 40.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
        child: Icon(icon, size: 18.sp),
      ),
    );
  }
}
