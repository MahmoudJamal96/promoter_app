import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/inventory_item.dart';
import '../models/product_model.dart';
import '../services/inventory_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'product_detail_screen.dart';
import '../../../core/constants/strings.dart';
import '../../../features/products/services/products_service.dart';
import '../../../core/di/injection_container.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  // For product list view
  List<Product> _products = [];
  bool _isLoading = true;
  String _selectedCategory = 'الكل';
  int _currentPage = 0;
  bool _hasMoreData = true;
  late ProductsService _productsService;

  // For inventory management
  List<InventoryItem> _inventoryItems = [];
  List<InventoryItem> _filteredInventoryItems = [];
  bool _countingMode = false;
  bool _showDifferencesOnly = false;
  bool _isInventorySaving = false;
  String _inventorySearchQuery = '';

  // Unit display selection
  bool _showPrimaryUnits = true;

  // Variable to store categories
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _productsService = sl<ProductsService>();
    _loadProducts();
    _loadInventoryItems();
    _loadCategories(); // Load categories from API

    // Set up pagination
    _scrollController.addListener(_scrollListener);

    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  } // Load inventory items for counting

  Future<void> _loadInventoryItems() async {
    try {
      final inventoryService = InventoryService();
      final items = await inventoryService.getInventoryItems();

      setState(() {
        _inventoryItems = items;
        _filteredInventoryItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('فشل تحميل بيانات المخزون');
    }
  }

  // Load categories from API
  Future<void> _loadCategories() async {
    try {
      final categories = await _productsService.getCategories();
      setState(() {
        _categories = categories;
        // Add "All" category at the beginning
        if (!_categories.any((cat) => cat['name'] == 'الكل')) {
          _categories.insert(0, {'id': 0, 'name': 'الكل'});
        }
      });
    } catch (e) {
      _showErrorSnackbar('فشل تحميل التصنيفات');
    }
  }

  // Calculate total inventory value
  double get _totalInventoryValue {
    return _filteredInventoryItems.fold(
        0, (sum, item) => sum + item.totalValue);
  }

  // Filter inventory items based on search
  void _filterInventoryItems() {
    if (_inventorySearchQuery.isEmpty) {
      setState(() {
        _filteredInventoryItems = _inventoryItems;
      });
      return;
    }

    setState(() {
      _filteredInventoryItems = _inventoryItems.where((item) {
        return item.name.contains(_inventorySearchQuery);
      }).toList();
    });
  } // Save counted inventory

  Future<void> _saveInventoryCounts() async {
    setState(() {
      _isInventorySaving = true;
    });

    try {
      await InventoryService.saveInventoryCount(_inventoryItems);

      setState(() {
        _isInventorySaving = false;
        _countingMode = false;
      });

      _showSuccessSnackbar('تم حفظ تعديلات الجرد بنجاح');
    } catch (e) {
      setState(() {
        _isInventorySaving = false;
      });
      _showErrorSnackbar('فشل حفظ بيانات الجرد');
    }
  }

  // Update actual count for an item
  void _updateActualCount(String id, double value) {
    final index = _inventoryItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      setState(() {
        _inventoryItems[index] =
            _inventoryItems[index].copyWith(actualCount: value);
        _filterInventoryItems();
      });
    }
  }

  // Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show success snackbar
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Load initial products or next page
  Future<void> _loadProducts() async {
    if (!_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiResponse =
          await _productsService.getProducts(page: _currentPage + 1);

      // Convert API Product model to Inventory Product model
      final List<Product> newProducts = apiResponse
          .map((p) => Product(
                id: p.id.toString(),
                name: p.name,
                category: p.categoryName,
                price: p.price,
                quantity: p.quantity,
                imageUrl: p.imageUrl ?? 'assets/images/yasin_app_logo.JPG',
                barcode: p.barcode,
                location: 'الرف ${p.categoryId}',
                supplier: p.companyName ?? 'غير محدد',
                lastUpdated: DateTime.tryParse(p.updatedAt) ?? DateTime.now(),
              ))
          .toList();

      setState(() {
        if (newProducts.isEmpty) {
          _hasMoreData = false;
        } else {
          _products.addAll(newProducts);
          _currentPage++;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('حدث خطأ أثناء تحميل المنتجات');
    }
  }

  // Load products filtered by category
  Future<void> _loadProductsByCategory(int categoryId) async {
    if (!_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiResponse = await _productsService.getProducts(
          page: _currentPage + 1, categoryId: categoryId);

      // Convert API Product model to Inventory Product model
      final List<Product> newProducts = apiResponse
          .map((p) => Product(
                id: p.id.toString(),
                name: p.name,
                category: p.categoryName,
                price: p.price,
                quantity: p.quantity,
                imageUrl: p.imageUrl ?? 'assets/images/yasin_app_logo.JPG',
                barcode: p.barcode,
                location: 'الرف ${p.categoryId}',
                supplier: p.companyName ?? 'غير محدد',
                lastUpdated: DateTime.tryParse(p.updatedAt) ?? DateTime.now(),
              ))
          .toList();

      setState(() {
        if (newProducts.isEmpty) {
          _hasMoreData = false;
        } else {
          _products.addAll(newProducts);
          _currentPage++;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('حدث خطأ أثناء تحميل المنتجات');
    }
  }

  // Search for products

  Future<void> _searchProducts(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the ProductsService to search for products via getProducts method
      final apiResults = await _productsService.getProducts(search: query);

      // Convert API Product model to Inventory Product model
      final List<Product> results = apiResults
          .map((p) => Product(
                id: p.id.toString(),
                name: p.name,
                category: p.categoryName,
                price: p.price,
                quantity: p.quantity,
                imageUrl: p.imageUrl ?? 'assets/images/yasin_app_logo.JPG',
                barcode: p.barcode,
                location: 'الرف ${p.categoryId}',
                supplier: p.companyName ?? 'غير محدد',
                lastUpdated: DateTime.tryParse(p.updatedAt) ?? DateTime.now(),
              ))
          .toList();

      setState(() {
        _products = results;
        _isLoading = false;
        _hasMoreData = false; // Disable pagination during search
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('حدث خطأ أثناء البحث');
    }
  }

  // Filter by category
  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _products = [];
      _currentPage = 0;
      _hasMoreData = true;
    });

    // If not the "All" category, filter by category when loading products
    if (category != 'الكل') {
      // Find the category ID
      final categoryEntry = _categories.firstWhere(
        (cat) => cat['name'] == category,
        orElse: () => {'id': 0, 'name': 'الكل'},
      );
      final int categoryId = categoryEntry['id'] as int;

      // Load products filtered by category
      _loadProductsByCategory(categoryId);
    } else {
      // Load all products
      _loadProducts();
    }
  }

  // Scroll listener for pagination
  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMoreData) {
      _loadProducts();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'إدارة المخزون',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'المنتجات'),
            Tab(text: 'جرد المخزون'),
          ],
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: theme.colorScheme.onSurface),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
          IconButton(
            icon:
                Icon(Icons.qr_code_scanner, color: theme.colorScheme.onSurface),
            onPressed: () {
              // TODO: Navigate to barcode scanner
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Products listing (existing functionality)
          Column(
            children: [
              // Search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن منتج...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _products = [];
                                _currentPage = 0;
                                _hasMoreData = true;
                              });
                              _loadProducts();
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
                  onFieldSubmitted: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        _products = [];
                        _currentPage = 0;
                        _hasMoreData = true;
                      });
                      _loadProducts();
                    } else {
                      _searchProducts(value);
                    }
                  },
                ),
              ),

              // Category chips
              SizedBox(
                height: 50.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index]['name'] as String;
                    final isSelected = category == _selectedCategory;

                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor:
                            theme.colorScheme.primary.withOpacity(0.2),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                        onSelected: (_) => _filterByCategory(category),
                      ),
                    );
                  },
                ),
              ),

              // Products grid
              Expanded(
                child: _isLoading && _products.isEmpty
                    ? Center(
                        // child: CircularProgressIndicator(
                        //   color: theme.colorScheme.primary,
                        // ),
                        )
                    : _products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory,
                                  size: 72.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'لا توجد منتجات',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ).animate().fade(duration: 300.ms),
                          )
                        : RefreshIndicator(
                            color: theme.colorScheme.primary,
                            onRefresh: () async {
                              setState(() {
                                _products = [];
                                _currentPage = 0;
                                _hasMoreData = true;
                              });
                              await _loadProducts();
                            },
                            child: GridView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.all(16.w),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16.w,
                                mainAxisSpacing: 16.h,
                              ),
                              itemCount:
                                  _products.length + (_hasMoreData ? 1 : 0),
                              itemBuilder: (context, index) {
                                // Show loading indicator at the end if more data is available
                                if (index == _products.length) {
                                  return Center(
                                      // child: CircularProgressIndicator(
                                      //   color: theme.colorScheme.primary,
                                      // ),
                                      );
                                }

                                final product = _products[index];
                                return _buildProductCard(context, product)
                                    .animate()
                                    .fadeIn(
                                      duration: 300.ms,
                                      delay: Duration(milliseconds: index * 50),
                                    );
                              },
                            ),
                          ),
              ),
            ],
          ),
          // Tab 2: Inventory Count
          _buildInventoryCountTab(theme),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              onPressed: () {
                // Add new product functionality
              },
              child: Icon(Icons.add),
            )
          : FloatingActionButton(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              onPressed: () {
                setState(() {
                  _countingMode = !_countingMode;
                });
              },
              child: Icon(_countingMode ? Icons.check : Icons.edit),
            ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final theme = Theme.of(context);

    // Determine stock status color
    Color stockStatusColor;
    if (product.quantity > 20) {
      stockStatusColor = Colors.green;
    } else if (product.quantity > 5) {
      stockStatusColor = Colors.orange;
    } else {
      stockStatusColor = Colors.red;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image and category badge
            Stack(
              children: [
                Container(
                  height: 120.h,
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
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
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
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        'الكمية: ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        product.quantity.toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: stockStatusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} ${Strings.CURRENCY}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16.sp,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'فلترة المنتجات',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الفئة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _categories.map((category) {
                      final categoryName = category['name'] as String;
                      final isSelected = categoryName == _selectedCategory;
                      return ChoiceChip(
                        label: Text(categoryName),
                        selected: isSelected,
                        selectedColor:
                            theme.colorScheme.primary.withOpacity(0.2),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                        onSelected: (_) {
                          _filterByCategory(categoryName);
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 24.h),
                  Text(
                    'السعر',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Price range slider (just UI, not implemented fully)
                  RangeSlider(
                    values: const RangeValues(0, 5000),
                    min: 0,
                    max: 5000,
                    divisions: 50,
                    labels: RangeLabels(
                        '0 ${Strings.CURRENCY}', '5000 ${Strings.CURRENCY}'),
                    onChanged: (RangeValues values) {},
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.primary.withOpacity(0.2),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0 ${Strings.CURRENCY}'),
                      Text('5000 ${Strings.CURRENCY}'),
                    ],
                  ),

                  SizedBox(height: 24.h),
                  Text(
                    'حالة المخزون',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Stock status checkboxes (just UI, not implemented fully)
                  CheckboxListTile(
                    title: const Text('متوفر بكثرة'),
                    value: true,
                    onChanged: (_) {},
                    activeColor: theme.colorScheme.primary,
                  ),
                  CheckboxListTile(
                    title: const Text('متوفر بقلة'),
                    value: true,
                    onChanged: (_) {},
                    activeColor: theme.colorScheme.primary,
                  ),
                  CheckboxListTile(
                    title: const Text('نفذت الكمية'),
                    value: false,
                    onChanged: (_) {},
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Apply filter button
            Padding(
              padding: EdgeInsets.all(16.w),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text(
                  'تطبيق الفلتر',
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
    );
  }

  // Build the inventory count tab
  Widget _buildInventoryCountTab(ThemeData theme) {
    return Column(
      children: [
        // Search and filter bar
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with total value
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إجمالي قيمة المخزون:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_totalInventoryValue.toStringAsFixed(2)} ${Strings.CURRENCY}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Search field
              TextField(
                decoration: InputDecoration(
                  hintText: 'بحث في المخزون...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _inventorySearchQuery = value;
                    _filterInventoryItems();
                  });
                },
              ),

              SizedBox(height: 16.h),

              // Control buttons
              Row(
                children: [
                  // Unit display toggle
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(_showPrimaryUnits
                          ? Icons.view_list
                          : Icons.view_module),
                      label: Text(_showPrimaryUnits
                          ? 'عرض الوحدة الأساسية'
                          : 'عرض الوحدة الفرعية'),
                      onPressed: () {
                        setState(() {
                          _showPrimaryUnits = !_showPrimaryUnits;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Print button
                  IconButton(
                    onPressed: _generatePdf,
                    icon: Icon(Icons.print),
                    tooltip: 'طباعة تقرير المخزون',
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),

              // Count mode controls
              if (_countingMode)
                Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Row(
                    children: [
                      // Show differences toggle
                      Expanded(
                        child: CheckboxListTile(
                          title: Text('عرض الفروقات فقط'),
                          value: _showDifferencesOnly,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              _showDifferencesOnly = value ?? false;
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      // Save button
                      ElevatedButton(
                        onPressed:
                            _isInventorySaving ? null : _saveInventoryCounts,
                        child: _isInventorySaving
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                // child: CircularProgressIndicator(
                                //   strokeWidth: 2,
                                //   color: Colors.white,
                                // ),
                              )
                            : Text('حفظ الجرد'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Inventory items list
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _filteredInventoryItems.isEmpty
                  ? Center(child: Text('لا توجد عناصر مخزون'))
                  : ListView.builder(
                      itemCount: _filteredInventoryItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredInventoryItems[index];

                        // Skip items with no difference if filter is on
                        if (_showDifferencesOnly &&
                            _countingMode &&
                            !item.hasDifference) {
                          return SizedBox.shrink();
                        }

                        return Card(
                          margin: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 4.h),
                          child: Padding(
                            padding: EdgeInsets.all(16.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Item name and details
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${item.price.toStringAsFixed(2)} ${Strings.CURRENCY}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),

                                // Quantity info
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'الكمية في النظام: ${_showPrimaryUnits ? '${item.primaryUnitCount} ${item.primaryUnit}' : '${item.secondaryUnitCount} ${item.secondaryUnit}'}',
                                      ),
                                    ),
                                    if (_countingMode && item.hasDifference)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          color: item.difference > 0
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                        ),
                                        child: Text(
                                          item.difference > 0
                                              ? '+${item.difference}'
                                              : '${item.difference}',
                                          style: TextStyle(
                                            color: item.difference > 0
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                // Actual count input field (visible only in count mode)
                                if (_countingMode)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            initialValue: item.actualCount > 0
                                                ? item.actualCount.toString()
                                                : '',
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'الجرد الفعلي',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                horizontal: 12.w,
                                                vertical: 8.h,
                                              ),
                                            ),
                                            onChanged: (value) {
                                              final count =
                                                  double.tryParse(value);
                                              if (count != null) {
                                                _updateActualCount(
                                                    item.id, count);
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(_showPrimaryUnits
                                            ? item.primaryUnit
                                            : item.secondaryUnit),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(
                              duration: 300.ms,
                              delay: Duration(milliseconds: index * 50),
                            );
                      },
                    ),
        ),
      ],
    );
  }

  // Generate PDF for printing
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'تقرير جرد المخزون',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                  'تاريخ الطباعة: ${DateTime.now().toString().split(' ')[0]}'),
              pw.SizedBox(height: 10),
              pw.Text(
                  'إجمالي قيمة المخزون: ${_totalInventoryValue.toStringAsFixed(2)} ${Strings.CURRENCY}'),
              pw.SizedBox(height: 20),

              // Table header
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(3),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                  4: pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          '#',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'اسم المنتج',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'الكمية',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'السعر',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'القيمة الإجمالية',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // Table data
                  ..._filteredInventoryItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                            '${index + 1}',
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(item.name),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                            _showPrimaryUnits
                                ? '${item.primaryUnitCount} ${item.primaryUnit}'
                                : '${item.secondaryUnitCount} ${item.secondaryUnit}',
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                            '${item.price.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(
                            '${item.totalValue.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Print the document
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
