import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/core/constants/assets.dart';
import 'package:promoter_app/core/constants/strings.dart';
import 'package:promoter_app/core/di/injection_container.dart';
import 'package:promoter_app/core/error/exceptions.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';
import 'package:promoter_app/core/view/widgets/image_loader.dart';
import 'package:promoter_app/features/inventory/models/product_model.dart';
import 'package:promoter_app/features/inventory/services/inventory_service.dart';
import 'package:promoter_app/features/inventory/widgets/warehouse_card.dart';
import 'package:promoter_app/features/inventory_transfer/models/inventory_transfer_model.dart';
import 'package:promoter_app/features/inventory_transfer/services/inventory_transfer_service.dart';
import 'package:promoter_app/features/products/services/products_service.dart';
import 'package:promoter_app/features/sales_invoice/services/order_service.dart';

class WarehouseTransferScreen extends StatefulWidget {
  const WarehouseTransferScreen({super.key});

  @override
  State<WarehouseTransferScreen> createState() => _WarehouseTransferScreenState();
}

class _WarehouseTransferScreenState extends State<WarehouseTransferScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Mock data for warehouses
  final List<Map<String, dynamic>> warehouses = [
    {
      'name': 'المخزن الرئيسي',
      'code': 'WH001',
      'itemsCount': 120,
    },
    {
      'name': 'مخزن 1',
      'code': 'WH002',
      'itemsCount': 85,
    },
    {
      'name': 'المخزن 2',
      'code': 'WH003',
      'itemsCount': 42,
    },
    {
      'name': 'مخزن 3',
      'code': 'WH004',
      'itemsCount': 16,
    },
  ];
  // Default destination warehouse for all transfers
  final Map<String, dynamic> defaultDestinationWarehouse = {
    'name': 'المخزن الرئيسي',
    'code': 'WH001',
    'itemsCount': 120,
  };

  // Default source warehouse (since you have only one warehouse)
  final Map<String, dynamic> defaultSourceWarehouse = {
    'name': 'مخزن الفرع',
    'code': 'WH002',
    'itemsCount': 85,
  };
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // // Navigate directly to transfer form since you have only one warehouse
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _navigateToTransferForm(
    //     defaultSourceWarehouse,
    //     defaultDestinationWarehouse,
    //     isTransferRequest: true,
    //   );
    // });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter warehouses based on search query
    final filteredWarehouses = warehouses.where((warehouse) {
      final name = warehouse['name'].toString().toLowerCase();
      final code = warehouse['code'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || code.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تحويل المخزون',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: const Color(0xFF148ccd),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'طلب تحويل'),
            Tab(text: 'طلب مرتجع'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // طلب تحويل (Transfer Request)
          _buildTransferRequestTab(filteredWarehouses),

          // طلب مرتجع (Return Request)
          _buildReturnRequestTab(filteredWarehouses),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SoundManager().playClickSound();
          // Navigate to add new warehouse
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('إضافة مخزن جديد')),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  // Transfer Request Tab
  Widget _buildTransferRequestTab(List<Map<String, dynamic>> filteredWarehouses) {
    // Filter out the default destination warehouse from source options
    final sourceWarehouses = filteredWarehouses.where((warehouse) {
      return warehouse['code'] != defaultDestinationWarehouse['code'];
    }).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              // Show destination warehouse info

              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'بحث عن مخزن مصدر...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            SoundManager().playClickSound();
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: sourceWarehouses.isEmpty
              ? _buildEmptyState(
                  'لا توجد مخازن مطابقة للبحث', 'حاول البحث بكلمات أخرى أو أضف مخزن جديد')
              : ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: sourceWarehouses.length,
                  itemBuilder: (context, index) {
                    final warehouse = sourceWarehouses[index];
                    return WarehouseCard(
                      name: warehouse['name'],
                      code: warehouse['code'],
                      itemsCount: warehouse['itemsCount'],
                      onTap: () => _navigateToTransferForm(
                        warehouse,
                        defaultDestinationWarehouse,
                        isTransferRequest: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Return Request Tab
  Widget _buildReturnRequestTab(List<Map<String, dynamic>> filteredWarehouses) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'بحث عن مخزن مستقبل...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            SoundManager().playClickSound();
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredWarehouses.isEmpty
              ? _buildEmptyState(
                  'لا توجد مخازن مطابقة للبحث', 'حاول البحث بكلمات أخرى أو أضف مخزن جديد')
              : ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: filteredWarehouses.length,
                  itemBuilder: (context, index) {
                    final warehouse = filteredWarehouses[index];
                    // Filter out the destination warehouse from source options for returns
                    if (warehouse['code'] == defaultDestinationWarehouse['code']) {
                      return const SizedBox
                          .shrink(); // Don't show the destination warehouse as source
                    }
                    return WarehouseCard(
                      name: warehouse['name'],
                      code: warehouse['code'],
                      itemsCount: warehouse['itemsCount'],
                      onTap: () => _navigateToTransferForm(
                        warehouse,
                        defaultDestinationWarehouse,
                        isTransferRequest: false,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ImageLoader(
            path: Assets.warehouseLottie,
            height: 150.h,
            width: 150.w,
            fit: BoxFit.contain,
            repeated: true,
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToTransferForm(
    Map<String, dynamic> sourceWarehouse,
    Map<String, dynamic> destinationWarehouse, {
    required bool isTransferRequest,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WarehouseTransferFormScreen(
          sourceWarehouse: sourceWarehouse,
          destinationWarehouse: destinationWarehouse,
          isTransferRequest: isTransferRequest,
        ),
      ),
    );
  }
}

class WarehouseTransferFormScreen extends StatefulWidget {
  final Map<String, dynamic> sourceWarehouse;
  final Map<String, dynamic> destinationWarehouse;
  final bool isTransferRequest;

  const WarehouseTransferFormScreen({
    super.key,
    required this.sourceWarehouse,
    required this.destinationWarehouse,
    required this.isTransferRequest,
  });

  @override
  State<WarehouseTransferFormScreen> createState() => _WarehouseTransferFormScreenState();
}

class _WarehouseTransferFormScreenState extends State<WarehouseTransferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;
  late ProductsService _productsService;
  late OrderService _orderService;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Product> _searchResults = [];
  final List<SalesItem> _cartItems = [];
  // Mock product data
  // Search products by name or barcode using API
  @override
  initState() {
    super.initState();
    _productsService = sl<ProductsService>();
    _orderService = OrderService();
    _searchController.addListener(() {
      _searchProducts(_searchController.text);
    });
  }

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
      // Use ProductsService to search products via API
      final apiResults = await _productsService.scanProduct(name: query);

      // Convert API products to local Product model
      final List<Product> results = apiResults
          .map((apiProduct) => Product(
                id: apiProduct.id.toString(),
                name: apiProduct.name,
                category: apiProduct.categoryName,
                price: apiProduct.price,
                quantity: apiProduct.quantity,
                imageUrl: apiProduct.imageUrl ?? 'assets/images/yasin_app_logo.JPG',
                barcode: apiProduct.barcode,
                location: 'الرف ${apiProduct.categoryId}',
                supplier: apiProduct.companyName ?? 'غير محدد',
                lastUpdated: DateTime.tryParse(apiProduct.updatedAt) ?? DateTime.now(),
                units: apiProduct.units, // Include units if available
              ))
          .toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      if (e is ApiException) {
        // _showErrorSnackBar('فشل في البحث عن المنتجات: ${e.message}');
      } else {
        // _showErrorSnackBar('حدث خطأ أثناء البحث: ${e.toString()}');
      }
    }
  }

  // Add product to cart
  void _addToCart(Product product) {
    SoundManager().playClickSound();
    final existingItemIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex >= 0) {
      // Increment quantity
      setState(() {
        _cartItems[existingItemIndex] = _cartItems[existingItemIndex].copyWith(
          quantity: _cartItems[existingItemIndex].quantity + 1,
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

    //   _showSuccessSnackBar('تم إضافة ${product.name} إلى الفاتورة');
  }

  // Remove product from cart
  void _removeFromCart(int index) {
    SoundManager().playClickSound();
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  // Update cart item quantity
  void _updateCartItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
      return;
    }

    setState(() {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
    });
  }

  final List<Map<String, String>> products = [
    {'name': 'لابتوب أيسر', 'code': 'P001'},
    {'name': 'طابعة HP', 'code': 'P002'},
    {'name': 'موبايل سامسونج', 'code': 'P003'},
    {'name': 'شاشة LG', 'code': 'P004'},
    {'name': 'ماوس لوجيتك', 'code': 'P005'},
  ];

  Map<String, String>? _selectedProduct;

  @override
  void dispose() {
    _productController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(icon, size: 18.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isTransferRequest ? 'نموذج طلب التحويل' : 'نموذج طلب المرتجع';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF148ccd),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن منتج...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  SoundManager().playClickSound();
                                  _searchController.clear();
                                  setState(() {
                                    _searchResults = [];
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _searchProducts(value);
                        } else {
                          setState(() {
                            _searchResults = [];
                          });
                        }
                      },
                    ),

                    // Search results
                    if (_isSearching)
                      Container(
                        height: 200.h,
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_searchResults.isNotEmpty)
                      Container(
                        height: 200.h,
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.all(8.w),
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: Colors.grey.shade200),
                          itemBuilder: (context, index) {
                            final product = _searchResults[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(product.imageUrl),
                                onBackgroundImageError: (_, __) {},
                                child: product.imageUrl.isEmpty
                                    ? Icon(Icons.inventory, size: 20.sp)
                                    : null,
                              ),
                              title: Text(
                                product.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                              subtitle: Text(
                                'سعر: ${product.price.toStringAsFixed(2)} ${Strings.CURRENCY} | المتاح: ${product.quantity}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.green),
                                onPressed: () => _addToCart(product),
                              ),
                              onTap: () => _addToCart(product),
                            );
                          },
                        ),
                      ).animate().fade(duration: 200.ms),
                    if (_cartItems.isNotEmpty) SizedBox(height: 16.h),
                    if (_cartItems.isNotEmpty)
                      Text(
                        'المنتجات المضافة إلى الطلب',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.all(0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...List.generate(_cartItems.length, (index) {
                            final item = _cartItems[index];
                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                              '${item.price.toStringAsFixed(2)} ${Strings.CURRENCY}',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Theme.of(context).colorScheme.primary,
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
                                                _updateCartItemQuantity(index, item.quantity - 1),
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
                                                _updateCartItemQuantity(index, item.quantity + 1),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 16.w),
                                      Text(
                                        '${item.total.toStringAsFixed(2)} ${Strings.CURRENCY}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _removeFromCart(index),
                                        iconSize: 20.sp,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                                if (index < _cartItems.length - 1)
                                  Divider(
                                    height: 16.h,
                                    thickness: 1,
                                    color: Colors.grey.shade200,
                                  ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Conditional reason field for return requests
                    if (!widget.isTransferRequest) ...[
                      SizedBox(height: 16.h),
                      Text(
                        'سبب الإرجاع',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _reasonController,
                        decoration: InputDecoration(
                          hintText: 'أدخل سبب الإرجاع',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        ),
                        validator: (value) {
                          if (!widget.isTransferRequest && (value == null || value.isEmpty)) {
                            return 'برجاء إدخال سبب الإرجاع';
                          }
                          return null;
                        },
                      ),
                    ],
                    if (_cartItems.isNotEmpty) SizedBox(height: 8.h),
                    if (_cartItems.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("إجمالي الكمية : ",
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          Text("( ${_cartItems.fold(0, (sum, item) => sum + item.quantity)} )",
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    if (_cartItems.isNotEmpty) SizedBox(height: 8.h),
                    if (_cartItems.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("المجموع الكلي : ",
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          Text(
                              "( ${_cartItems.fold(0.0, (sum, item) => sum + (item.total * item.quantity)).toStringAsFixed(2)} ${Strings.CURRENCY}   )",
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    if (_cartItems.isNotEmpty) SizedBox(height: 8.h),
                    if (_cartItems.isNotEmpty)
                      Divider(
                        height: 1,
                        color: Colors.grey.shade300,
                      ),

                    Text(
                      'ملاحظات (اختياري)',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'أدخل أي ملاحظات إضافية',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.isTransferRequest ? 'إرسال طلب التحويل' : 'إرسال طلب المرتجع',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Future<void> _submitForm() async {
    SoundManager().playClickSound();
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final inventoryTransferService = sl<InventoryTransferService>();

        // Prepare request data
        final items = [
          {
            'product_id': int.parse(_selectedProduct!['code']!.substring(1)), // Convert P001 to 001
            'quantity': int.parse(_quantityController.text),
          }
        ];

        InventoryTransfer result;

        if (widget.isTransferRequest) {
          // Handle transfer request
          result = await inventoryTransferService.requestTransfer(
            items: items,
            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          );

          _showTransferSuccessDialog(
            isTransfer: true,
            transferNumber: result.transferNumber,
            fromWarehouse: widget.sourceWarehouse['name'],
            toWarehouse: widget.destinationWarehouse['name'],
            products: ['${_selectedProduct!['name']} (${_quantityController.text})'],
          );
        } else {
          // Handle return request
          result = await inventoryTransferService.requestReturn(
            items: items,
            reason: _reasonController.text,
            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          );

          _showTransferSuccessDialog(
            isTransfer: false,
            transferNumber: result.transferNumber,
            fromWarehouse: widget.sourceWarehouse['name'],
            toWarehouse: widget.destinationWarehouse['name'],
            products: ['${_selectedProduct!['name']} (${_quantityController.text})'],
            reason: _reasonController.text,
          );
        }
      } catch (error) {
        _showErrorMessage('حدث خطأ أثناء إرسال الطلب: ${error.toString()}');
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Show success dialog with transfer details
  void _showTransferSuccessDialog({
    required bool isTransfer,
    required String transferNumber,
    required String fromWarehouse,
    required String toWarehouse,
    required List<String> products,
    String? reason,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                isTransfer ? 'تم إرسال طلب التحويل بنجاح' : 'تم إرسال طلب المرتجع بنجاح',
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('رقم الطلب: $transferNumber'),
              SizedBox(height: 8.h),
              Text('من: $fromWarehouse'),
              Text('إلى: $toWarehouse'),
              SizedBox(height: 8.h),
              const Text('المنتجات:'),
              ...products.map((product) => Padding(
                    padding: EdgeInsets.only(right: 16.w, top: 4.h),
                    child: Text('- $product'),
                  )),
              if (reason != null) ...[
                SizedBox(height: 8.h),
                Text('سبب الإرجاع: $reason'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                SoundManager().playClickSound();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
