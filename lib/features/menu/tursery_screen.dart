import 'package:promoter_app/core/utils/sound_manager.dart';
import 'package:promoter_app/qara_ksa.dart';

class TreasuryScreen extends StatefulWidget {
  const TreasuryScreen({super.key});

  @override
  _TreasuryScreenState createState() => _TreasuryScreenState();
}

class _TreasuryScreenState extends State<TreasuryScreen> {
  final Color primaryColor = const Color(0xFF148ccd);
  String selectedBranch = 'all';
  bool showTransferDialog = false;
  String transferFrom = '';
  String transferTo = '';
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  final List<Map<String, dynamic>> branches = [
    {'id': 'main', 'name': 'الفرع الرئيسي', 'code': 'MB001'},
    {'id': 'north', 'name': 'الفرع الشمالي', 'code': 'NB002'},
    {'id': 'south', 'name': 'الفرع الجنوبي', 'code': 'SB003'},
    {'id': 'east', 'name': 'الفرع الشرقي', 'code': 'EB004'},
    {'id': 'west', 'name': 'الفرع الغربي', 'code': 'WB005'},
  ];

  final List<Map<String, dynamic>> treasuryData = [
    {
      'branch': 'الفرع الرئيسي',
      'code': 'MB001',
      'openingBalance': 125000.0,
      'cashInflow': 45000.0,
      'cashOutflow': 32000.0,
      'closingBalance': 138000.0,
      'status': 'healthy'
    },
    {
      'branch': 'الفرع الشمالي',
      'code': 'NB002',
      'openingBalance': 85000.0,
      'cashInflow': 28000.0,
      'cashOutflow': 35000.0,
      'closingBalance': 78000.0,
      'status': 'warning'
    },
    {
      'branch': 'الفرع الجنوبي',
      'code': 'SB003',
      'openingBalance': 95000.0,
      'cashInflow': 38000.0,
      'cashOutflow': 25000.0,
      'closingBalance': 108000.0,
      'status': 'healthy'
    },
    {
      'branch': 'الفرع الشرقي',
      'code': 'EB004',
      'openingBalance': 67000.0,
      'cashInflow': 22000.0,
      'cashOutflow': 29000.0,
      'closingBalance': 60000.0,
      'status': 'critical'
    },
    {
      'branch': 'الفرع الغربي',
      'code': 'WB005',
      'openingBalance': 110000.0,
      'cashInflow': 52000.0,
      'cashOutflow': 41000.0,
      'closingBalance': 121000.0,
      'status': 'healthy'
    },
  ];

