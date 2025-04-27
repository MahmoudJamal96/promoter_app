import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/core/constants/assets.dart';
import 'package:promoter_app/core/view/widgets/image_loader.dart';
import 'package:promoter_app/features/inventory/widgets/warehouse_card.dart';

class WarehouseTransferScreen extends StatefulWidget {
  const WarehouseTransferScreen({Key? key}) : super(key: key);

  @override
  State<WarehouseTransferScreen> createState() =>
      _WarehouseTransferScreenState();
}

class _WarehouseTransferScreenState extends State<WarehouseTransferScreen> {
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

  @override
  void dispose() {
    _searchController.dispose();
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
          'تحويل للمخازن',
          style: TextStyle(fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
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
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16.r),
                    itemCount: filteredWarehouses.length,
                    itemBuilder: (context, index) {
                      final warehouse = filteredWarehouses[index];
                      return WarehouseCard(
                        name: warehouse['name'],
                        code: warehouse['code'],
                        itemsCount: warehouse['itemsCount'],
                        onTap: () => _showTransferDialog(warehouse),
                      );
                    },
                  ),
          ),
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

  Widget _buildEmptyState() {
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
            'لا توجد مخازن مطابقة للبحث',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'حاول البحث بكلمات أخرى أو أضف مخزن جديد',
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

  void _showTransferDialog(Map<String, dynamic> sourceWarehouse) {
    // Create a filtered list of warehouses excluding the source warehouse
    final destinationWarehouses = warehouses
        .where((warehouse) => warehouse['code'] != sourceWarehouse['code'])
        .toList();

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
                'اختر المخزن المستهدف للتحويل',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'من: ${sourceWarehouse['name']}',
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
                        _navigateToTransferForm(sourceWarehouse, warehouse);
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
    Map<String, dynamic> destinationWarehouse,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WarehouseTransferFormScreen(
          sourceWarehouse: sourceWarehouse,
          destinationWarehouse: destinationWarehouse,
        ),
      ),
    );
  }
}

class WarehouseTransferFormScreen extends StatefulWidget {
  final Map<String, dynamic> sourceWarehouse;
  final Map<String, dynamic> destinationWarehouse;

  const WarehouseTransferFormScreen({
    Key? key,
    required this.sourceWarehouse,
    required this.destinationWarehouse,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'نموذج التحويل',
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
                      'تفاصيل التحويل',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
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
                                  'من',
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
                          Icons.arrow_forward,
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
                                  'إلى',
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
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'تأكيد التحويل',
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

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم التحويل بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to the warehouse transfer screen
      Navigator.pop(context);
    }
  }
}
