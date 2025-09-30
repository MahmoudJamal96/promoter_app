import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';
import 'package:promoter_app/features/client/cubit/client_cubit_service.dart';
import 'package:promoter_app/features/client/cubit/client_state.dart';
import 'package:promoter_app/features/client/models/client_model.dart';
import 'package:promoter_app/features/client/widgets/change_status_dialoug.dart';
import 'package:promoter_app/features/client/widgets/enhanced_client_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/di/injection_container.dart';
import '../../inventory/screens/sales_invoice_screen_fixed.dart';

class ItineraryClients extends StatelessWidget {
  const ItineraryClients({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<ClientCubit>(), child: const ItineraryClientsScreen());
  }
}

class ItineraryClientsScreen extends StatefulWidget {
  const ItineraryClientsScreen({super.key});

  @override
  State<ItineraryClientsScreen> createState() => _ItineraryClientsScreenState();
}

class _ItineraryClientsScreenState extends State<ItineraryClientsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _makePhoneCall(String phoneNumber) async {
    SoundManager().playClickSound();
    try {
      // Clean the phone number (remove any non-digit characters except +)
      String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      final String url = "tel:$cleanedNumber";
      await launchUrlString(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الاتصال: $e')),
        );
      }
    }
  }

  void _openMap(double latitude, double longitude) async {
    try {
      final googleUrl =
          Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

      if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر فتح الخريطة')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في فتح الخريطة: $e')),
        );
      }
    }
  }

  void _createSalesInvoice(BuildContext context, Client client) {
    SoundManager().playClickSound();
    Navigator.pop(context); // Close the client details sheet
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SalesInvoiceScreen(
          initialClientName: client.name,
          initialClientPhone: client.phone ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF148ccd),
        title: const Text('العملاء',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<ClientCubit, ClientState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ClientLoaded) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  _buildSearchAndFilter(context),
                  Expanded(
                    child: _buildListView(context, state),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(state.error ?? 'حدث خطأ ما'),
            );
          }
        },
      ),
    );
  }

  List<Client> _getFilteredClients(ClientLoaded state) {
    // Start with base list - use sortedClients if available, otherwise use clients
    List<Client> result = state.sortedClients.isEmpty ? state.clients : state.sortedClients;

    // Apply search filter if query exists
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      result = result.where((client) {
        final name = client.name.toLowerCase();
        String phone = client.phone?.toLowerCase() ?? "";
        final address = client.address.toLowerCase();
        return name.contains(query) || phone.contains(query) || address.contains(query);
      }).toList();
    }

    // Apply status filter if not null (i.e., not "All")
    if (state.filterStatus != null) {
      result = result.where((client) => client.visitStatus == state.filterStatus).toList();
    }

    return result;
  }

  Widget _buildListView(BuildContext context, ClientLoaded state) {
    final filteredClients = _getFilteredClients(state);

    if (filteredClients.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد عملاء متاحين',
          style: TextStyle(fontSize: 18.sp),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredClients.length,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemBuilder: (context, index) {
        final client = filteredClients[index];
        return EnhancedClientCard(
          client: client,
          onTap: () => _showClientDetails(context, client),
        ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms);
      },
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.w),
          child: BlocBuilder<ClientCubit, ClientState>(
            buildWhen: (previous, current) {
              if (previous is ClientLoaded && current is ClientLoaded) {
                return previous.searchQuery != current.searchQuery;
              }
              return previous != current;
            },
            builder: (context, state) {
              return TextField(
                onChanged: (value) {
                  context.read<ClientCubit>().setSearchQuery(value);
                },
                decoration: InputDecoration(
                  hintText: 'ابحث عن عميل...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 16.w,
                  ),
                ),
              );
            },
          ),
        ),
        //  _buildFilterChips(context),
      ],
    );
  }

  void _showClientDetails(BuildContext context, Client client) {
    SoundManager().playClickSound();
    String currentStatus = client.visitStatus.name;

    void showStatusDialog() {
      SoundManager().playClickSound();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return UserStatusDialog(
            initialStatus: currentStatus,
            clientId: client.id,
            onStatusChanged: (newStatus) {
              setState(() {
                currentStatus = newStatus;
              });
              // Here you can also save to database or call an API
              log('Status changed to: $newStatus');
            },
          );
        },
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  child: Text(
                    client.name[0],
                    style: TextStyle(fontSize: 24.sp),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        client.address,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _buildDetailRow(Icons.phone, 'رقم الهاتف', client.phone ?? ""),
            _buildDetailRow(Icons.account_balance_wallet, 'رصيد الحساب', '${client.balance} ج.م'),
            _buildDetailRow(Icons.calendar_today, 'آخر عملية شراء', client.lastPurchase),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    onPressed: () => _makePhoneCall(client.phone ?? ""),
                    icon: const Icon(Icons.phone),
                    label: const Text('اتصال'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF148ccd),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    onPressed: () {
                      SoundManager().playClickSound();
                      print(
                          'Opening map for ${client.name}  ${client.latitude}, ${client.longitude}');
                      _openMap(client.latitude, client.longitude);
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('خريطة'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    onPressed: showStatusDialog,
                    icon: const Icon(Icons.account_circle_sharp),
                    label: const Text('الحالة'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                onPressed: () => _createSalesInvoice(context, client),
                icon: const Icon(Icons.receipt_long),
                label: const Text('إنشاء فاتورة مبيعات'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 16.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
