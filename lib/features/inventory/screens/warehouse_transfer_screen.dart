import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/core/constants/assets.dart';
import 'package:promoter_app/core/view/widgets/image_loader.dart';
import 'package:promoter_app/features/inventory/widgets/warehouse_card.dart';
import 'package:promoter_app/features/inventory_transfer/services/inventory_transfer_service.dart';
import 'package:promoter_app/features/inventory_transfer/models/inventory_transfer_model.dart';
import 'package:promoter_app/core/di/injection_container.dart';

class WarehouseTransferScreen extends StatefulWidget {
  const WarehouseTransferScreen({Key? key}) : super(key: key);

  @override
  State<WarehouseTransferScreen> createState() =>
      _WarehouseTransferScreenState();
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
      'name': 'مخزن الفرع',
      'code': 'WH002',
      'itemsCount': 85,
    },
    {
      'name': 'المخزن الجديد',
      'code': 'WH003',
      'itemsCount': 42,
    },
    {
      'name': 'مخزن المرتجعات',
      'code': 'WH004',
      'itemsCount': 16,
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          style: TextStyle(fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
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
          // Navigate to add new warehouse
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('إضافة مخزن جديد')),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  // Transfer Request Tab
  Widget _buildTransferRequestTab(
      List<Map<String, dynamic>> filteredWarehouses) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.r),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'بحث عن مخزن...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
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
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: filteredWarehouses.isEmpty
              ? _buildEmptyState('لا توجد مخازن مطابقة للبحث',
                  'حاول البحث بكلمات أخرى أو أضف مخزن جديد')
              : ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: filteredWarehouses.length,
                  itemBuilder: (context, index) {
                    final warehouse = filteredWarehouses[index];
                    return WarehouseCard(
                      name: warehouse['name'],
                      code: warehouse['code'],
                      itemsCount: warehouse['itemsCount'],
                      onTap: () => _showTransferDialog(warehouse,
                          isTransferRequest: true),
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
          child: TextField(
            decoration: InputDecoration(
              hintText: 'بحث عن مخزن...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
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
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
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
        ),
        Expanded(
          child: filteredWarehouses.isEmpty
              ? _buildEmptyState('لا توجد مخازن مطابقة للبحث',
                  'حاول البحث بكلمات أخرى أو أضف مخزن جديد')
              : ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: filteredWarehouses.length,
                  itemBuilder: (context, index) {
                    final warehouse = filteredWarehouses[index];
                    // Only show the main warehouse as a destination for returns
                    if (warehouse['name'] == 'المخزن الرئيسي') {
                      return WarehouseCard(
                        name: warehouse['name'],
                        code: warehouse['code'],
                        itemsCount: warehouse['itemsCount'],
                        onTap: () => _showTransferDialog(warehouse,
                            isTransferRequest: false),
                      );
                    }
                    return WarehouseCard(
                      name: warehouse['name'],
                      code: warehouse['code'],
                      itemsCount: warehouse['itemsCount'],
                      onTap: () => _showTransferDialog(warehouse,
                          isTransferRequest: false),
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

  void _showTransferDialog(Map<String, dynamic> sourceWarehouse,
      {required bool isTransferRequest}) {
    final dialogTitle = isTransferRequest
        ? 'اختر المخزن المستهدف للتحويل'
        : 'اختر المخزن المصدر للمرتجع';

    final fromText = isTransferRequest ? 'من' : 'إلى';

    // For transfer requests: destination can't be the source
    // For return requests: source can't be the main warehouse
    final destinationWarehouses = warehouses.where((warehouse) {
      if (isTransferRequest) {
        return warehouse['code'] != sourceWarehouse['code'];
      } else {
        // For return requests, the destination is always the main warehouse
        return warehouse['name'] == 'المخزن الرئيسي';
      }
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.r),
          height: 0.6.sh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                dialogTitle,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                '$fromText: ${sourceWarehouse['name']}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.builder(
                  itemCount: destinationWarehouses.length,
                  itemBuilder: (context, index) {
                    final warehouse = destinationWarehouses[index];
                    return WarehouseCard(
                      name: warehouse['name'],
                      code: warehouse['code'],
                      itemsCount: warehouse['itemsCount'],
                      onTap: () {
                        Navigator.pop(context);
                        if (isTransferRequest) {
                          _navigateToTransferForm(sourceWarehouse, warehouse,
                              isTransferRequest: true);
                        } else {
                          // For return requests, the source is what user selected and destination is the main warehouse
                          _navigateToTransferForm(sourceWarehouse, warehouse,
                              isTransferRequest: false);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
    Key? key,
    required this.sourceWarehouse,
    required this.destinationWarehouse,
    required this.isTransferRequest,
  }) : super(key: key);

  @override
  State<WarehouseTransferFormScreen> createState() =>
      _WarehouseTransferFormScreenState();
}

class _WarehouseTransferFormScreenState
    extends State<WarehouseTransferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  // Mock product data
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

  @override
  Widget build(BuildContext context) {
    final title =
        widget.isTransferRequest ? 'نموذج طلب التحويل' : 'نموذج طلب المرتجع';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
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
                    Text(
                      'تفاصيل الطلب',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'نوع الطلب',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isTransferRequest
                                  ? Colors.blue.shade50
                                  : Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              widget.isTransferRequest
                                  ? 'طلب تحويل'
                                  : 'طلب مرتجع',
                              style: TextStyle(
                                color: widget.isTransferRequest
                                    ? Colors.blue.shade700
                                    : Colors.amber.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.isTransferRequest ? 'من' : 'الى',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  widget.sourceWarehouse['name'],
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'كود: ${widget.sourceWarehouse['code']}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Icon(
                          widget.isTransferRequest
                              ? Icons.arrow_forward
                              : Icons.arrow_back,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.isTransferRequest ? 'إلى' : 'من',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  widget.destinationWarehouse['name'],
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'كود: ${widget.destinationWarehouse['code']}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
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
                    Text(
                      'اختر المنتج',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<Map<String, String>>(
                      decoration: InputDecoration(
                        hintText: 'اختر المنتج',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                      ),
                      value: _selectedProduct,
                      items: products.map((product) {
                        return DropdownMenuItem<Map<String, String>>(
                          value: product,
                          child:
                              Text('${product['name']} (${product['code']})'),
                        );
                      }).toList(),
                      onChanged: (Map<String, String>? value) {
                        setState(() {
                          _selectedProduct = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'برجاء اختيار المنتج';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'الكمية',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        hintText: 'أدخل الكمية',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'برجاء إدخال الكمية';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'برجاء إدخال كمية صحيحة';
                        }
                        return null;
                      },
                    ),

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
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                        ),
                        validator: (value) {
                          if (!widget.isTransferRequest &&
                              (value == null || value.isEmpty)) {
                            return 'برجاء إدخال سبب الإرجاع';
                          }
                          return null;
                        },
                      ),
                    ],

                    SizedBox(height: 16.h),
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
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.isTransferRequest
                              ? 'إرسال طلب التحويل'
                              : 'إرسال طلب المرتجع',
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
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final inventoryTransferService = sl<InventoryTransferService>();

        // Prepare request data
        final items = [
          {
            'product_id': int.parse(
                _selectedProduct!['code']!.substring(1)), // Convert P001 to 001
            'quantity': int.parse(_quantityController.text),
          }
        ];

        InventoryTransfer result;

        if (widget.isTransferRequest) {
          // Handle transfer request
          result = await inventoryTransferService.requestTransfer(
            items: items,
            notes:
                _notesController.text.isNotEmpty ? _notesController.text : null,
          );

          _showTransferSuccessDialog(
            isTransfer: true,
            transferNumber: result.transferNumber,
            fromWarehouse: widget.sourceWarehouse['name'],
            toWarehouse: widget.destinationWarehouse['name'],
            products: [
              '${_selectedProduct!['name']} (${_quantityController.text})'
            ],
          );
        } else {
          // Handle return request
          result = await inventoryTransferService.requestReturn(
            items: items,
            reason: _reasonController.text,
            notes:
                _notesController.text.isNotEmpty ? _notesController.text : null,
          );

          _showTransferSuccessDialog(
            isTransfer: false,
            transferNumber: result.transferNumber,
            fromWarehouse: widget.sourceWarehouse['name'],
            toWarehouse: widget.destinationWarehouse['name'],
            products: [
              '${_selectedProduct!['name']} (${_quantityController.text})'
            ],
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
                isTransfer
                    ? 'تم إرسال طلب التحويل بنجاح'
                    : 'تم إرسال طلب المرتجع بنجاح',
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
              Text('المنتجات:'),
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
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: Text('إغلاق'),
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