  // Sample transaction data for the table
  final List<Map<String, dynamic>> transactionData = [
    {
      'date': '2024-01-15',
      'branch': 'الفرع الرئيسي',
      'income': 15000.0,
      'expense': 0.0,
      'details': 'إيداع من العميل أحمد محمد',
      'type': 'income'
    },
    {
      'date': '2024-01-15',
      'branch': 'الفرع الرئيسي',
      'income': 0.0,
      'expense': 5000.0,
      'details': 'سحب نقدي - إيجار المكتب',
      'type': 'expense'
    },
    {
      'date': '2024-01-14',
      'branch': 'الفرع الشمالي',
      'income': 12000.0,
      'expense': 0.0,
      'details': 'إيداع من العميل فاطمة علي',
      'type': 'income'
    },
    {
      'date': '2024-01-14',
      'branch': 'الفرع الشمالي',
      'income': 0.0,
      'expense': 8000.0,
      'details': 'دفع مرتبات الموظفين',
      'type': 'expense'
    },
    {
      'date': '2024-01-13',
      'branch': 'الفرع الجنوبي',
      'income': 18000.0,
      'expense': 0.0,
      'details': 'إيداع من العميل خالد سالم',
      'type': 'income'
    },
    {
      'date': '2024-01-13',
      'branch': 'الفرع الجنوبي',
      'income': 0.0,
      'expense': 3000.0,
      'details': 'شراء مستلزمات مكتبية',
      'type': 'expense'
    },
    {
      'date': '2024-01-12',
      'branch': 'الفرع الشرقي',
      'income': 10000.0,
      'expense': 0.0,
      'details': 'إيداع من العميل مريم أحمد',
      'type': 'income'
    },
    {
      'date': '2024-01-12',
      'branch': 'الفرع الشرقي',
      'income': 0.0,
      'expense': 12000.0,
      'details': 'دفع فواتير الكهرباء والماء',
      'type': 'expense'
    },
    {
      'date': '2024-01-11',
      'branch': 'الفرع الغربي',
      'income': 22000.0,
      'expense': 0.0,
      'details': 'إيداع من العميل عبدالله محمد',
      'type': 'income'
    },
    {
      'date': '2024-01-11',
      'branch': 'الفرع الغربي',
      'income': 0.0,
      'expense': 7000.0,
      'details': 'صيانة أجهزة الكمبيوتر',
      'type': 'expense'
    },
  ];
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    SoundManager().playClickSound();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF148ccd),
        elevation: 0,
        title: const Text(
          'تقرير الخزينة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () {
              SoundManager().playClickSound();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Summary
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Date
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Total Opening Balance
                      _buildSummaryCard(
                          'إجمالي الخزينة', _getTotalBalance(), Icons.account_balance),
                      // Total Cash Inflow
                      _buildSummaryCard(
                          'إجمالي الوارد',
                          transactionData.fold(0, (sum, item) => sum + item['income']),
                          Icons.arrow_upward),
                      // Total Cash Outflow
                      _buildSummaryCard(
                          'إجمالي المنصرف',
                          transactionData.fold(0, (sum, item) => sum + item['expense']),
                          Icons.arrow_downward),
                    ],
                  ),
                  // // Total Summary
                  // _buildSummaryCard(
                  //     'إجمالي الرصيد', _getTotalBalance(), Icons.account_balance_wallet),
                  // _buildSummaryCard(
                  //     'إجمالي الرصيد', _getTotalBalance(), Icons.account_balance_wallet),
                  // _buildSummaryCard(
                  //     'إجمالي الرصيد', _getTotalBalance(), Icons.account_balance_wallet),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              SoundManager().playClickSound();
              _showTransferDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_horiz, size: 18),
                SizedBox(width: 4),
                Text('تحويل'),
              ],
            ),
          ),
          // Branch Filter
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20),
          //   child: Row(
          //     children: [
          // Expanded(
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 12),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(12),
          //       border: Border.all(color: Colors.grey[300]!),
          //     ),
          //     child: DropdownButton<String>(
          //       value: selectedBranch,
          //       isExpanded: true,
          //       underline: const SizedBox(),
          //       hint: const Text('اختر الفرع'),
          //       items: [
          //         const DropdownMenuItem(value: 'all', child: Text('جميع الفروع')),
          //         ...branches.map((branch) => DropdownMenuItem(
          //               value: branch['id'],
          //               child: Text(branch['name']),
          //             )),
          //       ],
          //       onChanged: (value) {
          //         setState(() {
          //           selectedBranch = value!;
          //         });
          //       },
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 12),

          //     ],
          //   ),
          // ),

          const SizedBox(height: 20),

          // Transactions Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'التاريخ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'الإيراد',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'المصروف',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'التفاصيل',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Table Body
                  Expanded(
                    child: ListView.builder(
                      itemCount: _getFilteredTransactions().length,
                      itemBuilder: (context, index) {
                        final transaction = _getFilteredTransactions()[index];
                        return _buildTransactionRow(transaction, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(Map<String, dynamic> transaction, int index) {
    final isEven = index % 2 == 0;
    final backgroundColor = isEven ? Colors.grey[50] : Colors.white;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Date
          Expanded(
            flex: 2,
            child: Text(
              transaction['date'],
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          // Income
          Expanded(
            flex: 2,
            child: Text(
              transaction['income'] > 0 ? '+${transaction['income'].toStringAsFixed(0)} ج.م' : '-',
              style: TextStyle(
                fontSize: 12,
                color: transaction['income'] > 0 ? Colors.green : Colors.grey,
                fontWeight: transaction['income'] > 0 ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Expense
          Expanded(
            flex: 2,
            child: Text(
              transaction['expense'] > 0
                  ? '-${transaction['expense'].toStringAsFixed(0)} ج.م'
                  : '-',
              style: TextStyle(
                fontSize: 12,
                color: transaction['expense'] > 0 ? Colors.red : Colors.grey,
                fontWeight: transaction['expense'] > 0 ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Details
          Expanded(
            flex: 3,
            child: Text(
              transaction['details'],
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredTransactions() {
    if (selectedBranch == 'all') {
      return transactionData;
    } else {
      String branchName = branches.firstWhere((b) => b['id'] == selectedBranch)['name'];
      return transactionData.where((transaction) => transaction['branch'] == branchName).toList();
    }
  }

  Widget _buildSummaryCard(String title, double amount, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${amount.toStringAsFixed(0)} ج.م',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'تحويل بين الفروع',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // To Branch
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'إلى الفرع',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      value: transferTo.isEmpty ? null : transferTo,
                      items: branches
                          .where((branch) => branch['id'] != transferFrom)
                          .map((branch) => DropdownMenuItem<String>(
                                value: branch['id'],
                                child: Text(branch['name']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          transferTo = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Amount
                    TextFormField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'المبلغ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        suffixText: 'ج.م',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Note
                    TextFormField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: 'ملاحظة',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    SoundManager().playClickSound();
                    Navigator.of(context).pop();
                    _resetTransferForm();
                  },
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    SoundManager().playClickSound();
                    if (_validateTransfer()) {
                      _executeTransfer();
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('تحويل'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _validateTransfer() {
    if (transferTo.isEmpty || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
      );
      return false;
    }

    double amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
      );
      return false;
    }

    return true;
  }

  void _executeTransfer() {
    String toBranch = branches.firstWhere((b) => b['id'] == transferTo)['name'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحويل ${amountController.text} ج.م إلى $toBranch'),
        backgroundColor: Colors.green,
      ),
    );

    _resetTransferForm();
  }

  void _resetTransferForm() {
    transferFrom = '';
    transferTo = '';
    amountController.clear();
    noteController.clear();
  }

  double _getTotalBalance() {
    return transactionData.fold(0, (sum, item) => sum + (item['income'] - item['expense']));
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
