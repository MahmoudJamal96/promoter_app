import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/product_model.dart';
import '../services/inventory_service.dart';
import 'product_detail_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Product> _products = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _selectedCategory = 'الكل';
  int _currentPage = 0;
  bool _hasMoreData = true;

  final List<String> _categories = [
    'الكل',
    'أجهزة كهربائية',
    'إلكترونيات',
    'أدوات منزلية',
    'مستلزمات مكتبية',
    'أدوات صحية',
    'غذائية'
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();

    // Set up pagination
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Load initial products or next page
  Future<void> _loadProducts() async {
    if (!_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newProducts =
          await InventoryService.getProducts(page: _currentPage);

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
      _showErrorSnackBar('حدث خطأ أثناء تحميل المنتجات');
    }
  }

  // Search for products
  Future<void> _searchProducts(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final results = await InventoryService.searchProducts(query);

      setState(() {
        _products = results;
        _isSearching = false;
        _hasMoreData = false; // Disable pagination during search
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
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

    _loadProducts();
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
      body: Column(
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
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
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
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
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
                          itemCount: _products.length + (_hasMoreData ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show loading indicator at the end if more data is available
                            if (index == _products.length) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: theme.colorScheme.primary,
                                ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: () {
          // TODO: Add new product
        },
        child: const Icon(Icons.add),
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
            builder: (_) => ProductDetailScreen(productId: product.id),
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
                        '${product.price.toStringAsFixed(2)} ر.س',
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
                      final isSelected = category == _selectedCategory;
                      return ChoiceChip(
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
                        onSelected: (_) {
                          _filterByCategory(category);
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
                    labels: const RangeLabels('0 ر.س', '5000 ر.س'),
                    onChanged: (RangeValues values) {},
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.primary.withOpacity(0.2),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0 ر.س'),
                      Text('5000 ر.س'),
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
}
