import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/product_model.dart';
import '../services/inventory_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/features/products/services/products_service.dart';
import 'package:promoter_app/core/di/injection_container.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:promoter_app/features/products/models/product_model.dart'
    as ApiProduct;
import 'package:promoter_app/core/di/injection_container.dart';
import 'package:promoter_app/features/tools/scanner/scanner_screen.dart';
import 'package:promoter_app/features/products/models/product_model.dart'
    as ApiProduct;

class ProductInquiryScreen extends StatefulWidget {
  const ProductInquiryScreen({super.key});

  @override
  State<ProductInquiryScreen> createState() => _ProductInquiryScreenState();
}

class _ProductInquiryScreenState extends State<ProductInquiryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isScanning = false;
  Product? _selectedProduct;
  String _selectedTimeRange = 'شهر'; // Default time range
  final ProductsService _productsService = sl<ProductsService>();
  List<ApiProduct.Product> _relatedProducts = [];
  bool _isLoadingRelatedProducts = false;

  // Mock data for charts
  List<double> _salesData = [];
  List<double> _stockData = [];

  @override
  void initState() {
    super.initState();
    _generateMockChartData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Generate random data for charts
  void _generateMockChartData() {
    final random = Random();

    // Generate mock sales data
    _salesData = List.generate(30, (index) => random.nextDouble() * 20 + 5);

    // Generate mock stock data
    _stockData = List.generate(30, (index) {
      // Start with 100 and adjust randomly
      double currentStock = 100;
      for (int i = 0; i < index; i++) {
        // Random sales (decrease)
        currentStock -= random.nextDouble() * 8;
        // Random restocking (increase)
        if (random.nextBool() && random.nextBool()) {
          currentStock += random.nextDouble() * 20 + 10;
        }
      }
      return max(0, currentStock);
    });
  }

  // Load related products for a given product ID
  Future<void> _loadRelatedProducts(int productId) async {
    if (mounted) {
      setState(() {
        _isLoadingRelatedProducts = true;
      });
    }

    try {
      final productsService = sl<ProductsService>();
      final relatedProductsList =
          await productsService.getRelatedProducts(productId);

      if (mounted) {
        setState(() {
          _relatedProducts = relatedProductsList;
          _isLoadingRelatedProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRelatedProducts = false;
        });
      }
      _showErrorSnackBar('تعذر تحميل المنتجات المرتبطة');
    }
  }

  // Search products by name, id, or barcode
  Future<void> _searchProduct(String query) async {
    if (query.isEmpty) {
      setState(() {
        _selectedProduct = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Use the ProductsService to search for real products
      final productsService = sl<ProductsService>();
      final apiResults = await productsService.scanProduct(name: query);

      if (apiResults.isNotEmpty) {
        // Convert API product to inventory product
        final product = apiResults.first;
        final inventoryProduct = Product(
          id: product.id.toString(),
          name: product.name,
          category: product.categoryName,
          price: product.price,
          quantity: product.quantity,
          imageUrl: product.imageUrl ?? 'assets/images/yasin_app_logo.JPG',
          barcode: product.barcode,
          location: 'الرف ${product.categoryId}',
          supplier: product.companyName ?? 'المورد الرئيسي',
          lastUpdated: DateTime.parse(product.updatedAt),
        );

        setState(() {
          _isSearching = false;
          _selectedProduct = inventoryProduct;
          _generateMockChartData();
          _loadRelatedProducts(product.id);
        });
      } else {
        setState(() {
          _isSearching = false;
          _selectedProduct = null;
          _showInfoSnackBar('لم يتم العثور على نتائج');
        });
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showErrorSnackBar('حدث خطأ أثناء البحث');
    }
  }

  // Real barcode scanning with MobileScanner
  Future<void> _scanBarcode() async {
    setState(() {
      _isScanning = true;
    });

    // Show scanning dialog with live camera feed
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'مسح الباركود',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 300.h,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: MobileScanner(
                    controller: MobileScannerController(
                      detectionSpeed: DetectionSpeed.normal,
                      facing: CameraFacing.back,
                    ),
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty &&
                          barcodes.first.rawValue != null) {
                        Navigator.pop(context, barcodes.first.rawValue);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء'),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );

    setState(() {
      _isScanning = false;
    });

    if (result != null) {
      _searchController.text = result;
      await _processScannedBarcode(result);
    }
  }

  // Process scanned barcode
  Future<void> _processScannedBarcode(String barcode) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final productsService = sl<ProductsService>();
      final List<ApiProduct.Product> apiResults =
          await productsService.scanProduct(barcode: barcode);

      if (apiResults.isNotEmpty) {
        final product = apiResults.first;
        final inventoryProduct = Product(
          id: product.id.toString(),
          name: product.name,
          category: product.categoryName,
          price: product.price,
          quantity: product.quantity,
          imageUrl: product.imageUrl ?? 'assets/images/yasin_app_logo.JPG',
          barcode: product.barcode,
          location: 'الرف ${product.categoryId}',
          supplier: product.companyName ?? 'المورد الرئيسي',
          lastUpdated: DateTime.parse(product.updatedAt),
        );

        setState(() {
          _isSearching = false;
          _selectedProduct = inventoryProduct;
          _generateMockChartData();
          _loadRelatedProducts(product.id);
        });

        _showSuccessSnackBar('تم العثور على المنتج بنجاح');
      } else {
        setState(() {
          _isSearching = false;
          _selectedProduct = null;
        });
        _showInfoSnackBar('لم يتم العثور على منتج بهذا الباركود');
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showErrorSnackBar('حدث خطأ أثناء معالجة الباركود');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'الاستعلام عن صنف',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              // Show help dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('مساعدة'),
                  content: const Text(
                    'استخدم هذه الشاشة للاستعلام عن تفاصيل المنتجات ومراقبة حركة المخزون والمبيعات.\n\n'
                    '1. ابحث عن المنتج بالاسم أو الرقم التعريفي.\n'
                    '2. استخدم الماسح الضوئي للباركود للبحث السريع.\n'
                    '3. اطلع على معلومات المنتج وحالة المخزون.\n'
                    '4. راجع إحصائيات المبيعات والمخزون عبر الرسوم البيانية.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('فهمت'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and scan section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ادخل اسم المنتج أو الرقم التعريفي...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedProduct = null;
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.h, horizontal: 16.w),
                    ),
                    onFieldSubmitted: (value) {
                      _searchProduct(value);
                    },
                  ),
                ),

                // Scan button
                SizedBox(width: 12.w),
                InkWell(
                  onTap: _scanBarcode,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: _isScanning
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator or product details
          Expanded(
            child: _isSearching
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : _selectedProduct == null
                    ? _buildEmptyState(context)
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product basic details card
                              _buildProductDetailsCard(context),

                              SizedBox(height: 16.h),

                              // Stock information card
                              _buildStockInfoCard(context),

                              SizedBox(height: 16.h),

                              // Sales chart
                              _buildChartCard(
                                context: context,
                                title: 'إحصائيات المبيعات',
                                subtitle: 'آخر 30 يوم',
                                chartData: _salesData,
                                color: theme.colorScheme.primary,
                                label: 'المبيعات',
                                yAxisLabel: 'الكمية',
                                gradientColors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.5),
                                ],
                              ),

                              SizedBox(height: 16.h),

                              // Stock level chart
                              _buildChartCard(
                                context: context,
                                title: 'حركة المخزون',
                                subtitle: 'آخر 30 يوم',
                                chartData: _stockData,
                                color: Colors.amber,
                                label: 'المخزون',
                                yAxisLabel: 'الكمية',
                                gradientColors: [
                                  Colors.amber,
                                  Colors.amber.withOpacity(0.5),
                                ],
                              ),

                              SizedBox(height: 16.h),

                              // Related products
                              _buildRelatedProducts(context),

                              SizedBox(height: 16.h),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/animation/scan.json', // This would be better as an animated Lottie file
            width: 160.w,
            height: 160.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 24.h),
          Text(
            'ابحث عن منتج',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              'استخدم شريط البحث أو الماسح الضوئي للباركود للاستعلام عن منتج وعرض تفاصيله',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _scanBarcode,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 12.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('مسح الباركود'),
          ),
        ],
      ).animate().fade(duration: 300.ms),
    );
  }

  Widget _buildProductDetailsCard(BuildContext context) {
    final theme = Theme.of(context);
    final product = _selectedProduct!;

    // Determine stock status color
    Color stockStatusColor;
    String stockStatus;
    if (product.quantity > 20) {
      stockStatusColor = Colors.green;
      stockStatus = 'متوفر';
    } else if (product.quantity > 5) {
      stockStatusColor = Colors.orange;
      stockStatus = 'مخزون منخفض';
    } else if (product.quantity > 0) {
      stockStatusColor = Colors.red;
      stockStatus = 'مخزون منخفض جداً';
    } else {
      stockStatusColor = Colors.grey;
      stockStatus = 'غير متوفر';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Product header with image
          Container(
            height: 120.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12.r),
              ),
              color: theme.colorScheme.primary,
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage(product.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animate().scale(
                        begin: 0.8,
                        end: 1.0,
                        duration: 400.ms,
                      ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'رقم المنتج: ${product.id}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${product.price.toStringAsFixed(2)} ر.س',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                Divider(color: Colors.grey.shade200),

                SizedBox(height: 16.h),

                // Quick info rows
                Row(
                  children: [
                    _buildInfoItem(
                      icon: Icons.qr_code,
                      label: 'الباركود',
                      value: product.barcode,
                    ),
                    SizedBox(width: 12.w),
                    _buildInfoItem(
                      icon: Icons.location_on,
                      label: 'الموقع',
                      value: product.location,
                    ),
                    SizedBox(width: 12.w),
                    _buildInfoItem(
                      icon: Icons.business,
                      label: 'المورد',
                      value: product.supplier,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms).slide(
          begin: const Offset(0, 0.3),
          end: const Offset(0, 0),
          duration: 400.ms,
        );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final product = _selectedProduct!;

    // Determine stock status color and text
    Color stockStatusColor;
    String stockStatus;
    if (product.quantity > 20) {
      stockStatusColor = Colors.green;
      stockStatus = 'متوفر';
    } else if (product.quantity > 5) {
      stockStatusColor = Colors.orange;
      stockStatus = 'مخزون منخفض';
    } else if (product.quantity > 0) {
      stockStatusColor = Colors.red;
      stockStatus = 'مخزون منخفض جداً';
    } else {
      stockStatusColor = Colors.grey;
      stockStatus = 'غير متوفر';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  color: theme.colorScheme.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'معلومات المخزون',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Stock level indicator
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'مستوى المخزون:',
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              color: stockStatusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            stockStatus,
                            style: TextStyle(
                              color: stockStatusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: product.quantity / 50, // Max is 50
                          backgroundColor: Colors.grey.shade200,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(stockStatusColor),
                          minHeight: 8.h,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Current quantity
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'الكمية الحالية:',
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${product.quantity} قطعة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Min quantity
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'الحد الأدنى:',
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '5 قطع',
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Last update
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'آخر تحديث:',
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${product.lastUpdated.day}/${product.lastUpdated.month}/${product.lastUpdated.year}',
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.edit,
                      size: 18.sp,
                    ),
                    label: const Text('تعديل'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.history,
                      size: 18.sp,
                    ),
                    label: const Text('السجل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fade(
          duration: 400.ms,
          delay: 100.ms,
        )
        .slide(
          begin: const Offset(0, 0.3),
          end: const Offset(0, 0),
          duration: 400.ms,
          delay: 100.ms,
        );
  }

  Widget _buildChartCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<double> chartData,
    required Color color,
    required String label,
    required String yAxisLabel,
    required List<Color> gradientColors,
  }) {
    final theme = Theme.of(context);

    // Time range options
    final timeRanges = ['أسبوع', 'شهر', '3 أشهر', 'سنة'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  title.contains('مبيعات')
                      ? Icons.trending_up
                      : Icons.inventory,
                  color: color,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Time range selector chips
            SizedBox(
              height: 36.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: timeRanges.length,
                itemBuilder: (context, index) {
                  final timeRange = timeRanges[index];
                  final isSelected = timeRange == _selectedTimeRange;

                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: ChoiceChip(
                      label: Text(timeRange),
                      selected: isSelected,
                      selectedColor: color.withOpacity(0.2),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? color : Colors.grey.shade700,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12.sp,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedTimeRange = timeRange;
                            _generateMockChartData(); // Regenerate data for new time range
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16.h),

            // Chart
            SizedBox(
              height: 200.h,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          // Only show some dates
                          if (value % 5 != 0) {
                            return const SizedBox.shrink();
                          }

                          // Show dates like 1, 5, 10, 15...
                          return Text(
                            '${value.toInt() + 1}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10.sp,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(
                        yAxisLabel,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12.sp,
                        ),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10.sp,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: gradientColors,
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: false,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: gradientColors
                              .map((color) => color.withOpacity(0.2))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      // tooltipBgColor: Colors.white,
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          return LineTooltipItem(
                            '${barSpot.y.toStringAsFixed(1)}',
                            TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Chart legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fade(
          duration: 400.ms,
          delay: 200.ms,
        )
        .slide(
          begin: const Offset(0, 0.3),
          end: const Offset(0, 0),
          duration: 400.ms,
          delay: 200.ms,
        );
  }

  Widget _buildRelatedProducts(BuildContext context) {
    final theme = Theme.of(context);

    // Use either API related products or fallback to mock data if API call failed
    final List<dynamic> productsToShow = _relatedProducts.isNotEmpty
        ? _relatedProducts
        : List.generate(
            4,
            (index) => InventoryService
                .products[Random().nextInt(InventoryService.products.length)],
          );

    final bool usingApiData = _relatedProducts.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'منتجات مشابهة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'عرض الكل',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _isLoadingRelatedProducts
            ? Center(child: CircularProgressIndicator())
            : SizedBox(
                height: 170.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productsToShow.length,
                  itemBuilder: (context, index) {
                    // Handle both API product and inventory product types
                    final dynamic productItem = productsToShow[index];
                    final dynamic product = productsToShow[index];

                    // Extract product display info based on type
                    final String name = usingApiData
                        ? (productItem as ApiProduct.Product).name
                        : (productItem as Product).name;

                    final String imageUrl = usingApiData
                        ? ((productItem as ApiProduct.Product).imageUrl ??
                            'assets/images/yasin_app_logo.JPG')
                        : (productItem as Product).imageUrl;

                    final double price = usingApiData
                        ? (productItem as ApiProduct.Product).price
                        : (productItem as Product).price;

                    return Container(
                      width: 140.w,
                      margin: EdgeInsets.only(right: 12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product image
                          Container(
                            height: 80.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12.r),
                              ),
                              color: Colors.grey.shade200,
                              image: DecorationImage(
                                image: AssetImage(product.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Product info
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.sp,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${product.price.toStringAsFixed(2)} ر.س',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'المتاح: ${product.quantity}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(
                          duration: 300.ms,
                          delay: Duration(milliseconds: 300 + (index * 100)),
                        );
                    // .slideX(
                    //   begin: 0.3,
                    //   end: 0,
                    //   duration: 300.ms,
                    //   delay: Duration(milliseconds: 300 + (index * 100)),
                    // );
                  },
                ),
              ),
      ],
    );
  }
}
