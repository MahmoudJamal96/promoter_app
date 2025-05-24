// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:promoter_app/core/di/injection_container.dart';

// import '../models/client_model.dart';
// import '../models/location_models.dart' as loc;
// import '../services/client_service.dart';
// import '../cubit/client_cubit_service.dart';

// // Helper function to show the add client dialog
// Future<void> showAddClientDialog(
//     BuildContext context, ClientCubit clientCubit) async {
//   final nameController = TextEditingController();
//   final phoneController = TextEditingController();
//   final codeController = TextEditingController();
//   final addressController = TextEditingController();

//   // Get service instance
//   final clientService = sl<ClientService>();
  
//   // Initialize with hardcoded data, will be replaced with API data
//   List<loc.State> states = clientService.getEgyptStates();
//   List<loc.WorkType> workTypes = clientService.getWorkTypes();
//   List<loc.Responsible> responsibles = [];
  
//   // State management
//   loc.State? selectedState;
//   loc.City? selectedCity;
//   loc.WorkType? selectedWorkType;
//   loc.Responsible? selectedResponsible;
//   List<loc.City> availableCities = [];
  
//   // Fetch fresh data from API
//   try {
//     states = await clientService.fetchStates();
//     workTypes = await clientService.fetchWorkTypes();
//     responsibles = await clientService.fetchResponsibles();
//   } catch (e) {
//     print('Error fetching data from API: $e');
//     // Continue with hardcoded data
//   }

//   return showDialog<void>(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return StatefulBuilder(
//         builder: (context, setState) {          // Update cities when state changes
//           if (selectedState != null && availableCities.isEmpty) {
//             // Immediately use local data
//             availableCities = clientService.getCitiesByState(selectedState!.id);
            
//             // Then try to fetch from API (will update UI when complete)
//             clientService.fetchCitiesByState(selectedState!.id).then((cities) {
//               if (cities.isNotEmpty) {
//                 setState(() {
//                   availableCities = cities;
//                 });
//               }
//             }).catchError((e) {
//               print('Error fetching cities: $e');
//             });
//           }

