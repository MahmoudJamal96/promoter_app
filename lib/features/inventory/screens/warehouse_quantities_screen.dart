import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/core/constants/assets.dart';
import 'package:promoter_app/core/view/widgets/image_loader.dart';
import 'package:promoter_app/features/inventory/widgets/product_quantity_item.dart';

class WarehouseQuantitiesScreen extends StatefulWidget {
  const WarehouseQuantitiesScreen({Key? key}) : super(key: key);

  @override
  State<WarehouseQuantitiesScreen> createState() =>
      _WarehouseQuantitiesScreenState();
}

class _WarehouseQuantitiesScreenState extends State<WarehouseQuantitiesScreen> {
  // Mock data for product quantities
  final List<Map<String, dynamic>> products = [
    {
      'name': 'لابتوب أيسر',
      'code': 'P001',
      'quantities': {
        'المخزن الرئيسي': 10,
        'مخزن الفرع': 5,
        'المخزن الجديد': 0,
        'مخزن المرتجعات': 0,
      },
    },
    {
      'name': 'طابعة HP',
      'code': 'P002',
      'quantities': {
        'المخزن الرئيسي': 8,
        'مخزن الفرع': 3,
        'المخزن الجديد': 2,
        'مخزن المرتجعات': 1,
      },
    },
    {
      'name': 'موبايل سامسونج',
      'code': 'P003',
      'quantities': {
        'المخزن الرئيسي': 15,
        'مخزن الفرع': 10,
        'المخزن الجديد': 5,
        'مخزن المرتجعات': 0,
      },
    },
    {
      'name': 'شاشة LG',
      'code': 'P004',
      'quantities': {
        'المخزن الرئيسي': 7,
        'مخزن الفرع': 3,
        'المخزن الجديد': 0,
        'مخزن المرتجعات': 2,
      },
    },
    {
      'name': 'ماوس لوجيتك',
      'code': 'P005',
      'quantities': {
        'المخزن الرئيسي': 25,
        'مخزن الفرع': 15,
        'المخزن الجديد': 10,
        'مخزن المرتجعات': 5,
      },
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedWarehouse;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter products based on search query
    final filteredProducts = products.where((product) {
      final name = product['name'].toString().toLowerCase();
      final code = product['code'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || code.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'كميات المخازن',
          style: TextStyle(fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث عن منتج...',
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
          if (_selectedWarehouse != null)
            Padding(
              padding: EdgeInsets.only(bottom: 16.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'تصفية حسب: $_selectedWarehouse',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedWarehouse = null;
                            });
                          },
                          child: Icon(
                            Icons.close,
                            color: Theme.of(context).primaryColor,
                            size: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16.r),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      Map<String, int> quantities =
                          Map<String, int>.from(product['quantities']);

                      // Apply warehouse filter if selected
                      if (_selectedWarehouse != null) {
                        quantities = {
                          _selectedWarehouse!:
                              quantities[_selectedWarehouse] ?? 0,
                        };
                      }

                      return ProductQuantityItem(
                        productName: product['name'],
                        productCode: product['code'],
                        warehouseQuantities: quantities,
                        onTap: () => _showProductDetails(product),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportData,
        backgroundColor: Theme.of(context).primaryColor,
        icon: Icon(Icons.summarize),
        label: Text('تصدير التقرير'),
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
            'لا توجد منتجات مطابقة',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'حاول البحث بكلمات أخرى أو تغيير الفلتر',
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                'تصفية حسب المخزن',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                title: Text('الكل'),
                leading: Icon(
                  Icons.all_inbox,
                  color: _selectedWarehouse == null
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                selected: _selectedWarehouse == null,
                selectedTileColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                onTap: () {
                  setState(() {
                    _selectedWarehouse = null;
                  });
                  Navigator.pop(context);
                },
              ),
              ..._getWarehouseNames().map((name) {
                return ListTile(
                  title: Text(name),
                  leading: Icon(
                    Icons.warehouse,
                    color: _selectedWarehouse == name
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  selected: _selectedWarehouse == name,
                  selectedTileColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedWarehouse = name;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  List<String> _getWarehouseNames() {
    // Extract unique warehouse names from the products data
    Set<String> warehouseNames = {};
    for (var product in products) {
      final quantities = product['quantities'] as Map<String, dynamic>;
      warehouseNames.addAll(quantities.keys.cast<String>());
    }
    return warehouseNames.toList();
  }

  void _showProductDetails(Map<String, dynamic> product) {
    final quantities = product['quantities'] as Map<String, dynamic>;
    final totalQuantity =
        quantities.values.fold<int>(0, (prev, qty) => prev + (qty as int));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24.r),
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
              SizedBox(height: 24.h),
              Center(
                child: Text(
                  'تفاصيل المنتج',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'كود: ${product['code']}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'إجمالي الكمية: $totalQuantity',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'توزيع الكميات في المخازن',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: ListView(
                  children: quantities.entries.map((entry) {
                    final warehouse = entry.key;
                    final quantity = entry.value;
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: quantity > 0
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.warehouse,
                                color: quantity > 0
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                size: 20.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  warehouse,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
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
                              color: quantity > 0
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              '$quantity قطعة',
                              style: TextStyle(
                                color: quantity > 0
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _transferProduct(product),
                      icon: Icon(Icons.swap_horiz),
                      label: Text('تحويل'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.check),
                      label: Text('موافق'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _transferProduct(Map<String, dynamic> product) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/warehouse-transfer');
  }

  void _exportData() {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري تصدير التقرير...'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
