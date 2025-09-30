import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:promoter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:promoter_app/features/sales_invoice/models/sales_invoice_model.dart';
import 'package:promoter_app/qara_ksa.dart';
import 'package:share_plus/share_plus.dart';

class PrintInvoiceScreen extends StatefulWidget {
  final bool isPrinting;
  final SalesInvoice invoice;
  const PrintInvoiceScreen({super.key, required this.isPrinting, required this.invoice});

  @override
  State<PrintInvoiceScreen> createState() => _PrintInvoiceScreenState();
}

class _PrintInvoiceScreenState extends State<PrintInvoiceScreen> {
  ReceiptController? controller;
  bool _isProcessing = false;

  @override
  dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _handlePrint() async {
    if (controller == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Get image bytes first
      final imageBytes = await controller!.getImageBytes();

      // Select Bluetooth device
      final device = await FlutterBluetoothPrinter.selectDevice(context);
      if (device == null) {
        _showMessage('لم يتم اختيار جهاز طباعة');
        return;
      }

      await controller!.print(address: device.address);
      // Share the image as well
      //  await _shareImage(imageBytes);

      _showMessage('تم إرسال الطباعة بنجاح');
    } catch (e) {
      print('Error in printing: $e');
      _showMessage('خطأ في الطباعة: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _shareImage(Uint8List imageBytes) async {
    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.png';

      // Write bytes to file
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      // Share the file
      await Share.shareXFiles([XFile(imagePath)], text: 'فاتورة البيع');
    } catch (e) {
      print('Error sharing image: $e');
    }
  }

  Future<void> _handleShareOnly() async {
    if (controller == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final imageBytes = await controller!.getImageBytes();
      await _shareImage(imageBytes);
      _showMessage('تم مشاركة الفاتورة بنجاح');
    } catch (e) {
      print('Error sharing: $e');
      _showMessage('خطأ في المشاركة: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('خطأ') ? Colors.red : Colors.green,
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: const Text('مشاركة كصورة'),
                onTap: () {
                  Navigator.pop(context);
                  _handleShareOnly();
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('مشاركة كـ PDF'),
                onTap: () {
                  Navigator.pop(context);
                  convertSingleImageToPdf();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text('إلغاء'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Uint8List> convertSingleImageToPdf() async {
    final imageBytes = await controller!.getImageBytes();
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.png';

    // Write bytes to file
    final file = File(imagePath);
    await file.writeAsBytes(imageBytes);

    final pdf = pw.Document();
    final image = pw.MemoryImage(file.readAsBytesSync());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.fill),
          );
        },
      ),
    );

    // Save PDF to bytes
    final pdfBytes = await pdf.save();

    // Create PDF file for sharing
    final pdfPath = '${directory.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final pdfFile = File(pdfPath);
    await pdfFile.writeAsBytes(pdfBytes);

    // Share the PDF file
    await Share.shareXFiles([XFile(pdfPath)], text: 'فاتورة البيع');

    // Clean up temporary files
    try {
      await file.delete();
      await pdfFile.delete();
    } catch (e) {
      // Handle deletion errors if needed
      print('Error deleting temporary files: $e');
    }

    return pdfBytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.isPrinting ? 'طباعة الفاتورة' : "مشاركة الفاتورة"),
        centerTitle: true,
        backgroundColor: const Color(0xFF148ccd),
        foregroundColor: Colors.white,
        actions: [
          // Share button
          if (!widget.isPrinting)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _isProcessing ? null : _showShareOptions,
            ),
          // Print button
          if (widget.isPrinting)
            IconButton(
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.print, color: Colors.white),
              onPressed: _isProcessing ? null : _handlePrint,
            ),
        ],
      ),
      body: Center(
        child: Receipt(
          backgroundColor: Colors.white,
          defaultTextStyle: const TextStyle(fontSize: 15),
          onInitialized: (ReceiptController controller) {
            this.controller = controller;
            controller.paperSize = PaperSize.mm80;
          },
          builder: (context) => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 8),

                // Invoice Details
                _buildInvoiceDetails(),
                const SizedBox(height: 16),

                // Items Table
                _buildItemsTable(),
                const SizedBox(height: 16),

                // Totals Section
                _buildTotalsSection(),
                const SizedBox(height: 16),

                // Footer
                _buildFooter(),
                if (widget.isPrinting) const SizedBox(height: 170), // Add some bottom spacing
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo_banner.png',
            height: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          const Text(
            'شركة الياسين للتجارة والتوزيع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('رقم الفاتورة: ${widget.invoice.id}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                  'نوع الفاتورة: ${widget.invoice.paymentMethod == "deferred" ? "آجل" : widget.invoice.paymentMethod == "bank_transfer" ? "تحويل بنكي" : "نقدي"}',
                  style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text('العميل: ${widget.invoice.clientName}', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'التاريخ: ${DateFormat("dd/MM/yyyy", "ar").format(DateTime.now())}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'الوقت: ${DateFormat('HH:mm', "ar").format(DateTime.now())}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String userName = 'مستخدم';
                  if (state is AuthAuthenticated) {
                    userName = state.user.name;
                  }
                  return Text(
                    'المندوب: $userName',
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsTable() {
    return Table(
      border: TableBorder.all(color: Colors.black, width: 1),
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: [
            _buildTableCell('الإجمالي', isHeader: true),
            _buildTableCell('السعر', isHeader: true),
            _buildTableCell('الوحدة', isHeader: true),
            _buildTableCell('الكمية', isHeader: true),
            _buildTableCell('المنتج', isHeader: true),
          ],
        ),
        // Data rows
        ..._buildDataRows(),
      ],
    );
  }

  List<TableRow> _buildDataRows() {
    final items = widget.invoice.items
        .map((item) => {
              'product': item.productName,
              'quantity': item.quantity.toString(),
              'unit': "",
              'price': item.price.toStringAsFixed(2),
              'total': (item.quantity * item.price).toStringAsFixed(2),
            })
        .toList();

    return items
        .map((item) => TableRow(
              children: [
                _buildTableCell(item['total']!),
                _buildTableCell(item['price']!),
                _buildTableCell(item['unit']!),
                _buildTableCell(item['quantity']!),
                _buildTableCell(item['product']!),
              ],
            ))
        .toList();
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isHeader ? 13 : 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Table(
      border: TableBorder.all(color: Colors.black, width: 1),
      children: [
        TableRow(children: [
          _buildTotalCell('إجمالي الكميات: ${widget.invoice.totalQuantity ?? 0}'),
          _buildTotalCell('إجمالي المنتجات: ${widget.invoice.items.length}'),
        ]),
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: [
            _buildTotalCell('إجمالي الفاتورة', isBold: true),
            _buildTotalCell("${widget.invoice.total} ج.م", isBold: true),
          ],
        ),
        TableRow(children: [
          _buildTotalCell('الخصم'),
          _buildTotalCell('${widget.invoice.discount} ج.م'),
        ]),
        TableRow(children: [
          _buildTotalCell('إضافة'),
          _buildTotalCell('${widget.invoice.tax} ج.م'),
        ]),
        TableRow(children: [
          _buildTotalCell('ضريبة القيمة المضافة' ' 15%'),
          _buildTotalCell('${(widget.invoice.total * 0.15).toStringAsFixed(2)} ج.م'),
        ]),
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[300]),
          children: [
            _buildTotalCell('المبلغ المستحق', isBold: true),
            _buildTotalCell(
                '${(widget.invoice.total * 1.15 + widget.invoice.tax).toStringAsFixed(2)} ج.م',
                isBold: true),
          ],
        ),
        TableRow(children: [
          _buildTotalCell('الرصيد السابق'),
          _buildTotalCell('0.0 ج.م'),
        ]),
      ],
    );
  }

  Widget _buildTotalCell(String text, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 1)),
      ),
      child: const Column(
        children: [
          Text(
            'سعداء لتعاملكم معنا',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'خدمة العملاء: 01021721842',
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            'شكراً لزيارتكم',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