//           return Directionality(
//             textDirection: TextDirection.rtl,
//             child: AlertDialog(
//               title: Text(
//                 'إضافة عميل جديد',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20.sp,
//                 ),
//               ),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: nameController,
//                       textAlign: TextAlign.right,
//                       decoration: const InputDecoration(
//                         labelText: 'اسم العميل',
//                         border: OutlineInputBorder(),
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         alignLabelWithHint: true,
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                     TextField(
//                       controller: phoneController,
//                       textAlign: TextAlign.right,
//                       decoration: const InputDecoration(
//                         labelText: 'رقم الهاتف',
//                         border: OutlineInputBorder(),
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         alignLabelWithHint: true,
//                       ),
//                       keyboardType: TextInputType.phone,
//                     ),
//                     SizedBox(height: 16.h),
//                     TextField(
//                       controller: codeController,
//                       textAlign: TextAlign.right,
//                       decoration: const InputDecoration(
//                         labelText: 'كود العميل',
//                         border: OutlineInputBorder(),
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         alignLabelWithHint: true,
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                     TextField(
//                       controller: addressController,
//                       textAlign: TextAlign.right,
//                       decoration: const InputDecoration(
//                         labelText: 'العنوان',
//                         border: OutlineInputBorder(),
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         alignLabelWithHint: true,
//                       ),
//                       maxLines: 2,
//                     ),
//                     SizedBox(height: 16.h),
//                     // State dropdown
//                     DropdownButtonFormField<loc.State>(
//                       decoration: const InputDecoration(
//                         labelText: 'المحافظة',
//                         border: OutlineInputBorder(),
//                         alignLabelWithHint: true,
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       ),
//                       value: selectedState,
//                       hint: const Text('اختر المحافظة'),
//                       isExpanded: true,
//                       items: states.map((state) {
//                         return DropdownMenuItem<loc.State>(
//                           value: state,
//                           child: Text(state.name),
//                         );
//                       }).toList(),                      onChanged: (newValue) {
//                         if (newValue != null) {
//                           setState(() {
//                             selectedState = newValue;
//                             selectedCity = null;
//                             // First use local data for immediate response
//                             availableCities =
//                                 clientService.getCitiesByState(newValue.id);
//                           });
                          
//                           // Then fetch from API and update when data is available
//                           clientService.fetchCitiesByState(newValue.id).then((cities) {
//                           if (cities.isNotEmpty) {
//                             setState(() {
//                               availableCities = cities;
//                             });
//                           }
//                         }).catchError((e) {
//                           print('Error fetching cities: $e');
//                         });
//                     )
//                       },
//                     ),
//                     SizedBox(height: 16.h),
//                     // City dropdown
//                     DropdownButtonFormField<loc.City>(
//                       decoration: const InputDecoration(
//                         labelText: 'المدينة',
//                         border: OutlineInputBorder(),
//                         alignLabelWithHint: true,
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       ),
//                       value: selectedCity,
//                       hint: const Text('اختر المدينة'),
//                       isExpanded: true,
//                       items: availableCities.map((city) {
//                         return DropdownMenuItem<loc.City>(
//                           value: city,
//                           child: Text(city.name),
//                         );
//                       }).toList(),
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedCity = newValue;
//                         });
//                       },
//                     ),
//                     SizedBox(height: 16.h),                    // Work type dropdown
//                     DropdownButtonFormField<loc.WorkType>(
//                       decoration: const InputDecoration(
//                         labelText: 'نوع النشاط',
//                         border: OutlineInputBorder(),
//                         alignLabelWithHint: true,
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       ),
//                       value: selectedWorkType,
//                       hint: const Text('اختر نوع النشاط'),
//                       isExpanded: true,
//                       items: workTypes.map((type) {
//                         return DropdownMenuItem<loc.WorkType>(
//                           value: type,
//                           child: Text(type.name),
//                         );
//                       }).toList(),
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedWorkType = newValue;
//                         });
//                       },
//                     ),
//                     SizedBox(height: 16.h),
//                     // Responsible person dropdown
//                     DropdownButtonFormField<loc.Responsible>(
//                       decoration: const InputDecoration(
//                         labelText: 'المسؤول',
//                         border: OutlineInputBorder(),
//                         alignLabelWithHint: true,
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       ),
//                       value: selectedResponsible,
//                       hint: const Text('اختر المسؤول'),
//                       isExpanded: true,
//                       items: responsibles.map((person) {
//                         return DropdownMenuItem<loc.Responsible>(
//                           value: person,
//                           child: Text(person.name),
//                         );
//                       }).toList(),
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedResponsible = newValue;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text('إلغاء'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (nameController.text.isNotEmpty &&
//                         phoneController.text.isNotEmpty &&
//                         codeController.text.isNotEmpty &&
//                         selectedState != null &&
//                         selectedCity != null &&
//                         selectedWorkType != null) {
//                       // Create client with all required fields
//                       clientService
//                           .createClient(
//                         name: nameController.text,
//                         phone: phoneController.text,
//                         address: addressController.text,
//                         code: codeController.text,
//                         stateId: selectedState!.id,
//                         cityId: selectedCity!.id,
//                         typeOfWorkId: selectedWorkType!.id,
//                         latitude: 30.0444, // Default to Cairo coordinates
//                         longitude: 31.2357,
//                         responsibleId:
//                             1, // Default value, can be customized later
//                       )
//                           .then((client) {
//                         // Create a complete client with all fields for display
//                         final completeClient = client.copyWith(
//                           code: codeController.text,
//                           stateId: selectedState!.id,
//                           cityId: selectedCity!.id,
//                           typeOfWorkId: selectedWorkType!.id,
//                           responsibleId: 1,
//                         ); // Add the complete client to the cubit state
//                         clientCubit.addClient(completeClient);

//                         // Show success message and close dialog
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                               content: Text('تم إضافة العميل بنجاح')),
//                         );
//                         Navigator.of(context).pop();
//                       }).catchError((error) {
//                         // Show error message
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content: Text(
//                                   'خطأ في إضافة العميل: ${error.toString()}')),
//                         );
//                       });
//                     } else {
//                       // Show validation message
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                             content: Text('يرجى ملء جميع الحقول المطلوبة')),
//                       );
//                     }
//                   },
//                   child: const Text('إضافة'),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }
