// filepath: f:\Flutter_Projects\promoter_app\lib\features\client\screens\add_client_dialog_new.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:promoter_app/core/di/injection_container.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';

import '../cubit/client_cubit_service.dart';
import '../models/location_models.dart' as loc;
import '../services/client_service.dart';

// Helper function to show the add client dialog
Future<void> showAddClientDialog(BuildContext context, ClientCubit clientCubit) async {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  final addressController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  // Get service instance
  final clientService = sl<ClientService>();

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return _AddClientDialogContent(
        context: context,
        nameController: nameController,
        phoneController: phoneController,
        codeController: codeController,
        addressController: addressController,
        latitudeController: latitudeController,
        longitudeController: longitudeController,
        clientService: clientService,
        clientCubit: clientCubit,
      );
    },
  );
}

class _AddClientDialogContent extends StatefulWidget {
  final BuildContext context;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController codeController;
  final TextEditingController addressController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final ClientService clientService;
  final ClientCubit clientCubit;

  const _AddClientDialogContent({
    required this.context,
    required this.nameController,
    required this.phoneController,
    required this.codeController,
    required this.addressController,
    required this.latitudeController,
    required this.longitudeController,
    required this.clientService,
    required this.clientCubit,
  });

  @override
  _AddClientDialogContentState createState() => _AddClientDialogContentState();
}

class _AddClientDialogContentState extends State<_AddClientDialogContent> {
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
    _loadInitialData();
    _getCurrentLocation();
  }

  // Load data from API or fallback to hardcoded data
  Future<void> _loadInitialData() async {
    setState(() {
      isLoading = true;
    });

    // Start with hardcoded data
    states = widget.clientService.getEgyptStates();
    workTypes = widget.clientService.getWorkTypes();
    responsibles = [];

    try {
      // Try to load data from API
      final apiStates = await widget.clientService.fetchStates();
      final apiWorkTypes = await widget.clientService.fetchWorkTypes();
      final apiResponsibles = await widget.clientService.fetchResponsibles();

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
      availableCities = widget.clientService.getCitiesByState(state.id);
    });

    try {
      final apiCities = await widget.clientService.fetchCitiesByState(state.id);
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
  Future<void> _getCurrentLocation() async {
    SoundManager().playClickSound();
    try {
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

      // Update the text fields
      if (mounted) {
        setState(() {
          widget.latitudeController.text = position.latitude.toStringAsFixed(6);
          widget.longitudeController.text = position.longitude.toStringAsFixed(6);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الحصول على الموقع الحالي بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الحصول على الموقع: $e')),
        );
      }
    }
  }

  // Create new client
  void _createClient() {
    SoundManager().playClickSound();
    // Validate required fields
    if (widget.nameController.text.trim().isEmpty ||
        widget.phoneController.text.trim().isEmpty ||
        widget.codeController.text.trim().isEmpty ||
        selectedState == null ||
        selectedCity == null ||
        selectedWorkType == null) {
      // Show validation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    // Validate phone number (should be numeric and at least 8 digits)
    final phoneNumber = widget.phoneController.text.trim();
    if (phoneNumber.length < 8 || !RegExp(r'^\d+$').hasMatch(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم الهاتف غير صحيح')),
      );
      return;
    } // Get the selected responsible ID or use a default value
    final responsibleId = selectedResponsible?.id ?? 1;

    // Parse and validate latitude and longitude
    double latitude = 30.0444; // Default to Cairo coordinates
    double longitude = 31.2357;

    // Validate latitude if provided
    if (widget.latitudeController.text.trim().isNotEmpty) {
      final parsedLat = double.tryParse(widget.latitudeController.text.trim());
      if (parsedLat == null || parsedLat < -90 || parsedLat > 90) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خط العرض غير صحيح (يجب أن يكون بين -90 و 90)')),
        );
        return;
      }
      latitude = parsedLat;
    }

    // Validate longitude if provided
    if (widget.longitudeController.text.trim().isNotEmpty) {
      final parsedLon = double.tryParse(widget.longitudeController.text.trim());
      if (parsedLon == null || parsedLon < -180 || parsedLon > 180) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خط الطول غير صحيح (يجب أن يكون بين -180 و 180)')),
        );
        return;
      }
      longitude = parsedLon;
    }

    // Create client with all required fields
    widget.clientService
        .createClient(
      name: widget.nameController.text,
      phone: widget.phoneController.text,
      address: widget.addressController.text,
      code: widget.codeController.text,
      stateId: selectedState!.id,
      cityId: selectedCity!.id,
      typeOfWorkId: selectedWorkType!.id,
      latitude: latitude,
      longitude: longitude,
      responsibleId: responsibleId,
      shopName: widget.nameController.text, // Assuming shop name is same as client name
    )
        .then((client) {
      // Create a complete client with all fields for display
      final completeClient = client.copyWith(
        code: widget.codeController.text,
        stateId: selectedState!.id,
        cityId: selectedCity!.id,
        typeOfWorkId: selectedWorkType!.id,
        responsibleId: responsibleId,
      );

      // Add the complete client to the cubit state
      widget.clientCubit.addClient(completeClient);

      // Show success message and close dialog
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
      child: AlertDialog(
        title: Text(
          'إضافة عميل جديد',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        content: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: widget.nameController,
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
                      controller: widget.phoneController,
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
                    TextField(
                      controller: widget.codeController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'كود العميل',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        alignLabelWithHint: true,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: widget.addressController,
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
                    TextField(
                      controller: widget.latitudeController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'خط العرض (Latitude)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        alignLabelWithHint: true,
                        hintText: 'مثال: 30.0444',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 16.h),
                    // Longitude input field
                    TextField(
                      controller: widget.longitudeController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'خط الطول (Longitude)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        alignLabelWithHint: true,
                        hintText: 'مثال: 31.2357',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 16.h),
                    // Location helper button
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.my_location),
                            label: const Text('الحصول على الموقع الحالي'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // State dropdown
                    DropdownButtonFormField<loc.State>(
                      decoration: const InputDecoration(
                        labelText: 'المحافظة',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      value: selectedState,
                      hint: const Text('اختر المحافظة'),
                      isExpanded: true,
                      items: states.map((state) {
                        return DropdownMenuItem<loc.State>(
                          value: state,
                          child: Text(state.name),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          _updateCities(newValue);
                        }
                      },
                    ),
                    SizedBox(height: 16.h),
                    // City dropdown
                    DropdownButtonFormField<loc.City>(
                      decoration: const InputDecoration(
                        labelText: 'المدينة',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      value: selectedCity,
                      hint: const Text('اختر المدينة'),
                      isExpanded: true,
                      items: availableCities.map((city) {
                        return DropdownMenuItem<loc.City>(
                          value: city,
                          child: Text(city.name),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedCity = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 16.h),
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
                    SizedBox(height: 16.h),
                    // Responsible person dropdown
                    DropdownButtonFormField<loc.Responsible>(
                      decoration: const InputDecoration(
                        labelText: 'المسؤول',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      value: selectedResponsible,
                      hint: const Text('اختر المسؤول'),
                      isExpanded: true,
                      items: responsibles.map((person) {
                        return DropdownMenuItem<loc.Responsible>(
                          value: person,
                          child: Text(person.name),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedResponsible = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
        actions: [
          TextButton(
            onPressed: () {
              SoundManager().playClickSound();
              Navigator.of(context).pop();
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _createClient,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF148ccd)),
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
