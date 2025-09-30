import 'package:flutter/material.dart';
import 'package:promoter_app/features/tools/scanner/scanner_screen.dart';

import 'product_details_screen.dart';

class ScanningInquiryScreen extends StatefulWidget {
  const ScanningInquiryScreen({super.key});

  @override
  State<ScanningInquiryScreen> createState() => _ScanningInquiryScreenState();
}

class _ScanningInquiryScreenState extends State<ScanningInquiryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF148ccd),
        title: const Text("الاستعلام عن منتج"),
      ),
      body: Scanner(
        scanResult: (barcode) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Barcode: $barcode'),
            ),
          );

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(
                        qrCode: barcode,
                        productId: "djkjd",
                      )));
        },
      ),
    );
  }
}
