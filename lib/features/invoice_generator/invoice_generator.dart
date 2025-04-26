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
        theme: pw.ThemeData.withFont(
          base: isArabic ? ttf : pw.Font.helvetica(),
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
                      fontWeight: pw.FontWeight.bold, fontSize: 20),
                ),
                pw.Text('Invoice #: $invoiceNumber'),
                pw.Text('Date: ${date.toString().split(' ')[0]}'),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),

        // Table header
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Description')),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5), child: pw.Text('Qty')),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Unit Price')),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text('Total')),
              ],
            ),

            // Items
            ...items.map((item) => pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(item.description)),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(item.quantity.toString())),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('\$${item.price.toStringAsFixed(2)}')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                            '\$${(item.quantity * item.price).toStringAsFixed(2)}')),
                  ],
                )),
          ],
        ),

        // Total
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text('Total: \$${total.toStringAsFixed(2)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ],
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
