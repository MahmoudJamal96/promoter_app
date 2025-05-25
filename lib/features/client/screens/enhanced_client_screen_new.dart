import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/features/client/cubit/client_cubit_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/di/injection_container.dart';
import '../models/client_model.dart';
import '../cubit/client_state.dart';
import '../widgets/clients_map_view.dart';
import '../widgets/enhanced_client_card.dart';
import '../screens/add_client_page.dart';

class EnhancedClientScreen extends StatelessWidget {
  const EnhancedClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<ClientCubit>(),
        child: const EnhancedClientPage());
  }
}

class EnhancedClientPage extends StatefulWidget {
  const EnhancedClientPage({super.key});

  @override
  State<EnhancedClientPage> createState() => _EnhancedClientScreenState();
}

class _EnhancedClientScreenState extends State<EnhancedClientPage>
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

  void _showAddClientDialog() {
    // Navigate to the Add Client page
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AddClientPage(
          clientCubit: context.read<ClientCubit>(),
        ),
      ),
    )
        .then((v) {
      // Refresh the client list after adding a new client
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _makePhoneCall(String phoneNumber) async {
    try {
      // Clean the phone number (remove any non-digit characters except +)
      String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      final String url = "tel:$cleanedNumber";
      await launchUrlString(url);

      // if (await launchUrlString(url)) {
      //   await launchUrlString(url);
      // } else {
      //   throw 'Could not launch $url';
      // }
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
      final googleUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العملاء',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddClientDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'قائمة'),
            Tab(icon: Icon(Icons.map), text: 'خريطة'),
          ],
        ),
      ),
      body: BlocBuilder<ClientCubit, ClientState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ClientLoaded) {
            return Column(
              children: [
                _buildSearchAndFilter(context),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildListView(context, state),
                      _buildMapView(context, state),
                    ],
                  ),
                ),
              ],
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
    List<Client> result =
        state.sortedClients.isEmpty ? state.clients : state.sortedClients;

    // Apply search filter if query exists
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      result = result.where((client) {
        final name = client.name.toLowerCase();
        String phone = client.phone?.toLowerCase() ?? "";
        final address = client.address.toLowerCase();
        return name.contains(query) ||
            phone.contains(query) ||
            address.contains(query);
      }).toList();
    }

    // Apply status filter if not null (i.e., not "All")
    if (state.filterStatus != null) {
      result = result
          .where((client) => client.visitStatus == state.filterStatus)
          .toList();
    }

    return result;
  }

  Widget _buildMapView(BuildContext context, ClientLoaded state) {
    final filteredClients = _getFilteredClients(state);
    if (state.promoterPosition == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحديد موقعك...'),
          ],
        ),
      );
    }

    try {
      return ClientsMapView(
        promoterPosition: state.promoterPosition!,
        clients: filteredClients,
        onClientSelected: (client) {
          _showClientDetails(context, client);
        },
      );
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('خطأ في تحميل الخريطة: $e'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Force rebuild
                });
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
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
      padding: EdgeInsets.all(8.w),
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
        _buildFilterChips(context),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return BlocBuilder<ClientCubit, ClientState>(
      buildWhen: (previous, current) {
        if (previous is ClientLoaded && current is ClientLoaded) {
          return previous.filterStatus != current.filterStatus;
        }
        return previous != current;
      },
      builder: (context, state) {
        VisitStatus? currentFilter;
        if (state is ClientLoaded) {
          currentFilter = state.filterStatus;
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            children: [
              _buildFilterChip(
                context,
                null,
                'الكل',
                currentFilter == null,
              ),
              SizedBox(width: 8.w),
              _buildFilterChip(
                context,
                VisitStatus.notVisited,
                'لم يتم الزيارة',
                currentFilter == VisitStatus.notVisited,
              ),
              SizedBox(width: 8.w),
              _buildFilterChip(
                context,
                VisitStatus.visited,
                'تمت الزيارة',
                currentFilter == VisitStatus.visited,
              ),
              SizedBox(width: 8.w),
              _buildFilterChip(
                context,
                VisitStatus.postponed,
                'مؤجلة',
                currentFilter == VisitStatus.postponed,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    VisitStatus? status,
    String label,
    bool selected,
  ) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      onSelected: (_) {
        final cubit = context.read<ClientCubit>();
        if (status == null) {
          // Reset to "All" by explicitly setting null
          cubit.setFilterStatus(null);
        } else {
          cubit.setFilterStatus(status);
        }
      },
    );
  }

  void _showClientDetails(BuildContext context, Client client) {
    final statusOptions = {
      VisitStatus.notVisited: 'لم يتم الزيارة',
      VisitStatus.visited: 'تمت الزيارة',
      VisitStatus.postponed: 'مؤجلة',
    };

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
            _buildDetailRow(Icons.account_balance_wallet, 'رصيد الحساب',
                '${client.balance} ج.م'),
            _buildDetailRow(
                Icons.calendar_today, 'آخر عملية شراء', client.lastPurchase),
            _buildDetailRow(Icons.check_circle_outline, 'حالة الزيارة',
                statusOptions[client.visitStatus] ?? 'غير معروفة'),
            SizedBox(height: 24.h),
            Text(
              'تغيير حالة الزيارة',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusButton(
                  context,
                  client,
                  VisitStatus.notVisited,
                  Colors.grey,
                  Icons.access_time,
                  'لم يتم الزيارة',
                ),
                _buildStatusButton(
                  context,
                  client,
                  VisitStatus.visited,
                  Colors.green,
                  Icons.check_circle,
                  'تمت الزيارة',
                ),
                _buildStatusButton(
                  context,
                  client,
                  VisitStatus.postponed,
                  Colors.orange,
                  Icons.event_busy,
                  'مؤجلة',
                ),
              ],
            ),
            SizedBox(height: 16.h),
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
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    onPressed: () {
                      print(
                          'Opening map for ${client.name}  ${client.latitude}, ${client.longitude}');
                      _openMap(client.latitude, client.longitude);
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('خريطة'),
                  ),
                ),
              ],
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

  Widget _buildStatusButton(
    BuildContext context,
    Client client,
    VisitStatus status,
    Color color,
    IconData icon,
    String label,
  ) {
    final isCurrentStatus = client.visitStatus == status;
    return Column(
      children: [
        InkWell(
          onTap: isCurrentStatus
              ? null
              : () {
                  context
                      .read<ClientCubit>()
                      .updateClientStatus(client.id, status);
                  Navigator.pop(context);
                },
          child: CircleAvatar(
            radius: 24.r,
            backgroundColor: isCurrentStatus ? color : color.withOpacity(0.3),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp),
        ),
      ],
    );
  }
}
