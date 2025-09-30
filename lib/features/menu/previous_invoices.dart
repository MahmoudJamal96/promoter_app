import 'package:flutter/material.dart';

class PreviousInvoicesScreen extends StatefulWidget {
  const PreviousInvoicesScreen({super.key});

  @override
  State<PreviousInvoicesScreen> createState() => _PreviousInvoicesScreenState();
}

class _PreviousInvoicesScreenState extends State<PreviousInvoicesScreen> {
  final TextEditingController _invoiceNumberController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  String _selectedInvoiceType = 'الكل';
  bool _showResults = false;
  bool _isLoading = false;

  final List<String> _invoiceTypes = [
    'الكل',
    'فاتورة بيع',
    'مرتجع',
    'تحصيل',
    'صرف',
    'تحويل مخزون',
    'تحويل خزينة'
  ];

  // Sample data for demonstration
  final List<Invoice> _sampleInvoices = [
    const Invoice(
      id: 'INV-001',
      customerName: 'أحمد محمد',
      date: '2024-08-01',
      amount: 1250.00,
      status: InvoiceStatus.paid,
      type: 'فاتورة بيع',
      paymentMethod: 'نقداً',
    ),
    const Invoice(
      id: 'INV-002',
      customerName: 'فاطمة علي',
      date: '2024-08-02',
      amount: 850.50,
      status: InvoiceStatus.unpaid,
      type: 'فاتورة بيع',
      paymentMethod: 'آجل',
    ),
    const Invoice(
      id: 'INV-003',
      customerName: 'محمود حسن',
      date: '2024-08-03',
      amount: 2100.75,
      status: InvoiceStatus.partial,
      type: 'فاتورة بيع',
      paymentMethod: 'جزئي',
    ),
    const Invoice(
      id: 'RET-001',
      customerName: 'سارة أحمد',
      date: '2024-08-04',
      amount: 300.00,
      status: InvoiceStatus.paid,
      type: 'مرتجع',
      paymentMethod: 'نقداً',
    ),
  ];

  List<Invoice> _filteredInvoices = [];

