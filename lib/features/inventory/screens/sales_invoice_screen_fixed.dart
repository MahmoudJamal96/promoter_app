import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/product_model.dart';
import '../services/inventory_service.dart';
import '../../sales_invoice/models/sales_invoice_model.dart' as invoice_model;
import '../../products/services/products_service.dart';
import '../../sales_invoice/services/order_service.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/constants/strings.dart';
import '../../invoice_generator/invoice_generator.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

// Custom converter for sales invoice items
class SalesInvoiceConverter implements InvoiceConverter<InvoiceItem> {
  final String companyName;
  final String invoiceNumber;
  final String customerName;
  final DateTime date;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;

  SalesInvoiceConverter({
    required this.companyName,
    required this.invoiceNumber,
    required this.customerName,
    required this.date,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
  });

  @override
  pw.Widget buildInvoice(List<InvoiceItem> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  companyName,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 24),
                ),
                pw.SizedBox(height: 8),
                pw.Text('رقم الفاتورة: $invoiceNumber',
                    style: pw.TextStyle(fontSize: 14)),
                pw.Text('التاريخ: ${date.toString().split(' ')[0]}',
                    style: pw.TextStyle(fontSize: 14)),
                pw.Text('العميل: $customerName',
                    style: pw.TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 30),

        // Table header
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(4),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('المنتج',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('الكمية',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('السعر',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('المجموع',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),

            // Items
            ...items.map((item) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item.description),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(item.quantity.toString()),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${item.price.toStringAsFixed(2)} جنيه'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                          '${(item.quantity * item.price).toStringAsFixed(2)} جنيه'),
                    ),
                  ],
                )),
          ],
        ),

        pw.SizedBox(height: 30),

        // Totals section
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('المجموع الفرعي: ${subtotal.toStringAsFixed(2)} جنيه'),
                pw.Text('الضريبة (15%): ${tax.toStringAsFixed(2)} جنيه'),
                if (discount > 0)
                  pw.Text('الخصم: ${discount.toStringAsFixed(2)} جنيه'),
                pw.Divider(),
                pw.Text(
                  'المجموع الكلي: ${total.toStringAsFixed(2)} جنيه',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class SalesInvoiceScreen extends StatefulWidget {
  final String? initialClientName;
  final String? initialClientPhone;

  const SalesInvoiceScreen({
    super.key,
    this.initialClientName,
    this.initialClientPhone,
  });

  @override
  State<SalesInvoiceScreen> createState() => _SalesInvoiceScreenState();
}

class _SalesInvoiceScreenState extends State<SalesInvoiceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController =
      TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  bool _isSearching = false;
  List<Product> _searchResults = [];
  List<SalesItem> _cartItems = [];
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  // Services
  late ProductsService _productsService;
  late OrderService _orderService;
  @override
  void initState() {
    super.initState();
    _discountController.text = '0';
    _productsService = sl<ProductsService>();
    _orderService = OrderService();

    // Set initial client data if provided
    if (widget.initialClientName != null) {
      _customerNameController.text = widget.initialClientName!;
    }
    if (widget.initialClientPhone != null) {
      _customerPhoneController.text = widget.initialClientPhone!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  // Search products by name or barcode using API
  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Use ProductsService to search products via API
      final apiResults = await _productsService.scanProduct(name: query);

      // Convert API products to local Product model
      final List<Product> results = apiResults
          .map((apiProduct) => Product(
                id: apiProduct.id.toString(),
                name: apiProduct.name,
                category: apiProduct.categoryName,
                price: apiProduct.price,
                quantity: apiProduct.quantity,
                imageUrl:
                    apiProduct.imageUrl ?? 'assets/images/yasin_app_logo.JPG',
                barcode: apiProduct.barcode,
                location: 'الرف ${apiProduct.categoryId}',
                supplier: apiProduct.companyName ?? 'غير محدد',
                lastUpdated:
                    DateTime.tryParse(apiProduct.updatedAt) ?? DateTime.now(),
              ))
          .toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      _showErrorSnackBar('خطأ في البحث: ${e.toString()}');
    }
  }

  // Add product to cart
  void _addToCart(Product product) {
    final existingItemIndex =
        _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex >= 0) {
      // Increment quantity
      setState(() {
        _cartItems[existingItemIndex] = _cartItems[existingItemIndex].copyWith(
          quantity: _cartItems[existingItemIndex].quantity + 1,
        );
      });
    } else {
      // Add new item
      setState(() {
        _cartItems.add(SalesItem(
          product: product,
          quantity: 1,
          price: product.price,
        ));
      });
    }

    // Clear search
    _searchController.clear();
    setState(() {
      _searchResults = [];
    });

    _showSuccessSnackBar('تم إضافة ${product.name} إلى الفاتورة');
  }

  // Remove product from cart
  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  // Update cart item quantity
  void _updateCartItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
      return;
    }

    setState(() {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
    });
  }

  // Calculate totals
  double get _subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.total);

  double get _discount => double.tryParse(_discountController.text) ?? 0.0;

  double get _vat => _subtotal * 0.15;

  double get _total => _subtotal + _vat - _discount;
  // Create invoice using API
  Future<void> _createInvoice() async {
    if (_cartItems.isEmpty) {
      _showErrorSnackBar('لا يمكن إنشاء فاتورة فارغة');
      return;
    }

    if (_customerNameController.text.isEmpty) {
      _showErrorSnackBar('يرجى إدخال اسم العميل');
      return;
    }
    try {
      // Show loading dialog
      _showLoadingDialog(); // Create order using OrderService
      final result = await _orderService.createOrder(
        items: _cartItems,
        customerName: _customerNameController.text,
        customerPhone: _customerPhoneController.text.isEmpty
            ? 'غير محدد'
            : _customerPhoneController.text,
        paymentMethod: _selectedPaymentMethod,
        discount: _discount,
      );

      // Close loading dialog
      Navigator.pop(context);

      _showSuccessSnackBar('تم إنشاء الفاتورة بنجاح');

      // Print the invoice directly
      await _printInvoice(result);

      _resetForm();
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) Navigator.pop(context);
      _showErrorSnackBar('خطأ في إنشاء الفاتورة: ${e.toString()}');
    }
  }

  // Print invoice method using InvoiceGenerator
  Future<void> _printInvoice(invoice_model.SalesInvoice invoice) async {
    try {
      // Convert invoice items to InvoiceItem format
      final List<InvoiceItem> invoiceItems = invoice.items
          .map((item) => InvoiceItem(
                description: item.productName,
                quantity: item.quantity,
                price: item.price,
              ))
          .toList();

      // Create converter with invoice details
      final converter = SalesInvoiceConverter(
        companyName: 'شركة الياسين التجارية',
        invoiceNumber: invoice.invoiceNumber,
        customerName: invoice.clientName,
        date: DateTime.tryParse(invoice.createdAt) ?? DateTime.now(),
        subtotal: invoice.subtotal,
        tax: invoice.tax,
        discount: invoice.discount,
        total: invoice.total,
      );

      // Generate PDF
      final pdfBytes = await InvoiceGenerator.toPrinter(
        invoiceItems,
        converter: converter,
        isArabic: true,
      );

      // Show print preview and options
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('طباعة الفاتورة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('رقم الفاتورة: ${invoice.invoiceNumber}'),
              Text('العميل: ${invoice.clientName}'),
              Text(
                  'المجموع: ${invoice.total.toStringAsFixed(2)} ${Strings.CURRENCY}'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      // Show print preview
                      InvoiceGenerator.showPrintPreview(context, pdfBytes);
                    },
                    icon: const Icon(Icons.preview),
                    label: const Text('معاينة'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      // Print directly
                      final success =
                          await InvoiceGenerator.printDocument(pdfBytes);
                      if (success) {
                        _showSuccessSnackBar('تم طباعة الفاتورة بنجاح');
                      } else {
                        _showErrorSnackBar('فشل في طباعة الفاتورة');
                      }
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('طباعة'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorSnackBar('خطأ في تجهيز الفاتورة للطباعة: ${e.toString()}');
    }
  }

  // Show invoice created dialog
  void _showInvoiceCreatedDialog(invoice_model.SalesInvoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
            SizedBox(width: 8.w),
            const Text('تم إنشاء الفاتورة بنجاح'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('رقم الفاتورة: ${invoice.id}'),
            SizedBox(height: 8.h),
            Text(
                'إجمالي الفاتورة: ${invoice.total.toStringAsFixed(2)} ${Strings.CURRENCY}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  // Show invoice summary dialog
  void _showInvoiceSummaryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ملخص الفاتورة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('العميل: ${_customerNameController.text}'),
            if (_customerPhoneController.text.isNotEmpty)
              Text('الهاتف: ${_customerPhoneController.text}'),
            const Divider(),
            Text(
                'المجموع الفرعي: ${_subtotal.toStringAsFixed(2)} ${Strings.CURRENCY}'),
            Text(
                'ضريبة القيمة المضافة: ${_vat.toStringAsFixed(2)} ${Strings.CURRENCY}'),
            if (_discount > 0)
              Text(
                  'الخصم: ${_discount.toStringAsFixed(2)} ${Strings.CURRENCY}'),
            const Divider(),
            Text(
              'المجموع الكلي: ${_total.toStringAsFixed(2)} ${Strings.CURRENCY}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('بدء فاتورة جديدة'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  // Show loading dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('جاري إنشاء الفاتورة...'),
          ],
        ),
      ),
    );
  }

  // Reset form after creating invoice
  void _resetForm() {
    setState(() {
      _cartItems = [];
      _customerNameController.clear();
      _customerPhoneController.clear();
      _discountController.text = '0';
      _selectedPaymentMethod = PaymentMethod.cash;
    });
  }

  // Scan barcode using camera
  Future<void> _scanBarcode() async {
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'مسح الباركود',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                          final List<Barcode> barcodes = capture.barcodes;
                          if (barcodes.isNotEmpty &&
                              barcodes.first.rawValue != null) {
                            Navigator.pop(context, barcodes.first.rawValue);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (result != null && result.isNotEmpty) {
        // Search for product by barcode
        final apiResults = await _productsService.scanProduct(barcode: result);

        if (apiResults.isNotEmpty) {
          final apiProduct = apiResults.first;
          final scannedProduct = Product(
            id: apiProduct.id.toString(),
            name: apiProduct.name,
            category: apiProduct.categoryName,
            price: apiProduct.price,
            quantity: apiProduct.quantity,
            imageUrl: apiProduct.imageUrl ?? 'assets/images/yasin_app_logo.JPG',
            barcode: apiProduct.barcode,
            location: 'الرف ${apiProduct.categoryId}',
            supplier: apiProduct.companyName ?? 'غير محدد',
            lastUpdated:
                DateTime.tryParse(apiProduct.updatedAt) ?? DateTime.now(),
          );

          _addToCart(scannedProduct);
        } else {
          _showErrorSnackBar('لم يتم العثور على منتج بهذا الباركود');
        }
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في مسح الباركود: ${e.toString()}');
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('فاتورة مبيعات جديدة'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanBarcode,
            tooltip: 'مسح الباركود',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search section
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _searchProducts(value);
                } else {
                  setState(() {
                    _searchResults = [];
                  });
                }
              },
            ),
          ),

          // Search results
          if (_isSearching)
            Container(
              height: 200.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_searchResults.isNotEmpty)
            Container(
              height: 200.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                padding: EdgeInsets.all(8.w),
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(product.imageUrl),
                      onBackgroundImageError: (_, __) {},
                      child: product.imageUrl.isEmpty
                          ? Icon(Icons.inventory, size: 20.sp)
                          : null,
                    ),
                    title: Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
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
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () => _addToCart(product),
                    ),
                    onTap: () => _addToCart(product),
                  );
                },
              ),
            ).animate().fade(duration: 200.ms),

          // Cart items and summary
          Expanded(
            child: _cartItems.isEmpty
                ? Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 72.sp,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'لا توجد منتجات في الفاتورة',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'ابحث عن منتج لإضافته إلى الفاتورة',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ).animate().fade(duration: 300.ms),
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
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
                                  'عناصر الفاتورة (${_cartItems.length})',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                ...List.generate(_cartItems.length, (index) {
                                  final item = _cartItems[index];
                                  return Column(
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.h),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.product.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14.sp,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    '${item.price.toStringAsFixed(2)} ${Strings.CURRENCY}',
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: theme
                                                          .colorScheme.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Row(
                                              children: [
                                                _buildQuantityButton(
                                                  icon: Icons.remove,
                                                  onTap: () =>
                                                      _updateCartItemQuantity(
                                                          index,
                                                          item.quantity - 1),
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
                                                      _updateCartItemQuantity(
                                                          index,
                                                          item.quantity + 1),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 16.w),
                                            Text(
                                              '${item.total.toStringAsFixed(2)} ${Strings.CURRENCY}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  _removeFromCart(index),
                                              iconSize: 20.sp,
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (index < _cartItems.length - 1)
                                        Divider(
                                          height: 16.h,
                                          thickness: 1,
                                          color: Colors.grey.shade200,
                                        ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Customer info section
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
                                  'معلومات العميل',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _customerNameController,
                                        decoration: InputDecoration(
                                          labelText: 'اسم العميل *',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: TextField(
                                        controller: _customerPhoneController,
                                        decoration: InputDecoration(
                                          labelText: 'رقم الهاتف',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                        ),
                                        keyboardType: TextInputType.phone,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Payment method section
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
                                  'طريقة الدفع',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    _buildPaymentMethodButton(
                                      method: PaymentMethod.cash,
                                      label: 'نقدي',
                                      icon: Icons.money,
                                    ),
                                    SizedBox(width: 8.w),
                                    _buildPaymentMethodButton(
                                      method: PaymentMethod.credit,
                                      label: 'آجل',
                                      icon: Icons.credit_card,
                                    ),
                                    SizedBox(width: 8.w),
                                    _buildPaymentMethodButton(
                                      method: PaymentMethod.bank,
                                      label: 'بنكي',
                                      icon: Icons.account_balance,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Summary section
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'المجموع الفرعي:',
                                      style: TextStyle(fontSize: 16.sp),
                                    ),
                                    Text(
                                      '${_subtotal.toStringAsFixed(2)} ${Strings.CURRENCY}',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'ضريبة القيمة المضافة (15%):',
                                      style: TextStyle(fontSize: 16.sp),
                                    ),
                                    Text(
                                      '${_vat.toStringAsFixed(2)} ${Strings.CURRENCY}',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Text(
                                      'الخصم:',
                                      style: TextStyle(fontSize: 16.sp),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: TextField(
                                        controller: _discountController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                          suffixText: Strings.CURRENCY,
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+\.?\d{0,2}')),
                                        ],
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                Divider(thickness: 1),
                                SizedBox(height: 8.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'المجموع الإجمالي:',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${_total.toStringAsFixed(2)} ${Strings.CURRENCY}',
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
                                  child: ElevatedButton(
                                    onPressed: _cartItems.isNotEmpty
                                        ? _createInvoice
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14.h),
                                      minimumSize: Size(double.infinity, 50.h),
                                    ),
                                    child: Text(
                                      'إنشاء الفاتورة',
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

                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Icon(icon, size: 18.sp),
      ),
    );
  }

  Widget _buildPaymentMethodButton({
    required PaymentMethod method,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == method;
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method;
          });
        },
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color:
                  isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey.shade600,
                size: 24.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
