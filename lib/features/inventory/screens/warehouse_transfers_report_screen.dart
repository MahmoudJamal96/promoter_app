import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/core/constants/assets.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';
import 'package:promoter_app/core/view/widgets/image_loader.dart';
import 'package:promoter_app/features/inventory/widgets/transfer_item.dart';

class WarehouseTransfersReportScreen extends StatefulWidget {
  const WarehouseTransfersReportScreen({super.key});

  @override
  State<WarehouseTransfersReportScreen> createState() => _WarehouseTransfersReportScreenState();
}

class _WarehouseTransfersReportScreenState extends State<WarehouseTransfersReportScreen> {
  // Mock data for transfers
  final List<Map<String, dynamic>> transfers = [
    {
      'id': 'TR001',
      'itemName': 'لابتوب أيسر',
      'fromWarehouse': 'المخزن الرئيسي',
      'toWarehouse': 'مخزن الفرع',
      'date': '23-04-2025',
      'quantity': 5,
    },
    {
      'id': 'TR002',
      'itemName': 'شاشة سامسونج',
      'fromWarehouse': 'المخزن الرئيسي',
      'toWarehouse': 'مخزن الفرع',
      'date': '22-04-2025',
      'quantity': 3,
    },
    {
      'id': 'TR003',
      'itemName': 'طابعة HP',
      'fromWarehouse': 'مخزن الفرع',
      'toWarehouse': 'المخزن الجديد',
      'date': '21-04-2025',
      'quantity': 2,
    },
    {
      'id': 'TR004',
      'itemName': 'ماوس لوجيتك',
      'fromWarehouse': 'المخزن الرئيسي',
      'toWarehouse': 'مخزن المرتجعات',
      'date': '20-04-2025',
      'quantity': 10,
    },
    {
      'id': 'TR005',
      'itemName': 'هاتف آيفون',
      'fromWarehouse': 'مخزن الفرع',
      'toWarehouse': 'المخزن الرئيسي',
      'date': '19-04-2025',
      'quantity': 1,
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter transfers based on search query and selected filter
    final filteredTransfers = transfers.where((transfer) {
      final itemName = transfer['itemName'].toString().toLowerCase();
      final fromWarehouse = transfer['fromWarehouse'].toString().toLowerCase();
      final toWarehouse = transfer['toWarehouse'].toString().toLowerCase();
      final date = transfer['date'].toString().toLowerCase();
      final id = transfer['id'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      bool matchesSearch = itemName.contains(query) ||
          fromWarehouse.contains(query) ||
          toWarehouse.contains(query) ||
          date.contains(query) ||
          id.contains(query);

      if (_selectedFilter != null) {
        switch (_selectedFilter) {
          case 'المخزن الرئيسي':
            return matchesSearch &&
                (fromWarehouse == 'المخزن الرئيسي'.toLowerCase() ||
                    toWarehouse == 'المخزن الرئيسي'.toLowerCase());
          case 'مخزن الفرع':
            return matchesSearch &&
                (fromWarehouse == 'مخزن الفرع'.toLowerCase() ||
                    toWarehouse == 'مخزن الفرع'.toLowerCase());
          case 'المخزن الجديد':
            return matchesSearch &&
                (fromWarehouse == 'المخزن الجديد'.toLowerCase() ||
                    toWarehouse == 'المخزن الجديد'.toLowerCase());
          case 'مخزن المرتجعات':
            return matchesSearch &&
                (fromWarehouse == 'مخزن المرتجعات'.toLowerCase() ||
                    toWarehouse == 'مخزن المرتجعات'.toLowerCase());
          default:
            return matchesSearch;
        }
      }

      return matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'جدول تحويلات المخازن',
          style: TextStyle(fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF148ccd),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث في التحويلات...',
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
                SizedBox(height: 12.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(null, 'الكل'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('المخزن الرئيسي', 'المخزن الرئيسي'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('مخزن الفرع', 'مخزن الفرع'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('المخزن الجديد', 'المخزن الجديد'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('مخزن المرتجعات', 'مخزن المرتجعات'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredTransfers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16.r),
                    itemCount: filteredTransfers.length,
                    itemBuilder: (context, index) {
                      final transfer = filteredTransfers[index];
                      return TransferItem(
                        itemName: transfer['itemName'],
                        fromWarehouse: transfer['fromWarehouse'],
                        toWarehouse: transfer['toWarehouse'],
                        date: transfer['date'],
                        quantity: transfer['quantity'],
                        onTap: () => _showTransferDetails(transfer),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          SoundManager().playClickSound();
          // Navigate to create new transfer
          Navigator.pushNamed(context, '/warehouse-transfer');
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('تحويل جديد'),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildFilterChip(String? value, String label) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : null;
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Theme.of(context).primaryColor,
      checkmarkColor: Colors.white,
    );
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
            'لا توجد تحويلات مطابقة',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          if (_searchQuery.isNotEmpty || _selectedFilter != null)
            Text(
              'حاول تغيير معايير البحث أو الفلتر',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              'قم بإنشاء تحويل جديد بين المخازن',
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

  void _showTransferDetails(Map<String, dynamic> transfer) {
    SoundManager().playClickSound();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(24.r),
          height: 0.5.sh,
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
                  'تفاصيل التحويل',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _buildDetailRow('رقم التحويل', '${transfer['id']}'),
              _buildDetailRow('المنتج', '${transfer['itemName']}'),
              _buildDetailRow('من مخزن', '${transfer['fromWarehouse']}'),
              _buildDetailRow('إلى مخزن', '${transfer['toWarehouse']}'),
              _buildDetailRow('التاريخ', '${transfer['date']}'),
              _buildDetailRow('الكمية', '${transfer['quantity']}'),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        SoundManager().playClickSound();
                        // Print or share transfer details
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('طباعة تفاصيل التحويل')),
                        );
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('طباعة'),
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
                        SoundManager().playClickSound();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('موافق'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
