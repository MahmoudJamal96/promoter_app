import 'package:geolocator/geolocator.dart';
import 'package:promoter_app/core/data/exceptions.dart';
import 'package:promoter_app/core/data/models/parameter/name_filed.dart';
import 'package:promoter_app/core/data/models/parameter/phone_number_field.dart';
import 'package:promoter_app/core/data/models/request_model.dart';

class AddUserRequestModel extends RequestModel {
  AddUserRequestModel({
    this.warehouseId,
    this.isWarehouseUser,
    this.warehouseUserType,
    this.coveredRegions,
    this.parentProfileId,
    this.userTypeRole,
    this.profileImageUrl,
    this.coordinates,
    this.location,
    this.userTypeId,
    this.fName,
    this.lName,
    this.shopName,
    this.phone,
    this.shopImageUrl,
    this.governorateId,
    this.districtId,
    this.segmentId,
    this.enabled,
  }) : super(null);

  final List<String>? coordinates;

  /// this filed is used for operation user types
  final List<CoveredRegion>? coveredRegions;

  final String? districtId;
  final NameField? fName;
  final String? governorateId;
  final bool? isWarehouseUser;
  final NameField? lName;
  final String? parentProfileId;
  final PhoneNumberField? phone;
  final String? profileImageUrl;
  final String? segmentId;
  final String? shopImageUrl;
  final NameField? shopName;
  final String? userTypeId;
  final String? userTypeRole;
  final String? warehouseId;
  final String? warehouseUserType;
  final Position? location;
  final bool? enabled;

  @override
  List<Object?> get props => [
        fName,
        lName,
        shopName,
        phone,
        shopImageUrl,
        governorateId,
        districtId,
        segmentId,
        warehouseId,
        isWarehouseUser,
        warehouseUserType,
        location,
      ];

  @override
  Future<Map<String, dynamic>> toMap() async {
    final map = {
      "firstName": fName?.value
          .fold((l) => throw ValidationException(l.valueKey), (r) => r),
      // if (lName != null)
      "lastName": lName?.value.fold(
        (l) => ".", //throw ValidationException(l.valueKey),
        (r) => r,
      ),
      "phone": phone?.value
          .fold((l) => throw ValidationException(l.valueKey), (r) => r),
      if (shopName != null)
        "shopName": shopName?.value
            .fold((l) => throw ValidationException(l.valueKey), (r) => r),
      if (governorateId != null) "governorate": governorateId,
      if (districtId != null) "district": districtId,
      if (shopImageUrl != null) "shopImage": shopImageUrl,
      if (segmentId != null) "segment": {"id": segmentId},
      if (parentProfileId != null) "parentProfile": parentProfileId,
      if (userTypeRole != null) "userTypeRole": userTypeRole,
      if (profileImageUrl != null) "profileImageUrl": profileImageUrl,

      if (warehouseId != null) "warehouse": warehouseId,
      if (isWarehouseUser != null) "isWarehouseUser": isWarehouseUser,
      if (warehouseUserType != null) "warehouseUserType": warehouseUserType,
      if (location != null)
        "coordinates": [location!.latitude, location!.longitude],

      if (coordinates != null)
        "coordinates": coordinates?.map((e) => e).toList(),
      if (userTypeId != null) "userType": {"id": userTypeId},
      if (coveredRegions != null)
        "coveredRegion": coveredRegions?.map((e) => e.toMap()).toList(),
      if (enabled != null) "enabled": enabled,
    };
    return map;
  }
}

class CoveredRegion {
  CoveredRegion({
    required this.governorateId,
    required this.districts,
  });

  final List<String> districts;
  final String governorateId;

  Map<String, dynamic> toMap() {
    return {
      'governorate': {"id": governorateId},
      'districts': districts.map((e) => {"id": e}).toList(),
    };
  }
}
