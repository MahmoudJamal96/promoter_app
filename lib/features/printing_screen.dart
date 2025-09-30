import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';

class PrintingScreen extends StatefulWidget {
  const PrintingScreen({super.key});

  @override
  State<PrintingScreen> createState() => _PrintingScreenState();
}

class _PrintingScreenState extends State<PrintingScreen> {
  ReceiptController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطباعة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.black),
            onPressed: () async {
              if (controller != null) {
                try {
                  final device = await FlutterBluetoothPrinter.selectDevice(context);
                  await controller!.print(address: device!.address);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إرسال الطباعة إلى الطابعة')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في الطباعة: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Receipt(
        defaultTextStyle: const TextStyle(fontSize: 14),
        onInitialized: (ReceiptController controller) {
          this.controller = controller;
          controller.paperSize = PaperSize.mm80;
        },
        builder: (context) => Container(
          width: double.infinity, // Use full width available (80mm)
          padding: const EdgeInsets.all(16.0), // Add some padding from edges
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
            children: [
              // Add some top spacing
              const SizedBox(height: 20),

              // Main title - centered
              const Text(
                'هذه هي شاشة الطباعة',
                style: TextStyle(
                  fontSize: 20, // Reduced size for 80mm paper
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Subtitle - centered
              const Text(
                'يمكنك إضافة محتوى الطباعة هنا',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // You can add more content here
              // For example, a separator line
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black,
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),

              // Example of left-aligned content
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'تاريخ: 2024/01/01',
                  style: TextStyle(fontSize: 14),
                ),
              ),

              const SizedBox(height: 10),

              // Example of right-aligned content
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'رقم الفاتورة: 12345',
                  style: TextStyle(fontSize: 14),
                ),
              ),

              const SizedBox(height: 30),

              // Centered footer
              const Text(
                'شكراً لكم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              // Add bottom spacing
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}
