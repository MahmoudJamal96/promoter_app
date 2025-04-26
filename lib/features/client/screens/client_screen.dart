import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  // Sample client data - in a real app, this would come from a service or API
  final List<Map<String, dynamic>> _clients = [
    {
      'id': 1,
      'name': 'أحمد محمود',
      'phone': '01012345678',
      'address': 'القاهرة، مصر',
      'balance': 500.0,
      'lastPurchase': '2025-04-20',
    },
    {
      'id': 2,
      'name': 'محمد عبدالله',
      'phone': '01098765432',
      'address': 'الإسكندرية، مصر',
      'balance': 1200.0,
      'lastPurchase': '2025-04-15',
    },
    {
      'id': 3,
      'name': 'سارة أحمد',
      'phone': '01112233445',
      'address': 'طنطا، مصر',
      'balance': 0.0,
      'lastPurchase': '2025-04-22',
    },
    {
      'id': 4,
      'name': 'حسين علي',
      'phone': '01023456789',
      'address': 'المنصورة، مصر',
      'balance': 750.0,
      'lastPurchase': '2025-04-05',
    },
    {
      'id': 5,
      'name': 'فاطمة محمد',
      'phone': '01034567890',
      'address': 'أسيوط، مصر',
      'balance': 300.0,
      'lastPurchase': '2025-04-18',
    },
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('العملاء', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن عميل...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ).animate().fade(duration: 500.ms),

            SizedBox(height: 16.h),

            // Summary Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                      'إجمالي العملاء', _clients.length.toString()),
                  _buildSummaryItem(
                      'إجمالي المديونية', '${_calculateTotalBalance()} ج.م'),
                ],
              ),
            ).animate().fade(duration: 500.ms),

            SizedBox(height: 16.h),

            // Client list
            Expanded(
              child: _filteredClients.isEmpty
                  ? Center(child: Text('لا يوجد عملاء مطابقين للبحث'))
                  : ListView.builder(
                      itemCount: _filteredClients.length,
                      itemBuilder: (context, index) {
                        final client = _filteredClients[index];
                        return ClientCard(
                          client: client,
                          onTap: () => _showClientDetails(client),
                        )
                            .animate(delay: Duration(milliseconds: index * 100))
                            .fade(duration: 300.ms);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClientDialog,
        child: Icon(Icons.add),
        tooltip: 'إضافة عميل',
      ).animate().fade(duration: 500.ms).scale(begin: 0.5, end: 1.0),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> get _filteredClients {
    if (_searchQuery.isEmpty) {
      return _clients;
    }
    return _clients.where((client) {
      final name = client['name'].toString().toLowerCase();
      final phone = client['phone'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || phone.contains(query);
    }).toList();
  }

  double _calculateTotalBalance() {
    return _clients.fold(
        0, (total, client) => total + (client['balance'] as double));
  }

  void _showClientDetails(Map<String, dynamic> client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  client['name'],
                  style:
                      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              _buildDetailItem(Icons.phone, 'رقم الهاتف:', client['phone']),
              _buildDetailItem(
                  Icons.location_on, 'العنوان:', client['address']),
              _buildDetailItem(Icons.account_balance_wallet, 'الرصيد:',
                  '${client['balance']} ج.م'),
              _buildDetailItem(
                  Icons.calendar_today, 'آخر مشتريات:', client['lastPurchase']),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Edit client logic
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.edit),
                    label: Text('تعديل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add payment logic
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.payment),
                    label: Text('إضافة دفعة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
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

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          SizedBox(width: 10),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 5),
          Text(value),
        ],
      ),
    );
  }

  void _showAddClientDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة عميل جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم العميل',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'العنوان',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  // Add new client logic
                  setState(() {
                    _clients.add({
                      'id': _clients.length + 1,
                      'name': nameController.text,
                      'phone': phoneController.text,
                      'address': addressController.text,
                      'balance': 0.0,
                      'lastPurchase':
                          '${DateTime.now().toIso8601String().split('T')[0]}',
                    });
                  });
                }
                Navigator.pop(context);
              },
              child: Text('إضافة'),
            ),
          ],
        );
      },
    );
  }
}

class ClientCard extends StatelessWidget {
  final Map<String, dynamic> client;
  final VoidCallback onTap;

  const ClientCard({required this.client, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final balance = client['balance'] as double;
    final isPositiveBalance = balance > 0;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.2),
                child: Text(
                  client['name'].toString().substring(0, 1),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client['name'].toString(),
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.h),
                    Text(client['phone'].toString()),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${client['balance']} ج.م',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isPositiveBalance ? Colors.red : Colors.green,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    isPositiveBalance ? 'مديونية' : 'متوازن',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isPositiveBalance ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