  @override
  void initState() {
    super.initState();
    _loadRecentInvoices();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _invoiceNumberController.dispose();
    _customerNameController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  void _loadRecentInvoices() {
    setState(() {
      _filteredInvoices = _sampleInvoices.take(10).toList();
      _showResults = true;
    });
  }

  void _searchInvoices() {
    if (_isLoading) return; // Prevent multiple simultaneous searches

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return; // Check if widget is still mounted

      List<Invoice> results = List.from(_sampleInvoices); // Create a copy

      // Filter by invoice number
      if (_invoiceNumberController.text.isNotEmpty) {
        results = results
            .where((invoice) =>
                invoice.id.toLowerCase().contains(_invoiceNumberController.text.toLowerCase()))
            .toList();
      }

      // Filter by customer name
      if (_customerNameController.text.isNotEmpty) {
        results = results
            .where((invoice) => invoice.customerName.contains(_customerNameController.text))
            .toList();
      }

      // Filter by invoice type
      if (_selectedInvoiceType != 'الكل') {
        results = results.where((invoice) => invoice.type == _selectedInvoiceType).toList();
      }

      // Filter by date range
      if (_fromDateController.text.isNotEmpty || _toDateController.text.isNotEmpty) {
        results = results.where((invoice) {
          DateTime invoiceDate = DateTime.parse(invoice.date);

          if (_fromDateController.text.isNotEmpty) {
            DateTime fromDate = DateTime.parse(_fromDateController.text);
            if (invoiceDate.isBefore(fromDate)) return false;
          }

          if (_toDateController.text.isNotEmpty) {
            DateTime toDate = DateTime.parse(_toDateController.text);
            if (invoiceDate.isAfter(toDate)) return false;
          }

          return true;
        }).toList();
      }

      if (mounted) {
        setState(() {
          _filteredInvoices = results;
          _showResults = true;
          _isLoading = false;
        });
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _invoiceNumberController.clear();
      _customerNameController.clear();
      _fromDateController.clear();
      _toDateController.clear();
      _selectedInvoiceType = 'الكل';
      _showResults = false;
      _filteredInvoices.clear();
    });
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null && mounted) {
      setState(() {
        controller.text = picked.toString().split(' ')[0];
      });
    }
  }

  void _viewInvoiceDetails(Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvoiceDetailsSheet(invoice: invoice),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'فواتيري السابقة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF148ccd),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          // Changed from SingleChildScrollView to Column
          children: [
            // Search Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quick Actions Row
                    OutlinedButton.icon(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('مسح البحث'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search Fields
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _invoiceNumberController,
                            label: 'رقم الفاتورة',
                            icon: Icons.receipt_long,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _customerNameController,
                            label: 'اسم العميل',
                            icon: Icons.person,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Date Range and Type Filter
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            controller: _fromDateController,
                            label: 'من تاريخ',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateField(
                            controller: _toDateController,
                            label: 'إلى تاريخ',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Invoice Type Dropdown
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedInvoiceType,
                        decoration: const InputDecoration(
                          labelText: 'نوع الحركة',
                          prefixIcon: Icon(Icons.category),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        items: _invoiceTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedInvoiceType = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search Button
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _searchInvoices,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(_isLoading ? 'جاري البحث...' : 'بحث'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF148ccd),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Results Section
            if (_showResults) ...[
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Icon(Icons.receipt, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'النتائج: ${_filteredInvoices.length} فاتورة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _filteredInvoices.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'لا توجد نتائج',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'جرب تعديل معايير البحث',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredInvoices.length,
                        itemBuilder: (context, index) {
                          return InvoiceCard(
                            invoice: _filteredInvoices[index],
                            onTap: () => _viewInvoiceDetails(_filteredInvoices[index]),
                          );
                        },
                      ),
              ),
            ] else
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'ابدأ البحث أو اضغط على "أحدث الفواتير"',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(controller),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      controller.clear();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }
}

enum InvoiceStatus { paid, unpaid, partial }

class Invoice {
  final String id;
  final String customerName;
  final String date;
  final double amount;
  final InvoiceStatus status;
  final String type;
  final String paymentMethod;

  const Invoice({
    required this.id,
    required this.customerName,
    required this.date,
    required this.amount,
    required this.status,
    required this.type,
    required this.paymentMethod,
  });
}

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onTap,
  });

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.unpaid:
        return Colors.red;
      case InvoiceStatus.partial:
        return Colors.orange;
    }
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return 'مدفوعة';
      case InvoiceStatus.unpaid:
        return 'غير مدفوعة';
      case InvoiceStatus.partial:
        return 'مدفوعة جزئياً';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.id,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invoice.customerName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(invoice.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(invoice.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(invoice.status),
                      style: TextStyle(
                        color: _getStatusColor(invoice.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        invoice.date,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${invoice.amount.toStringAsFixed(2)} ر.س',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      invoice.type,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    invoice.paymentMethod,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
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

class InvoiceDetailsSheet extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailsSheet({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'تفاصيل الفاتورة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('مشاركة الفاتورة...')),
                            );
                          },
                          icon: const Icon(Icons.share),
                          tooltip: 'مشاركة',
                        ),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('طباعة الفاتورة...')),
                            );
                          },
                          icon: const Icon(Icons.print),
                          tooltip: 'طباعة',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('رقم الفاتورة', invoice.id),
                      _buildDetailRow('اسم العميل', invoice.customerName),
                      _buildDetailRow('التاريخ', invoice.date),
                      _buildDetailRow('المبلغ', '${invoice.amount.toStringAsFixed(2)} ر.س'),
                      _buildDetailRow('نوع الحركة', invoice.type),
                      _buildDetailRow('طريقة الدفع', invoice.paymentMethod),
                      _buildDetailRow('الحالة', _getStatusText(invoice.status)),
                      const SizedBox(height: 20),
                      const Text(
                        'تفاصيل إضافية',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: const Text(
                          'هنا يمكن عرض تفاصيل إضافية عن الفاتورة مثل الأصناف المباعة، الكميات، والملاحظات.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
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
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return 'مدفوعة';
      case InvoiceStatus.unpaid:
        return 'غير مدفوعة';
      case InvoiceStatus.partial:
        return 'مدفوعة جزئياً';
    }
  }
}
