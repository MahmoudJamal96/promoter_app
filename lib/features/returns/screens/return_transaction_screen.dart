import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/features/returns/models/return_model.dart';
import 'package:promoter_app/features/returns/services/returns_service.dart';
import 'package:promoter_app/core/di/injection_container.dart';
import 'package:promoter_app/features/products/models/product_model.dart';
import 'package:promoter_app/features/products/services/products_service.dart';
import 'package:promoter_app/features/client/services/client_service.dart';
import 'package:promoter_app/features/sales_invoice/models/sales_invoice_model.dart'
    as invoice_model;
import 'package:promoter_app/features/sales_invoice/services/sales_service.dart'
    as invoice_service;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:promoter_app/core/constants/strings.dart';

class ReturnTransactionScreen extends StatefulWidget {
  // Optional invoice ID parameter allows return creation for a specific invoice
  final String? invoiceId;

  const ReturnTransactionScreen({Key? key, this.invoiceId}) : super(key: key);

  @override
  State<ReturnTransactionScreen> createState() =>
      _ReturnTransactionScreenState();
}

// ReturnItemModel for managing return items with quantity
class ReturnItemModel {
  final Product product;
  final int quantity;

  const ReturnItemModel({
    required this.product,
    required this.quantity,
  });

  ReturnItemModel copyWith({
    Product? product,
    int? quantity,
  }) {
    return ReturnItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class _ReturnTransactionScreenState extends State<ReturnTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _invoiceSearchController =
      TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isLoading = false;
  bool _isSearching = false;
  bool _isSubmitting = false;
  bool _isLoadingClients = false;
  bool _isScanning = false;

  List<Map<String, dynamic>> _clients = [];
  List<Product> _searchResults = [];
  List<ReturnItemModel> _returnItems = [];
  List<String> _recentSearches = []; // Track recent searches
  Map<String, dynamic>? _selectedClient;
  invoice_model.SalesInvoice? _selectedInvoice;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClients();
    _loadRecentSearches();

    // If invoiceId is provided, load that invoice
    if (widget.invoiceId != null) {
      _loadInvoice(widget.invoiceId!);
      _tabController.animateTo(1); // Switch to invoice-based return tab
    }
  }

  // Load recent searches from storage
  Future<void> _loadRecentSearches() async {
    try {
      // In a real app, you would load this from SharedPreferences or similar storage
      _recentSearches = ['لابتوب', 'طابعة', 'شاشة', 'موبايل'];
    } catch (e) {
      // Ignore errors loading search history
      _recentSearches = [];
    }
  }

  // Save search to history
  void _addToSearchHistory(String query) {
    if (query.isEmpty) return;

    setState(() {
      // Remove if exists already to avoid duplicates
      _recentSearches.remove(query);
      // Add to the beginning of the list
      _recentSearches.insert(0, query);
      // Limit to 5 recent searches
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
    });

    // In a real app, you would save this to SharedPreferences or similar storage
  }

