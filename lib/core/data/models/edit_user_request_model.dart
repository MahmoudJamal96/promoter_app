import 'package:geolocator/geolocator.dart';
import 'package:promoter_app/core/data/models/parameter/name_filed.dart';
import 'package:promoter_app/core/data/models/parameter/phone_number_field.dart';
import 'package:promoter_app/core/data/models/request_model.dart';

import '../exceptions.dart';
import 'add_user_model.dart';

class EditUserRequestModel extends RequestModel {
  final String? id;
  final NameField? fName;
  final NameField? lName;
  final NameField? shopName;
  final bool isEnabled;
  final PhoneNumberField? phone;
  final String? governorateId;
  final String? governorateName;
  final String? segmentId;
  final String? segmentName;
  final String? districtId;
  final String? districtName;
  final String? whyDisabled;
  final String? disableComment;
  final Position? location;
  final String? userTypeId;

  final List<CoveredRegion>? coveredRegions;
  final String? userTypeRole;

  EditUserRequestModel({
    this.governorateId,
    this.governorateName,
    this.districtName,
    this.segmentId,
    this.coveredRegions,
    this.userTypeRole,
    this.segmentName,
    this.userTypeId,
    this.districtId,
    this.whyDisabled,
    this.disableComment,
    this.phone,
    this.isEnabled = true,
    this.id,
    this.fName,
    this.lName,
    this.location,
    this.shopName,
  }) : super(null);

  @override
  List<Object?> get props => [
        location,
      ];

  @override
  Future<Map<String, dynamic>> toMap() async => {
        if (fName != null)
          "firstName": fName?.value
              .fold((l) => throw ValidationException(l.valueKey), (r) => r),
        if (lName != null)
          "lastName": lName?.value
              .fold((l) => throw ValidationException(l.valueKey), (r) => r),
      if (shopName != null)
          "shopName": shopName?.value
              .fold((l) => throw ValidationException(l.valueKey), (r) => r),
        if (governorateId != null) "governorate": governorateId,
        if (districtId != null) "district": districtId,
        if (segmentId != null)
          "segment": {
            "id": segmentId,
            if (segmentName != null) "name": segmentName
          },
        if (userTypeRole != null) "userTypeRole": userTypeRole,
        if (whyDisabled != null) "whyDesabled": whyDisabled,
        if (disableComment != null) "holdComment": disableComment,
        "enabled": isEnabled,
        if (phone != null)
          "phone": phone?.value
              .fold((l) => throw ValidationException(l.valueKey), (r) => r),
        if (location != null)
          "coordinates": [location!.latitude, location!.longitude],
        if (coveredRegions != null)
          "coveredRegion": coveredRegions?.map((e) => e.toMap()).toList()
      };

  EditUserRequestModel fromUserModel(
      AddUserRequestModel model, bool isEnabled, String id) {
    return EditUserRequestModel(
      fName: model.fName,
      lName: model.lName,
      phone: model.phone,
      isEnabled: isEnabled,
      id: id,
      governorateId: model.governorateId,
      segmentId: model.segmentId,
      districtId: model.districtId,
    );
  }

  // copy with
  EditUserRequestModel copyWith(
      {NameField? fName,
      NameField? lName,
      PhoneNumberField? phone,
      String? governorateId,
      String? segmentId,
      String? districtId,
      String? whyDisabled,
      bool? isEnabled}) {
    return EditUserRequestModel(
      fName: fName ?? this.fName,
      lName: lName ?? this.lName,
      phone: phone ?? this.phone,
      governorateId: governorateId ?? this.governorateId,
      segmentId: segmentId ?? this.segmentId,
      districtId: districtId ?? this.districtId,
      whyDisabled: whyDisabled ?? this.whyDisabled,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
