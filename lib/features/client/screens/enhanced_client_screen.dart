// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../models/client_model.dart';
// import '../cubit/client_cubit.dart';
// import '../widgets/clients_map_view.dart';
// import '../widgets/enhanced_client_card.dart';

// class EnhancedClientScreen extends StatefulWidget {
//   const EnhancedClientScreen({super.key});

//   @override
//   State<EnhancedClientScreen> createState() => _EnhancedClientScreenState();
// }

// class _EnhancedClientScreenState extends State<EnhancedClientScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _isMapView = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _showAddClientDialog() {
//     final nameController = TextEditingController();
//     final phoneController = TextEditingController();
//     final addressController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('إضافة عميل جديد'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: nameController,
//                   decoration: const InputDecoration(
//                     labelText: 'اسم العميل',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 TextField(
//                   controller: phoneController,
//                   decoration: const InputDecoration(
//                     labelText: 'رقم الهاتف',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.phone,
//                 ),
//                 SizedBox(height: 16.h),
//                 TextField(
//                   controller: addressController,
//                   decoration: const InputDecoration(
//                     labelText: 'العنوان',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('إلغاء'),
//             ),
//             Consumer<ClientProvider>(
//               builder: (context, provider, _) => ElevatedButton(
//                 onPressed: () {
//                   if (nameController.text.isNotEmpty &&
//                       phoneController.text.isNotEmpty) {
//                     // Add new client logic - in a real app, we'd also get coordinates from the address
//                     // For mock purposes, we'll use Cairo coordinates
//                     final newClient = Client(
//                       id: provider.clients.length + 1,
//                       name: nameController.text,
//                       phone: phoneController.text,
//                       address: addressController.text,
//                       balance: 0.0,
//                       lastPurchase:
//                           '${DateTime.now().toIso8601String().split('T')[0]}',
//                       latitude: 30.0444, // Default to Cairo
//                       longitude: 31.2357,
//                     );

//                     provider.addClient(newClient);
//                   }
//                   Navigator.pop(context);
//                 },
//                 child: const Text('إضافة'),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showClientDetails(Client client) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: EdgeInsets.all(20.r),
//           height: MediaQuery.of(context).size.height * 0.6,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 50.w,
//                   height: 5.h,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20.h),
//               // Client name and status badge
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       client.name,
//                       style: TextStyle(
//                           fontSize: 24.sp, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   Container(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//                     decoration: BoxDecoration(
//                       color: client.getStatusColor().withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(20.r),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           client.getStatusIcon(),
//                           size: 16.r,
//                           color: client.getStatusColor(),
//                         ),
//                         SizedBox(width: 4.w),
//                         Text(
//                           client.getStatusText(),
//                           style: TextStyle(
//                             color: client.getStatusColor(),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20.h),

//               // Client details
//               _buildDetailItem(Icons.phone, 'رقم الهاتف:', client.phone),
//               _buildDetailItem(Icons.location_on, 'العنوان:', client.address),
//               _buildDetailItem(Icons.account_balance_wallet, 'الرصيد:',
//                   '${client.balance} ج.م'),
//               _buildDetailItem(
//                   Icons.calendar_today, 'آخر مشتريات:', client.lastPurchase),
//               _buildDetailItem(
//                   Icons.place, 'المسافة:', client.formatDistance()),
//               SizedBox(height: 30.h),

//               // Action buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   // Edit button
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       _updateClientStatus(client);
//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(Icons.edit_calendar),
//                     label: const Text('تحديث حالة الزيارة'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.amber,
//                     ),
//                   ),

