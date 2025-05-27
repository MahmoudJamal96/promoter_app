import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Generic interface for converting items to invoice format
abstract class InvoiceConverter<T> {
  pw.Widget buildInvoice(List<T> items);
}

class InvoiceGenerator {
  /// Converts a list of items to a printer-friendly format
  static Future<Uint8List> toPrinter<T>(
    List<T> items, {
    required InvoiceConverter<T> converter,
    PdfPageFormat format = PdfPageFormat.a4,
    bool isArabic = true,
  }) async {
    // Load the Arabic font
    final fontData =
        await rootBundle.load("assets/fonts/NotoSansArabic-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(20),
        theme: pw.ThemeData.withFont(
          base: isArabic ? ttf : pw.Font.helvetica(),
          bold: isArabic ? ttf : pw.Font.helveticaBold(),
        ),
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => converter.buildInvoice(items),
      ),
    );
    return pdf.save();
  }

  /// Generates an image from the invoice PDF
  static Future<Uint8List> generateImage(
    Uint8List pdfBytes, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final pages = await Printing.raster(pdfBytes, dpi: 300);
    // Wait for the Future to complete and then convert to PNG
    final firstPage = await pages.first;
    return firstPage.toPng();
  }

  /// Lists available printers
  static Future<List<Printer>> listPrinters() async {
    return await Printing.listPrinters();
  }

  /// Prints the document directly
  static Future<bool> printDocument(
    Uint8List pdfBytes, {
    String? printerName,
  }) async {
    return await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
      name: 'Invoice',
      // printer: printerName != null ? Printer(name: printerName) : null,
    );
  }

  /// Shows a print preview dialog
  static void showPrintPreview(BuildContext context, Uint8List pdfBytes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Invoice Preview')),
          body: PdfPreview(
            build: (_) => pdfBytes,
          ),
        ),
      ),
    );
  }
}

/// Example of a converter implementation for invoice items
class InvoiceItemConverter<T extends InvoiceItem>
    implements InvoiceConverter<T> {
  final String companyName;
  final String invoiceNumber;
  final DateTime date;
  final String? companyLogo;

  InvoiceItemConverter({
    required this.companyName,
    required this.invoiceNumber,
    required this.date,
    this.companyLogo,
  });
  @override
  pw.Widget buildInvoice(List<T> items) {
    final total = items.fold<double>(
        0, (sum, item) => sum + (item.quantity * item.price));

    return pw.Padding(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header with proper Arabic alignment
          pw.Container(
            width: double.infinity,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  companyName,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'رقم الفاتورة: $invoiceNumber',
                      style: pw.TextStyle(fontSize: 14),
                    ),
                    pw.Text(
                      'التاريخ: ${date.toString().split(' ')[0]}',
                      style: pw.TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),

          // Table with improved design
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
            ),
            child: pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'الوصف',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'الكمية',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'السعر',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'المجموع',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),

                // Items rows
                ...items.map((item) => pw.TableRow(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            item.description,
                            style: pw.TextStyle(fontSize: 11),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            item.quantity.toString(),
                            style: pw.TextStyle(fontSize: 11),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${item.price.toStringAsFixed(2)} ر.س',
                            style: pw.TextStyle(fontSize: 11),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${(item.quantity * item.price).toStringAsFixed(2)} ر.س',
                            style: pw.TextStyle(fontSize: 11),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),

          // Total section with better design
          pw.SizedBox(height: 20),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'المجموع الكلي:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                pw.Text(
                  '${total.toStringAsFixed(2)} ر.س',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Footer with thank you message
          pw.SizedBox(height: 30),
          pw.Center(
            child: pw.Text(
              'شكراً لتعاملكم معنا',
              style: pw.TextStyle(
                fontSize: 14,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example item class for invoices
class InvoiceItem {
  final String description;
  final int quantity;
  final double price;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.price,
  });
}
