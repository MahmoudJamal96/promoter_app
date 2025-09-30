import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';
import 'package:promoter_app/features/inventory/models/product_model.dart';

class ProductToPrintWidget extends StatefulWidget {
  final List<Product> products;

  const ProductToPrintWidget({super.key, required this.products});

  @override
  _ProductToPrintWidgetState createState() => _ProductToPrintWidgetState();
}

class _ProductToPrintWidgetState extends State<ProductToPrintWidget> {
  List<Product> sampleProducts = [];

  @override
  void initState() {
    super.initState();
    sampleProducts = widget.products;
  }

  Future<Uint8List> _generateProductsPdf() async {
    final pdf = pw.Document();

    // Load Arabic font - you need to add this font file to your assets
    final arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
    final arabicFontBold = await PdfGoogleFonts.notoSansArabicBold();

    // Calculate totals
    double totalValue =
        sampleProducts.fold(0, (sum, product) => sum + (product.price * product.quantity));
    int totalQuantity = sampleProducts.fold(0, (sum, product) => sum + product.quantity);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        textDirection: pw.TextDirection.rtl, // Right-to-left for Arabic
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'تقرير المخزون',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      font: arabicFontBold,
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'تم في: ${DateTime.now().toString().split('.')[0]}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                      font: arabicFont,
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Summary Cards
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'عدد المنتجات',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            font: arabicFontBold,
                          ),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.Text(
                          '${sampleProducts.length}',
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'الكمية الإجمالية',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            font: arabicFontBold,
                          ),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.Text(
                          '$totalQuantity',
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.orange100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'القيمة الإجمالية',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            font: arabicFontBold,
                          ),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.Text(
                          totalValue.toStringAsFixed(2),
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // Products Table
            pw.Text(
              'تفاصيل المنتجات',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                font: arabicFontBold,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
            pw.SizedBox(height: 15),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FixedColumnWidth(50), // Qty
                1: const pw.FixedColumnWidth(70), // Price
                2: const pw.FlexColumnWidth(1.2), // Category
                3: const pw.FlexColumnWidth(2), // Name
                4: const pw.FixedColumnWidth(60), // ID
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableHeader('الكمية', arabicFontBold),
                    _buildTableHeader('السعر', arabicFontBold),
                    _buildTableHeader('الفئة', arabicFontBold),
                    _buildTableHeader('اسم المنتج', arabicFontBold),
                    _buildTableHeader('المعرف', arabicFontBold),
                  ],
                ),

                // Data rows
                ...sampleProducts.map((product) => pw.TableRow(
                      children: [
                        _buildTableCell(product.quantity.toString(), arabicFont),
                        _buildTableCell(product.price.toStringAsFixed(2), arabicFont),
                        _buildTableCell(product.category, arabicFont),
                        _buildTableCell(product.name, arabicFont),
                        _buildTableCell(product.id, arabicFont),
                      ],
                    )),
              ],
            ),

            pw.SizedBox(height: 30),

            // Footer
            pw.Divider(),
            pw.Text(
              'تم إنشاء هذا التقرير بواسطة تطبيق الياسين',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                font: arabicFont,
              ),
              textAlign: pw.TextAlign.center,
              textDirection: pw.TextDirection.rtl,
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildTableHeader(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
          font: font,
        ),
        textAlign: pw.TextAlign.center,
        textDirection: pw.TextDirection.rtl,
      ),
    );
  }

  pw.Widget _buildTableCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, font: font),
        textAlign: pw.TextAlign.center,
        textDirection: pw.TextDirection.rtl,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير المخزون'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('المنتجات', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${sampleProducts.length}',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.green.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('الكمية', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${sampleProducts.fold(0, (sum, product) => sum + product.quantity)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.orange.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            sampleProducts
                                .fold(
                                    0.0, (sum, product) => sum + (product.price * product.quantity))
                                .toStringAsFixed(2),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sampleProducts.length,
              itemBuilder: (context, index) {
                final product = sampleProducts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(product.name[0], style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('السعر: ${product.price} | الكمية: ${product.quantity}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          SoundManager().playClickSound();
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => _generateProductsPdf(),
          );
        },
        icon: const Icon(Icons.print),
        label: const Text('طباعة التقرير'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
