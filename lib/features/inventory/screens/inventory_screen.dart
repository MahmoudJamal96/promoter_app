import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';
import 'package:promoter_app/features/inventory/models/print_products.dart';

import '../../../core/constants/strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../features/products/services/products_service.dart';
import '../models/product_model.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Map<String, dynamic>> _categories = [];

  bool _isLoading = true;
  bool _hasMoreData = true;

  String _selectedCategory = 'الكل';
  String _selectedType = '';

  int _currentPage = 0;
  late final ProductsService _productsService;

  @override
  void initState() {
    super.initState();
    _productsService = sl<ProductsService>();
    _loadCategories();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  double get _totalInventoryValue => _products.fold(0, (sum, p) => sum + (p.price * p.quantity));

  Future<void> _loadCategories() async {
    try {
      final categories = await _productsService.getCategories();
      setState(() {
        _categories = categories;
        if (_categories.isNotEmpty) {
          _filterByCategory(_categories.first['name'] as String);
        }
      });
    } catch (_) {
      _showErrorSnackbar('فشل تحميل التصنيفات');
    }
  }

  Future<void> _loadProductsByCategory(int categoryId) async {
    if (!_hasMoreData) return;
    setState(() => _isLoading = true);

    try {
      final apiResponse = await _productsService.getProducts(
        page: _currentPage + 1,
        categoryId: categoryId,
      );

      final newProducts = apiResponse
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
                units: p.units,
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
    } catch (_) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('حدث خطأ أثناء تحميل المنتجات');
    }
  }

  Future<void> _searchProducts(String query) async {
    setState(() => _isLoading = true);

    try {
      final apiResults = await _productsService.getProducts(
        search: query,
        categoryId: _categories.firstWhere(
          (cat) => cat['name'] == _selectedCategory,
          orElse: () => {'id': 0},
        )['id'] as int,
      );

      setState(() {
        _products = apiResults
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
                  units: p.units,
                ))
            .toList();
        _isLoading = false;
        _hasMoreData = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('حدث خطأ أثناء البحث');
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _products = [];
      _currentPage = 0;
      _selectedType = '';
      _hasMoreData = true;
    });

    if (category != 'الكل') {
      final categoryId = _categories.firstWhere(
        (cat) => cat['name'] == category,
        orElse: () => {'id': 0},
      )['id'] as int;
      _loadProductsByCategory(categoryId);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMoreData) {
      final categoryId = _categories.firstWhere(
        (cat) => cat['name'] == _selectedCategory,
        orElse: () => {'id': 0},
      )['id'] as int;
      _loadProductsByCategory(categoryId);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _scanBarcode() async {
    try {
      await showDialog<String>(
        context: context,
        builder: (ctx) => Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('مسح الباركود',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 16.h),
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
                        final code = capture.barcodes.first.rawValue;
                        if (code != null) {
                          _searchController.text = code;
                          _searchProducts(code);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    SoundManager().playClickSound();
                    Navigator.pop(context);
                  },
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF148ccd),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('المخزون',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        actions: [
          IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
              onPressed: () {
                SoundManager().playClickSound();
                _scanBarcode();
              }),
          IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                SoundManager().playClickSound();
                _showFilterBottomSheet(context);
              }),
          IconButton(
              icon: const Icon(Icons.print, color: Colors.white),
              onPressed: () {
                SoundManager().playClickSound();
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ProductToPrintWidget(products: _products)));
              }),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          _buildCategoryChips(theme),
          _buildProductList(theme),
        ],
      ),
      bottomNavigationBar: _buildBottomSummary(),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
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
                    SoundManager().playClickSound();
                    setState(() {
                      _searchController.clear();
                      _products = [];
                      _currentPage = 0;
                      _hasMoreData = true;
                    });
                    _filterByCategory(_selectedCategory);
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        ),
        onFieldSubmitted: (value) {
          if (value.isEmpty) {
            setState(() {
              _products = [];
              _currentPage = 0;
              _hasMoreData = true;
            });
            _filterByCategory(_selectedCategory);
          } else {
            _searchProducts(value);
          }
        },
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme) {
    return SizedBox(
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
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(
                    color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300),
              ),
              onSelected: (_) => _filterByCategory(category),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList(ThemeData theme) {
    if (_isLoading && _products.isEmpty) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }
    if (_products.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory, size: 72.sp, color: Colors.grey.shade400),
              SizedBox(height: 16.h),
              Text('لا توجد منتجات',
                  style: TextStyle(fontSize: 18.sp, color: Colors.grey.shade600)),
            ],
          ).animate().fade(duration: 300.ms),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () async {
          setState(() {
            _products = [];
            _currentPage = 0;
            _hasMoreData = true;
          });
          _filterByCategory(_selectedCategory);
        },
        child: GridView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h),
          itemCount: _selectedType.isNotEmpty ? _filteredProducts.length : _products.length,
          itemBuilder: (context, index) {
            final product = _selectedType.isNotEmpty ? _filteredProducts[index] : _products[index];
            return _buildProductCard(context, product)
                .animate()
                .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 50));
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final stockStatusColor = product.quantity > 20
        ? Colors.green
        : product.quantity > 5
            ? Colors.orange
            : Colors.red;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(children: [
            Container(
              height: 100.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/logo_banner.png',
                  image: product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  imageErrorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/logo_banner.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  product.units.isEmpty ? "علبة" : product.units.first.name,
                  style:
                      TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ]),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.h),
                Row(children: [
                  Text('الكمية: ', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                  Text(product.quantity.toString(),
                      style: TextStyle(
                          fontSize: 12.sp, color: stockStatusColor, fontWeight: FontWeight.bold)),
                ]),
                SizedBox(height: 4.h),
                Text('${product.price.toStringAsFixed(2)} ${Strings.CURRENCY}',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      height: 70.h,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow("عدد المنتجات:", "(${_products.length})"),
          _buildSummaryRow(
              "المبلغ الإجمالي:", "${_totalInventoryValue.toStringAsFixed(2)} ${Strings.CURRENCY}"),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            // Header
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Section
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
                          selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            side: BorderSide(
                              color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
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

                    // Type Section
                    Text(
                      'النوع',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: ["كرتونة", "علبة"].map((type) {
                        final isSelected = type == _selectedType;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            side: BorderSide(
                              color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
                            ),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedType = isSelected ? '' : type;
                              _filteredProducts = _products
                                  .where(
                                      (product) => product.units.any((unit) => unit.name == type))
                                  .toList();
                              Navigator.pop(context);
                            });
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // Apply button
            Padding(
              padding: EdgeInsets.all(16.w),
              child: ElevatedButton(
                onPressed: () {
                  SoundManager().playClickSound();

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