  @override
  void dispose() {
    _searchController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    _invoiceSearchController.dispose();
    _scannerController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Load available clients
  Future<void> _loadClients() async {
    setState(() {
      _isLoadingClients = true;
    });

    try {
      final clients = await ClientService().getClients();
      setState(() {
        _clients = clients
            .map((client) => {
                  'id': client.id,
                  'name': client.name,
                  'phone': client.phone,
                })
            .toList();
        _isLoadingClients = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingClients = false;
      });
      _showErrorSnackBar('حدث خطأ أثناء تحميل العملاء');
    }
  }

  // Load invoice by ID
  Future<void> _loadInvoice(String invoiceId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final invoiceService = invoice_service.SalesService();
      final invoice = await invoiceService.getInvoiceById(invoiceId);

      if (invoice != null) {
        setState(() {
          _selectedInvoice = invoice; // Set client based on invoice
          _selectedClient = _clients.firstWhere(
            (client) => client['id'] == invoice.clientId,
            orElse: () => {
              'id': invoice.clientId,
              'name': invoice.clientName,
              'phone': 'N/A',
            },
          );
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar('لم يتم العثور على الفاتورة');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('حدث خطأ أثناء تحميل الفاتورة');
    }
  }

  // Search for products
  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Use the ProductsService to search for products
      final productsService = sl<ProductsService>();
      final apiResults = await productsService.scanProduct(name: query);
      setState(() {
        _searchResults = apiResults
            .map((product) => Product(
                  id: product.id,
                  name: product.name,
                  sku: product.sku,
                  quantity: product.quantity,
                  price: product.price,
                  barcode: product.barcode,
                  categoryId: product.categoryId,
                  categoryName: product.categoryName,
                  createdAt: product.createdAt,
                  updatedAt: product.updatedAt,
                ))
            .toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showErrorSnackBar('حدث خطأ أثناء البحث عن المنتجات');
    }
  }

  // Scan product barcode
  Future<void> _scanProductBarcode(String barcode) async {
    setState(() {
      _isSearching = true;
    });

    try {
      // Use the ProductsService to search for products by barcode
      final productsService = sl<ProductsService>();
      final apiResults = await productsService.scanProduct(barcode: barcode);
      if (apiResults.isNotEmpty) {
        // Create a product using all fields directly from the API result
        final firstProduct = apiResults.first;
        final product = Product(
          id: firstProduct.id,
          name: firstProduct.name,
          sku: firstProduct.sku,
          barcode: firstProduct.barcode,
          price: firstProduct.price,
          quantity: firstProduct.quantity,
          categoryId: firstProduct.categoryId,
          categoryName: firstProduct.categoryName,
          createdAt: firstProduct.createdAt,
          updatedAt: firstProduct.updatedAt,
        );

        _addToReturnItems(product);
        _showSuccessSnackBar('تم إضافة ${product.name} إلى المرتجع');
      } else {
        _showErrorSnackBar('لم يتم العثور على المنتج');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء البحث عن المنتج');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // Toggle barcode scanner
  void _toggleScanner() {
    setState(() {
      _isScanning = !_isScanning;
    });
    if (!_isScanning) {
      _scannerController.stop();
    } else {
      _scannerController.start();
    }
  }

  // Add product to return items
  void _addToReturnItems(Product product) {
    // Check if product already exists in return items
    final existingIndex =
        _returnItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      setState(() {
        _returnItems[existingIndex] = _returnItems[existingIndex].copyWith(
          quantity: _returnItems[existingIndex].quantity + 1,
        );
      });
    } else {
      setState(() {
        _returnItems.add(ReturnItemModel(
          product: product,
          quantity: 1,
        ));
      });
    }

    // Clear search
    _searchController.clear();
    setState(() {
      _searchResults = [];
    });

    _showSuccessSnackBar('تم إضافة ${product.name} إلى المرتجع');
  }

  // Remove product from return items
  void _removeFromReturnItems(int index) {
    final removedItem = _returnItems[index];
    setState(() {
      _returnItems.removeAt(index);
    });

    _showInfoSnackBar('تم حذف ${removedItem.product.name} من المرتجع');
  }

  // Update product quantity in return items
  void _updateReturnItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromReturnItems(index);
      return;
    }

    setState(() {
      _returnItems[index] = _returnItems[index].copyWith(
        quantity: newQuantity,
      );
    });
  }

  // Validate return form data
  bool _validateReturnForm({bool showErrors = true}) {
    List<String> errors = [];

    if (_returnItems.isEmpty) {
      errors.add('أضف منتجات إلى المرتجع أولاً');
    }

    if (_selectedClient == null) {
      errors.add('اختر عميل');
    }

    if (_reasonController.text.isEmpty) {
      errors.add('أدخل سبب الإرجاع');
    }

    // Show errors if requested
    if (showErrors && errors.isNotEmpty) {
      _showErrorSnackBar(errors.first);
      return false;
    }

    return errors.isEmpty;
  }

  // Submit standalone return
  Future<void> _submitStandaloneReturn() async {
    if (!_validateReturnForm()) {
      return;
    }

    // Format return items for API
    final items = _returnItems
        .map((item) => {
              'product_id': int.parse(item.product.id.toString()),
              'quantity': item.quantity,
            })
        .toList();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final returnsService = sl<ReturnsService>();
      final result = await returnsService.createStandaloneReturn(
        clientId: _selectedClient!['id'],
        items: items,
        reason: _reasonController.text,
        notes: _notesController.text,
      );

      setState(() {
        _isSubmitting = false;
      });

      // Show success message
      _showReturnCreatedDialog(result);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorSnackBar('حدث خطأ أثناء إنشاء المرتجع');
    }
  }

  // Submit invoice-based return
  Future<void> _submitInvoiceReturn() async {
    // Add invoice-specific validations
    if (_selectedInvoice == null) {
      _showErrorSnackBar('اختر فاتورة للإرجاع');
      return;
    }

    // Use shared validation
    if (!_validateReturnForm()) {
      return;
    }

    // Format return items for API
    final items = _returnItems
        .map((item) => {
              'product_id': int.parse(item.product.id.toString()),
              'quantity': item.quantity,
            })
        .toList();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final returnsService = sl<ReturnsService>();
      final result = await returnsService.createReturnFromInvoice(
        invoiceId: int.parse(_selectedInvoice!.id.toString()),
        items: items,
        reason: _reasonController.text,
        notes: _notesController.text,
      );

      setState(() {
        _isSubmitting = false;
      });

      // Show success message
      _showReturnCreatedDialog(result);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorSnackBar('حدث خطأ أثناء إنشاء المرتجع');
    }
  }

  // Show return created dialog
  void _showReturnCreatedDialog(ReturnOrder returnOrder) {
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
            const Text('تم إنشاء المرتجع بنجاح'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('رقم المرتجع: ${returnOrder.returnNumber}'),
            SizedBox(height: 8.h),
            Text(
                'إجمالي المرتجع: ${returnOrder.total.toStringAsFixed(2)} ${Strings.CURRENCY}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('مرتجع جديد'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to return details screen
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

  // Reset form after creating return
  void _resetForm() {
    setState(() {
      _returnItems = [];
      _selectedClient = null;
      _selectedInvoice = null;
      _reasonController.clear();
      _notesController.clear();
      _invoiceSearchController.clear();
      if (_isScanning) {
        _isScanning = false;
        _scannerController.stop();
      }
    });
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

  // Build quantity button
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate subtotal
    final subtotal = _returnItems.fold(
      0.0,
      (sum, item) => sum + (item.quantity * item.product.price),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل مرتجع'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'مرتجع منفصل'),
            Tab(text: 'مرتجع على فاتورة'),
          ],
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.grey,
        ),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.qr_code_scanner : Icons.qr_code),
            onPressed: _toggleScanner,
            tooltip: _isScanning ? 'إيقاف المسح' : 'مسح الباركود',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barcode scanner
          if (_isScanning)
            Container(
              height: 200.h,
              width: double.infinity,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: (capture) {
                      final barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty &&
                          barcodes.first.rawValue != null) {
                        _scanProductBarcode(barcodes.first.rawValue!);
                        // Temporarily stop scanning after successful scan
                        _scannerController.stop();
                        Future.delayed(Duration(seconds: 2), () {
                          if (_isScanning) {
                            _scannerController.start();
                          }
                        });
                      }
                    },
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: EdgeInsets.only(top: 10.h),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'وجه الكاميرا نحو باركود المنتج',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: _toggleScanner,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 300.ms),

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
          ), // Search results
          if (_isSearching)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              height: 80.h,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_searchResults.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              constraints: BoxConstraints(maxHeight: 180.h),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _searchResults.length,
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
                        'سعر: ${product.price.toStringAsFixed(2)} ${Strings.CURRENCY} | المتاح: ${product.quantity}',
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
                        onPressed: () => _addToReturnItems(product),
                      ),
                    );
                  },
                ),
              ),
            ).animate().fade(duration: 200.ms),
          // else if (_searchController.text.isEmpty && _recentSearches.isNotEmpty)
          //   Container(
          //     padding: EdgeInsets.symmetric(horizontal: 16.w),
          //     constraints: BoxConstraints(maxHeight: 180.h),
          //     child: Card(
          //       elevation: 2,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12.r),
          //       ),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Padding(
          //             padding: EdgeInsets.all(12.w),
          //             child: Text(
          //               'عمليات البحث السابقة',
          //               style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 14.sp,
          //                 color: Colors.grey.shade700,
          //               ),
          //             ),
          //           ),
          //           Flexible(
          //             child: ListView.builder(
          //               shrinkWrap: true,
          //               padding: EdgeInsets.zero,
          //               itemCount: _recentSearches.length,
          //               itemBuilder: (context, index) {
          //                 final query = _recentSearches[index];
          //                 return ListTile(
          //                   leading: Icon(Icons.history, color: Colors.grey),
          //                   title: Text(
          //                     query,
          //                     style: TextStyle(fontSize: 14.sp),
          //                   ),
          //                   onTap: () {
          //                     _searchController.text = query;
          //                     _searchProducts(query);
          //                   },
          //                   dense: true,
          //                 );
          //               },
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ).animate().fade(duration: 200.ms),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Standalone return tab
                _buildStandaloneReturnTab(theme, subtotal),

                // Invoice-based return tab
                _buildInvoiceReturnTab(theme, subtotal),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build standalone return tab
  Widget _buildStandaloneReturnTab(ThemeData theme, double subtotal) {
    return _returnItems.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_return_outlined,
                  size: 72.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16.h),
                Text(
                  'لم يتم إضافة أي منتجات للمرتجع',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'ابحث عن منتج وأضفه إلى المرتجع',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Return items
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
                          'المنتجات المرتجعة',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _returnItems.length,
                          itemBuilder: (context, index) {
                            final item = _returnItems[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      item.product.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Row(
                                    children: [
                                      _buildQuantityButton(
                                        icon: Icons.remove,
                                        onTap: () => _updateReturnItemQuantity(
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
                                        onTap: () => _updateReturnItemQuantity(
                                            index, item.quantity + 1),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 16.w),
                                  Text(
                                    '${(item.quantity * item.product.price).toStringAsFixed(2)} جنيه',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _removeFromReturnItems(index),
                                    iconSize: 20.sp,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Client info
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
                          'العميل',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        _isLoadingClients
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButtonFormField<Map<String, dynamic>>(
                                decoration: InputDecoration(
                                  labelText: 'اختر العميل',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                ),
                                value: _selectedClient,
                                items: _clients.map((client) {
                                  return DropdownMenuItem<Map<String, dynamic>>(
                                    value: client,
                                    child: Text(
                                        '${client['name']} - ${client['phone']}'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedClient = value;
                                  });
                                },
                              ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Reason and notes
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
                          'سبب الإرجاع وملاحظات',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextFormField(
                          controller: _reasonController,
                          decoration: InputDecoration(
                            labelText: 'سبب الإرجاع',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            errorText:
                                _reasonController.text.isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        TextFormField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            labelText: 'ملاحظات إضافية',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Summary
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الإجمالي:',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${subtotal.toStringAsFixed(2)} جنيه',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed:
                                _isSubmitting ? null : _submitStandaloneReturn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                            child: _isSubmitting
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'تسجيل المرتجع',
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
              ],
            ),
          );
  }

  // Build invoice-based return tab
  Widget _buildInvoiceReturnTab(ThemeData theme, double subtotal) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _selectedInvoice == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 72.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'لم يتم تحديد فاتورة',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'أدخل رقم الفاتورة لإنشاء مرتجع عليها',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _invoiceSearchController,
                              decoration: InputDecoration(
                                labelText: 'رقم الفاتورة',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          ElevatedButton(
                            onPressed: () {
                              final invoiceId = _invoiceSearchController.text;
                              if (invoiceId.isNotEmpty) {
                                _loadInvoice(invoiceId);
                              } else {
                                _showErrorSnackBar('أدخل رقم الفاتورة');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.h, horizontal: 16.w),
                            ),
                            child: Text('بحث'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Invoice info
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
                              'معلومات الفاتورة',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('رقم الفاتورة:'),
                                Text(_selectedInvoice!.id.toString()),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('تاريخ الفاتورة:'),
                                Text(_selectedInvoice!.createdAt
                                    .toString()
                                    .split(' ')[0]),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('العميل:'),
                                Text(_selectedInvoice!.clientName),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('إجمالي الفاتورة:'),
                                Text(
                                    '${_selectedInvoice!.total.toStringAsFixed(2)} جنيه'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Invoice items
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
                              'منتجات الفاتورة',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _selectedInvoice!.items.length,
                              itemBuilder: (context, index) {
                                final item = _selectedInvoice!.items[index];
                                final isSelected = _returnItems.any(
                                  (returnItem) =>
                                      returnItem.product.id.toString() ==
                                      item.productId.toString(),
                                );
                                return ListTile(
                                  title: Text(item.productName),
                                  subtitle: Text(
                                    'الكمية: ${item.quantity} | السعر: ${item.price.toStringAsFixed(2)} جنيه',
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle,
                                          color: Colors.green)
                                      : IconButton(
                                          icon: Icon(Icons.add_circle),
                                          onPressed: () {
                                            final product = Product(
                                              id: item.productId,
                                              name: item.productName,
                                              sku: 'SKU-' +
                                                  item.productId
                                                      .toString(), // Placeholder SKU
                                              barcode: 'BC-' +
                                                  item.productId
                                                      .toString(), // Placeholder barcode
                                              quantity: item.quantity,
                                              price: item.price,
                                              categoryId:
                                                  1, // Default category ID
                                              categoryName:
                                                  'Default', // Default category name
                                              createdAt:
                                                  DateTime.now().toString(),
                                              updatedAt:
                                                  DateTime.now().toString(),
                                            );
                                            _addToReturnItems(product);
                                          },
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Return items
                    if (_returnItems.isNotEmpty) ...[
                      SizedBox(height: 16.h),
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
                                'المنتجات المرتجعة',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _returnItems.length,
                                itemBuilder: (context, index) {
                                  final item = _returnItems[index];
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.h),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            item.product.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14.sp,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Row(
                                          children: [
                                            _buildQuantityButton(
                                              icon: Icons.remove,
                                              onTap: () =>
                                                  _updateReturnItemQuantity(
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
                                                  _updateReturnItemQuantity(
                                                      index, item.quantity + 1),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 16.w),
                                        Text(
                                          '${(item.quantity * item.product.price).toStringAsFixed(2)} جنيه',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _removeFromReturnItems(index),
                                          iconSize: 20.sp,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 16.h),

                    // Reason and notes
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
                              'سبب الإرجاع وملاحظات',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextFormField(
                              controller: _reasonController,
                              decoration: InputDecoration(
                                labelText: 'سبب الإرجاع',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                errorText: _reasonController.text.isEmpty
                                    ? 'مطلوب'
                                    : null,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            TextFormField(
                              controller: _notesController,
                              decoration: InputDecoration(
                                labelText: 'ملاحظات إضافية',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Summary
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الإجمالي:',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${subtotal.toStringAsFixed(2)} جنيه',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed:
                                    _isSubmitting ? null : _submitInvoiceReturn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                ),
                                child: _isSubmitting
                                    ? SizedBox(
                                        width: 20.w,
                                        height: 20.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'تسجيل المرتجع',
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
                  ],
                ),
              );
  }
}
