import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:promoter_app/core/di/injection_container.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';

import '../cubit/client_cubit_service.dart';
import '../models/location_models.dart' as loc;
import '../services/client_service.dart';

class AddClientPage extends StatefulWidget {
  final ClientCubit clientCubit;

  const AddClientPage({
    super.key,
    required this.clientCubit,
  });

  @override
  State<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  // Text controllers
  final nameController = TextEditingController();
  final marketNameController = TextEditingController();
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  // Service instance
  late final ClientService clientService;

  // State management
  loc.State? selectedState;
  loc.City? selectedCity;
  loc.WorkType? selectedWorkType;
  loc.Responsible? selectedResponsible;
  List<loc.City> availableCities = [];

  // Data collections
  List<loc.State> states = [];
  List<loc.WorkType> workTypes = [];
  List<loc.Responsible> responsibles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    clientService = sl<ClientService>();
    _loadInitialData();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    codeController.dispose();
    locationNameController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  // Load data from API or fallback to hardcoded data
  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
    });

    // Start with hardcoded data
    states = clientService.getEgyptStates();
    workTypes = clientService.getWorkTypes();
    responsibles = [];

    try {
      // Try to load data from API
      final apiStates = await clientService.fetchStates();
      final apiWorkTypes = await clientService.fetchWorkTypes();
      final apiResponsibles = await clientService.fetchResponsibles();

      // Update state with API data if available
      if (apiStates.isNotEmpty) {
        states = apiStates;
      }

      if (apiWorkTypes.isNotEmpty) {
        workTypes = apiWorkTypes;
      }

      if (apiResponsibles.isNotEmpty) {
        responsibles = apiResponsibles;
      }
    } catch (e) {
      // Continue with hardcoded data if API fails
      debugPrint('Error loading data from API: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Update cities when state changes
  void _updateCities(loc.State state) async {
    setState(() {
      selectedState = state;
      selectedCity = null;
      availableCities = clientService.getCitiesByState(state.id);
    });

    try {
      final apiCities = await clientService.fetchCitiesByState(state.id);
      if (apiCities.isNotEmpty && mounted) {
        setState(() {
          availableCities = apiCities;
        });
      }
    } catch (e) {
      debugPrint('Error fetching cities: $e');
    }
  }

  // Get current location
  final TextEditingController locationNameController = TextEditingController();

  void _getCurrentLocation(BuildContext context) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري الحصول على الموقع...')),
      );

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خدمات الموقع غير مفعلة')),
        );
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفض إذن الوصول للموقع')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('إذن الوصول للموقع مرفوض نهائياً')),
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates (Reverse Geocoding)
      String locationName = await _getAddressFromCoordinates(position.latitude, position.longitude);

      // Update the text fields
      setState(() {
        latitudeController.text = position.latitude.toStringAsFixed(6);
        longitudeController.text = position.longitude.toStringAsFixed(6);
        locationNameController.text = locationName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الحصول على الموقع والعنوان بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الحصول على الموقع: $e')),
      );
    }
  }

  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        // Build address string
        List<String> addressParts = [];

        if (placemark.street != null && placemark.street!.isNotEmpty) {
          addressParts.add(placemark.street!);
        }
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          addressParts.add(placemark.subLocality!);
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressParts.add(placemark.locality!);
        }
        if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
          addressParts.add(placemark.administrativeArea!);
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          addressParts.add(placemark.country!);
        }

        return addressParts.join(', ');
      }

      return 'لم يتم العثور على العنوان';
    } catch (e) {
      return 'خطأ في الحصول على العنوان: $e';
    }
  }

  // Alternative method to get specific address components
  Future<Map<String, String>> _getDetailedAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        return {
          'street': placemark.street ?? '',
          'subLocality': placemark.subLocality ?? '',
          'locality': placemark.locality ?? '',
          'administrativeArea': placemark.administrativeArea ?? '',
          'country': placemark.country ?? '',
          'postalCode': placemark.postalCode ?? '',
          'name': placemark.name ?? '',
          'thoroughfare': placemark.thoroughfare ?? '',
          'subThoroughfare': placemark.subThoroughfare ?? '',
        };
      }

      return {};
    } catch (e) {
      return {'error': 'خطأ في الحصول على تفاصيل العنوان: $e'};
    }
  }

  // Method to get location name from coordinates without getting current location
  Future<void> getLocationNameFromCoordinates(
      BuildContext context, double latitude, double longitude) async {
    try {
      String locationName = await _getAddressFromCoordinates(latitude, longitude);

      setState(() {
        locationNameController.text = locationName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الحصول على اسم المكان بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الحصول على اسم المكان: $e')),
      );
    }
  }

  // Create new client
  void _createClient() {
    SoundManager().playClickSound();
    // Validate required fields
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        locationNameController.text.trim().isEmpty ||
        marketNameController.text.trim().isEmpty ||
        selectedWorkType == null) {
      // Show validation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    // Validate phone number (should be numeric and at least 8 digits)
    final phoneNumber = phoneController.text.trim();
    if (phoneNumber.length < 8 || !RegExp(r'^\d+$').hasMatch(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم الهاتف غير صحيح')),
      );
      return;
    }

    // Parse and validate latitude and longitude
    double latitude = 30.0444; // Default to Cairo coordinates
    double longitude = 31.2357;

    // Validate latitude if provided
    if (latitudeController.text.trim().isNotEmpty) {
      final parsedLat = double.tryParse(latitudeController.text.trim());
      if (parsedLat == null || parsedLat < -90 || parsedLat > 90) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خط العرض غير صحيح (يجب أن يكون بين -90 و 90)')),
        );
        return;
      }
      latitude = parsedLat;
    }

    // Validate longitude if provided
    if (longitudeController.text.trim().isNotEmpty) {
      final parsedLon = double.tryParse(longitudeController.text.trim());
      if (parsedLon == null || parsedLon < -180 || parsedLon > 180) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خط الطول غير صحيح (يجب أن يكون بين -180 و 180)')),
        );
        return;
      }
      longitude = parsedLon;
    }

    // Get the selected responsible ID or use a default value
    final responsibleId = selectedResponsible?.id ?? 1;

    // Create client with all required fields
    clientService
        .createClient(
            name: nameController.text,
            phone: phoneController.text,
            address: locationNameController.text,
            code: codeController.text,
            stateId: 1,
            cityId: 1,
            typeOfWorkId: selectedWorkType!.id,
            latitude: latitude,
            longitude: longitude,
            responsibleId: responsibleId,
            shopName: marketNameController.text.trim())
        .then((client) {
      // // Add the complete client to the cubit state
      // widget.clientCubit.addClient(completeClient);

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة العميل بنجاح')),
      );
      Navigator.of(context).pop();
    }).catchError((error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في إضافة العميل: ${error.toString()}')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF148ccd),
          title: const Text(
            'إضافة عميل جديد',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Client name field
                    TextField(
                      controller: nameController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'اسم العميل',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        alignLabelWithHint: true,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: marketNameController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'اسم الماركت',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        alignLabelWithHint: true,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Phone number field
                    TextField(
                      controller: phoneController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        alignLabelWithHint: true,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16.h),

                    // Client code field
                    // TextField(
                    //   controller: codeController,
                    //   textAlign: TextAlign.right,
                    //   decoration: const InputDecoration(
                    //     labelText: 'كود العميل',
                    //     border: OutlineInputBorder(),
                    //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    //     alignLabelWithHint: true,
                    //   ),
                    // ),
                    // SizedBox(height: 16.h),

                    // Address field
                    TextField(
                      controller: locationNameController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'العنوان',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 16.h),

                    // Latitude input field
                    // TextField(
                    //   controller: latitudeController,
                    //   textAlign: TextAlign.right,
                    //   decoration: const InputDecoration(
                    //     labelText: 'خط العرض (Latitude)',
                    //     border: OutlineInputBorder(),
                    //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    //     alignLabelWithHint: true,
                    //     hintText: 'مثال: 30.0444',
                    //   ),
                    //   keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    // ),
                    // SizedBox(height: 16.h),

                    // // Longitude input field
                    // TextField(
                    //   controller: longitudeController,
                    //   textAlign: TextAlign.right,
                    //   decoration: const InputDecoration(
                    //     labelText: 'خط الطول (Longitude)',
                    //     border: OutlineInputBorder(),
                    //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    //     alignLabelWithHint: true,
                    //     hintText: 'مثال: 31.2357',
                    //   ),
                    //   keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    // ),
                    // SizedBox(height: 16.h),

                    // Location helper button
                    OutlinedButton.icon(
                      onPressed: () {
                        SoundManager().playClickSound();
                        _getCurrentLocation(context);
                      },
                      icon: const Icon(Icons.my_location),
                      label: const Text('الحصول على الموقع الحالي'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // State dropdown
                    // DropdownButtonFormField<loc.State>(
                    //   decoration: const InputDecoration(
                    //     labelText: 'المحافظة',
                    //     border: OutlineInputBorder(),
                    //     alignLabelWithHint: true,
                    //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    //   ),
                    //   value: selectedState,
                    //   hint: const Text('اختر المحافظة'),
                    //   isExpanded: true,
                    //   items: states.map((state) {
                    //     return DropdownMenuItem<loc.State>(
                    //       value: state,
                    //       child: Text(state.name),
                    //     );
                    //   }).toList(),
                    //   onChanged: (newValue) {
                    //     if (newValue != null) {
                    //       _updateCities(newValue);
                    //     }
                    //   },
                    // ),
                    // SizedBox(height: 16.h),

                    // // City dropdown
                    // DropdownButtonFormField<loc.City>(
                    //   decoration: const InputDecoration(
                    //     labelText: 'المدينة',
                    //     border: OutlineInputBorder(),
                    //     alignLabelWithHint: true,
                    //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    //   ),
                    //   value: selectedCity,
                    //   hint: const Text('اختر المدينة'),
                    //   isExpanded: true,
                    //   items: availableCities.map((city) {
                    //     return DropdownMenuItem<loc.City>(
                    //       value: city,
                    //       child: Text(city.name),
                    //     );
                    //   }).toList(),
                    //   onChanged: (newValue) {
                    //     setState(() {
                    //       selectedCity = newValue;
                    //     });
                    //   },
                    // ),
                    // SizedBox(height: 16.h),

                    // Work type dropdown
                    DropdownButtonFormField<loc.WorkType>(
                      decoration: const InputDecoration(
                        labelText: 'مجموعة العملاء',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      value: selectedWorkType,
                      hint: const Text('اختر مجموعة العملاء'),
                      isExpanded: true,
                      items: workTypes.map((type) {
                        return DropdownMenuItem<loc.WorkType>(
                          value: type,
                          child: Text(type.name),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedWorkType = newValue;
                        });
                      },
                    ),
                    // SizedBox(height: 16.h),

                    // // Responsible person dropdown
                    // DropdownButtonFormField<loc.Responsible>(
                    //   decoration: const InputDecoration(
                    //     labelText: 'المسؤول',
                    //     border: OutlineInputBorder(),
                    //     alignLabelWithHint: true,
                    //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    //   ),
                    //   value: selectedResponsible,
                    //   hint: const Text('اختر المسؤول'),
                    //   isExpanded: true,
                    //   items: responsibles.map((person) {
                    //     return DropdownMenuItem<loc.Responsible>(
                    //       value: person,
                    //       child: Text(person.name),
                    //     );
                    //   }).toList(),
                    //   onChanged: (newValue) {
                    //     setState(() {
                    //       selectedResponsible = newValue;
                    //     });
                    //   },
                    // ),
                    SizedBox(height: 32.h),

                    // Save button
                    ElevatedButton(
                      onPressed: _createClient,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        textStyle: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: const Color(0xFF148ccd),
                      ),
                      child: const Text('إضافة العميل'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