//                   // Navigate button
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       _navigateToClient(client);
//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(Icons.directions),
//                     label: const Text('توجيه للعميل'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).primaryColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _updateClientStatus(Client client) {
//     final provider = Provider.of<ClientProvider>(context, listen: false);

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('تحديث حالة الزيارة'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildStatusButton(
//                 context,
//                 'تمت الزيارة',
//                 Icons.check_circle,
//                 Colors.green,
//                 () {
//                   provider.updateClientStatus(client.id, VisitStatus.visited);
//                   Navigator.pop(context);
//                 },
//               ),
//               SizedBox(height: 10.h),
//               _buildStatusButton(
//                 context,
//                 'لم تتم الزيارة',
//                 Icons.cancel,
//                 Colors.red,
//                 () {
//                   provider.updateClientStatus(
//                       client.id, VisitStatus.notVisited);
//                   Navigator.pop(context);
//                 },
//               ),
//               SizedBox(height: 10.h),
//               _buildStatusButton(
//                 context,
//                 'تم تأجيلها',
//                 Icons.access_time,
//                 Colors.orange,
//                 () {
//                   provider.updateClientStatus(client.id, VisitStatus.postponed);
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStatusButton(
//     BuildContext context,
//     String text,
//     IconData icon,
//     Color color,
//     VoidCallback onPressed,
//   ) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton.icon(
//         onPressed: onPressed,
//         icon: Icon(icon, color: Colors.white),
//         label: Text(text),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           padding: EdgeInsets.symmetric(vertical: 12.h),
//         ),
//       ),
//     );
//   }

//   void _navigateToClient(Client client) async {
//     final url =
//         'https://www.google.com/maps/dir/?api=1&destination=${client.latitude},${client.longitude}';

//     final uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } else {
//       _showErrorSnackBar('لا يمكن فتح تطبيق الخرائط');
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   Widget _buildDetailItem(IconData icon, String title, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 10.h),
//       child: Row(
//         children: [
//           Icon(icon, color: Theme.of(context).primaryColor),
//           SizedBox(width: 10.w),
//           Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
//           SizedBox(width: 5.w),
//           Text(value),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ClientProvider>(
//       builder: (context, provider, _) {
//         final isLoading = provider.isLoading;
//         final promoterPosition = provider.promoterPosition;
//         final filteredClients = provider.getFilteredClients();

//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('العملاء',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             centerTitle: true,
//             actions: [
//               // Toggle between list and map view
//               IconButton(
//                 icon: Icon(_isMapView ? Icons.list : Icons.map),
//                 onPressed: () {
//                   setState(() {
//                     _isMapView = !_isMapView;
//                   });
//                 },
//               ),
//             ],
//             bottom: PreferredSize(
//               preferredSize: Size.fromHeight(_isMapView ? 48.h : 0),
//               child: _isMapView
//                   ? TabBar(
//                       controller: _tabController,
//                       tabs: const [
//                         Tab(text: 'الخريطة'),
//                         Tab(text: 'القائمة'),
//                       ],
//                       onTap: (index) {
//                         setState(() {
//                           _isMapView = index == 0;
//                         });
//                       },
//                     )
//                   : SizedBox(),
//             ),
//           ),
//           body: isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : promoterPosition == null
//                   ? const Center(child: Text('جاري تحديد الموقع...'))
//                   : _isMapView
//                       ? _buildMapView(
//                           context, provider, promoterPosition, filteredClients)
//                       : _buildListView(context, provider, filteredClients),
//           floatingActionButton: FloatingActionButton(
//             onPressed: _showAddClientDialog,
//             child: const Icon(Icons.add),
//             tooltip: 'إضافة عميل',
//           ).animate().fade(duration: 500.ms).scale(begin: 0.5, end: 1.0),
//         );
//       },
//     );
//   }

//   Widget _buildMapView(BuildContext context, ClientProvider provider,
//       Position promoterPosition, List<Client> filteredClients) {
//     return Column(
//       children: [
//         _buildFilterChips(context, provider),
//         Expanded(
//           child: ClientsMapView(
//             clients: filteredClients,
//             promoterPosition: promoterPosition,
//             onClientSelected: _showClientDetails,
//             filterStatus: provider.filterStatus,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildListView(BuildContext context, ClientProvider provider,
//       List<Client> filteredClients) {
//     return Padding(
//       padding: EdgeInsets.all(16.r),
//       child: Column(
//         children: [
//           // Search field
//           TextField(
//             decoration: InputDecoration(
//               hintText: 'ابحث عن عميل...',
//               prefixIcon: const Icon(Icons.search),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16.r),
//               ),
//             ),
//             onChanged: (value) {
//               provider.setSearchQuery(value);
//             },
//           ).animate().fade(duration: 500.ms),

//           SizedBox(height: 16.h),

//           // Filter chips
//           _buildFilterChips(context, provider),

//           SizedBox(height: 16.h),

//           // Summary Card
//           Container(
//             padding: EdgeInsets.all(16.r),
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(16.r),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildSummaryItem(
//                     'إجمالي العملاء', provider.clients.length.toString()),
//                 _buildSummaryItem('إجمالي المديونية',
//                     '${provider.calculateTotalBalance()} ج.م'),
//               ],
//             ),
//           ).animate().fade(duration: 500.ms),

//           SizedBox(height: 16.h),

//           // Client list
//           Expanded(
//             child: filteredClients.isEmpty
//                 ? const Center(child: Text('لا يوجد عملاء مطابقين للبحث'))
//                 : ListView.builder(
//                     itemCount: filteredClients.length,
//                     itemBuilder: (context, index) {
//                       final client = filteredClients[index];
//                       return EnhancedClientCard(
//                         client: client,
//                         onTap: () => _showClientDetails(client),
//                         onNavigate: () => _navigateToClient(client),
//                       )
//                           .animate(delay: Duration(milliseconds: index * 100))
//                           .fade(duration: 300.ms);
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChips(BuildContext context, ClientProvider provider) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
//       child: Row(
//         children: [
//           _buildFilterChip(
//             label: 'الكل',
//             selected: provider.filterStatus == null,
//             onSelected: (selected) {
//               provider.setFilterStatus(null);
//             },
//             avatar: const Icon(Icons.list, size: 18),
//           ),
//           SizedBox(width: 8.w),
//           _buildFilterChip(
//             label: 'تمت الزيارة',
//             selected: provider.filterStatus == VisitStatus.visited,
//             onSelected: (selected) {
//               provider.setFilterStatus(selected ? VisitStatus.visited : null);
//             },
//             avatar:
//                 const Icon(Icons.check_circle, size: 18, color: Colors.green),
//           ),
//           SizedBox(width: 8.w),
//           _buildFilterChip(
//             label: 'لم تتم الزيارة',
//             selected: provider.filterStatus == VisitStatus.notVisited,
//             onSelected: (selected) {
//               provider
//                   .setFilterStatus(selected ? VisitStatus.notVisited : null);
//             },
//             avatar: const Icon(Icons.cancel, size: 18, color: Colors.red),
//           ),
//           SizedBox(width: 8.w),
//           _buildFilterChip(
//             label: 'تم تأجيلها',
//             selected: provider.filterStatus == VisitStatus.postponed,
//             onSelected: (selected) {
//               provider.setFilterStatus(selected ? VisitStatus.postponed : null);
//             },
//             avatar:
//                 const Icon(Icons.access_time, size: 18, color: Colors.orange),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChip({
//     required String label,
//     required bool selected,
//     required Function(bool) onSelected,
//     Widget? avatar,
//   }) {
//     return FilterChip(
//       label: Text(label),
//       selected: selected,
//       onSelected: onSelected,
//       avatar: avatar,
//       selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
//       checkmarkColor: Theme.of(context).primaryColor,
//     );
//   }

//   Widget _buildSummaryItem(String title, String value) {
//     return Column(
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 4.h),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.bold,
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//       ],
//     );
//   }
// }
