import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../models/product_model.dart';
import '../services/inventory_service.dart';

class SalesInvoiceScreen extends StatefulWidget {
  const SalesInvoiceScreen({super.key});

  @override
  State<SalesInvoiceScreen> createState() => _SalesInvoiceScreenState();
}

class _SalesInvoiceScreenState extends State<SalesInvoiceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController =
      TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  bool _isSearching = false;
  List<Product> _searchResults = [];
  List<SalesItem> _cartItems = [];
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();
    _discountController.text = '0';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  // Search products by name or barcode
  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await InventoryService.searchProducts(query);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showErrorSnackBar('حدث خطأ أثناء البحث');
    }
  }

  // Add product to cart
  void _addToCart(Product product) {
    // Check if product already in cart
    final existingItemIndex =
        _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex >= 0) {
      // Increment quantity
      setState(() {
        final currentItem = _cartItems[existingItemIndex];
        _cartItems[existingItemIndex] = SalesItem(
          product: currentItem.product,
          quantity: currentItem.quantity + 1,
          price: currentItem.price,
        );
      });
    } else {
      // Add new item
      setState(() {
        _cartItems.add(SalesItem(
          product: product,
          quantity: 1,
          price: product.price,
        ));
      });
    }

    // Clear search
    _searchController.clear();
    setState(() {
      _searchResults = [];
    });

    _showSuccessSnackBar('تم إضافة ${product.name} إلى السلة');
  }

  // Remove product from cart
  void _removeFromCart(int index) {
    final removedItem = _cartItems[index];
    setState(() {
      _cartItems.removeAt(index);
    });

    _showInfoSnackBar('تم حذف ${removedItem.product.name} من السلة');
  }

  // Update product quantity in cart
  void _updateCartItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
      return;
    }

    setState(() {
      final currentItem = _cartItems[index];
      _cartItems[index] = SalesItem(
        product: currentItem.product,
        quantity: newQuantity,
        price: currentItem.price,
      );
    });
  }

  // Calculate subtotal
  double get _subtotal => _cartItems.fold(0, (sum, item) => sum + item.total);

  // Calculate VAT (15%)
  double get _vat => _subtotal * 0.15;

  // Calculate discount
  double get _discount => double.tryParse(_discountController.text) ?? 0;

  // Calculate total
  double get _total => _subtotal + _vat - _discount;

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Show info snackbar
  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Create invoice and save
  Future<void> _createInvoice() async {
    if (_cartItems.isEmpty) {
      _showErrorSnackBar('أضف منتجات إلى الفاتورة أولاً');
      return;
    }

    if (_customerNameController.text.isEmpty) {
      _showErrorSnackBar('أدخل اسم العميل');
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري إنشاء الفاتورة...'),
          ],
        ),
      ),
    );

    try {
      // Create invoice
      final invoice = await SalesService.createInvoice(
        _cartItems,
        _customerNameController.text,
        _customerPhoneController.text.isEmpty
            ? 'غير محدد'
            : _customerPhoneController.text,
        _selectedPaymentMethod,
        _discount,
      );

      // Close loading dialog
      Navigator.pop(context);

      // Show success and navigate to invoice details
      _showInvoiceCreatedDialog(invoice);
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      _showErrorSnackBar('حدث خطأ أثناء إنشاء الفاتورة');
    }
  }

  // Show invoice created dialog
  void _showInvoiceCreatedDialog(SalesInvoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            const Text('تم إنشاء الفاتورة بنجاح'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('رقم الفاتورة: ${invoice.invoiceId}'),
            SizedBox(height: 8.h),
            Text('إجمالي الفاتورة: ${invoice.total.toStringAsFixed(2)} ر.س'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('فاتورة جديدة'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to invoice details screen
              _resetForm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('عرض التفاصيل'),
          ),
        ],
      ),
    );
  }

  // Reset form after creating invoice
  void _resetForm() {
    setState(() {
      _cartItems = [];
      _customerNameController.clear();
      _customerPhoneController.clear();
      _discountController.text = '0';
      _selectedPaymentMethod = PaymentMethod.cash;
    });
  }

  // Scan barcode (mock implementation)
  Future<void> _scanBarcode() async {
    // Show scanning animation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('جاري المسح...'),
          content: SizedBox(
            height: 100.h,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );

    // Simulate delay
    await Future.delayed(const Duration(seconds: 1));

    // Dismiss dialog
    Navigator.pop(context);

    // Mock scan result (random product)
    final randomIndex =
        DateTime.now().millisecond % InventoryService.products.length;
    final scannedProduct = InventoryService.products[randomIndex];

    // Add scanned product to cart
    _addToCart(scannedProduct);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'فاتورة مبيعات جديدة',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon:
                Icon(Icons.qr_code_scanner, color: theme.colorScheme.onSurface),
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج بالاسم أو الباركود...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    _searchResults = [];
                  });
                } else {
                  _searchProducts(value);
                }
              },
            ),
          ),

          // Search results (if any)
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_searchResults.isNotEmpty)
            Container(
              constraints: BoxConstraints(maxHeight: 200.h),
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  return ListTile(
                    title: Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                    ),
                    subtitle: Text(
                      'سعر: ${product.price.toStringAsFixed(2)} ر.س | المتاح: ${product.quantity}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => _addToCart(product),
                    ),
                  );
                },
              ),
            ).animate().fade(duration: 200.ms),

          // Cart items and summary
          Expanded(
            child: _cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 72.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'لا توجد منتجات في الفاتورة',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'ابحث عن منتج لإضافته إلى الفاتورة',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ).animate().fade(duration: 300.ms),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: ListView.separated(
                              padding: EdgeInsets.all(16.w),
                              itemCount: _cartItems.length,
                              separatorBuilder: (context, index) => Divider(
                                  height: 1, color: Colors.grey.shade200),
                              itemBuilder: (context, index) {
                                final item = _cartItems[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14.sp,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              '${item.price.toStringAsFixed(2)} ر.س',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Row(
                                        children: [
                                          _buildQuantityButton(
                                            icon: Icons.remove,
                                            onTap: () =>
                                                _updateCartItemQuantity(
                                                    index, item.quantity - 1),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            item.quantity.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          _buildQuantityButton(
                                            icon: Icons.add,
                                            onTap: () =>
                                                _updateCartItemQuantity(
                                                    index, item.quantity + 1),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 16.w),
                                      Text(
                                        '${item.total.toStringAsFixed(2)} ر.س',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () => _removeFromCart(index),
                                        iconSize: 20.sp,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Customer info section
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'بيانات العميل',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _customerNameController,
                                        decoration: InputDecoration(
                                          labelText: 'اسم العميل',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 12.h,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _customerPhoneController,
                                        decoration: InputDecoration(
                                          labelText: 'رقم الهاتف',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 12.h,
                                          ),
                                        ),
                                        keyboardType: TextInputType.phone,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'طريقة الدفع',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    _buildPaymentMethodOption(
                                      method: PaymentMethod.cash,
                                      label: 'نقدي',
                                      icon: Icons.money,
                                    ),
                                    SizedBox(width: 16.w),
                                    _buildPaymentMethodOption(
                                      method: PaymentMethod.creditCard,
                                      label: 'بطاقة',
                                      icon: Icons.credit_card,
                                    ),
                                    SizedBox(width: 16.w),
                                    _buildPaymentMethodOption(
                                      method: PaymentMethod.bankTransfer,
                                      label: 'تحويل',
                                      icon: Icons.account_balance,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Summary section
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'المجموع الفرعي:',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    Text(
                                      '${_subtotal.toStringAsFixed(2)} ر.س',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'ضريبة القيمة المضافة (15%):',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    Text(
                                      '${_vat.toStringAsFixed(2)} ر.س',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'الخصم:',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100.w,
                                      child: TextFormField(
                                        controller: _discountController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+\.?\d{0,2}')),
                                        ],
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8.w, vertical: 8.h),
                                          suffixText: 'ر.س',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                        ),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 24.h, thickness: 1),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'الإجمالي:',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${_total.toStringAsFixed(2)} ر.س',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                ElevatedButton(
                                  onPressed: _createInvoice,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(vertical: 14.h),
                                    minimumSize: Size(double.infinity, 50.h),
                                  ),
                                  child: Text(
                                    'إنشاء الفاتورة',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required PaymentMethod method,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isSelected = method == _selectedPaymentMethod;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color:
                  isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey.shade600,
                size: 24.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
