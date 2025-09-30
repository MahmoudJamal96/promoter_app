import 'dart:developer';

import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';
import 'package:promoter_app/features/menu/tasks/itinerary_clients.dart';
import 'package:promoter_app/qara_ksa.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  ReceiptController? controller;

  // Sample data - replace with your actual data
  final List<Map<String, dynamic>> itineraryData = const [
    {'day': 'السبت', 'route': 'القاهرة - الإسكندرية', 'clientCount': 25},
    {'day': 'الأحد', 'route': 'القاهرة - الإسكندرية', 'clientCount': 25},
    {'day': 'الاثنين', 'route': 'الجيزة - الفيوم', 'clientCount': 18},
    {'day': 'الثلاثاء', 'route': 'القاهرة - شرم الشيخ', 'clientCount': 32},
    {'day': 'الأربعاء', 'route': 'أسوان - الأقصر', 'clientCount': 15},
    {'day': 'الخميس', 'route': 'الإسكندرية - مطروح', 'clientCount': 22},
    {'day': 'الجمعة', 'route': 'القاهرة - بورسعيد', 'clientCount': 30},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول خط السير',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF148ccd),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () async {
              if (controller != null) {
                SoundManager().playClickSound();
                try {
                  final device = await FlutterBluetoothPrinter.selectDevice(context);
                  await controller!.print(address: device!.address);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إرسال الطباعة إلى الطابعة')),
                  );
                } catch (e) {
                  log('Print error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ في الطباعة: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: true
          ? const Center(
              child: Text("لايوجد خطوط سير متاحة"),
            )
          : Column(
              children: [
                // Table
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFF148ccd).withOpacity(0.1),
                        ),
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF148ccd),
                          fontSize: 14,
                        ),
                        dataTextStyle: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        columnSpacing: 20,
                        horizontalMargin: 16,
                        columns: const [
                          DataColumn(
                            label: Center(
                              child: Text('اليوم'),
                            ),
                          ),
                          DataColumn(
                            label: Center(
                              child: Text('خط السير'),
                            ),
                          ),
                          DataColumn(
                            label: Center(
                              child: Text('عدد العملاء'),
                            ),
                          )
                        ],
                        rows: itineraryData.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: 80, // Fixed width for all day cells
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    margin: EdgeInsets.symmetric(vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF148ccd).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      // Center the text within the fixed width
                                      child: Text(
                                        item['day'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF148ccd),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.route,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        item['route'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                InkWell(
                                  onTap: () {
                                    SoundManager().playClickSound();
                                    log('Tapped on client count for ${item['day']}');
                                    // Handle tap event, e.g., navigate to client list
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ItineraryClients(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: Colors.green.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          '${item['clientCount']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      const Icon(
                                        Icons.remove_red_eye,
                                        size: 16,
                                        color: Color(0xFF148ccd),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // Footer with summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إجمالي العملاء:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF148ccd),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${itineraryData.fold(0, (sum, item) => sum + (item['clientCount'] as int))}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
