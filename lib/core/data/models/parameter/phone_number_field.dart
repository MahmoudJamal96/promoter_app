import 'dart:developer';

import 'package:promoter_app/qara_ksa.dart';

import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class PhoneNumberField extends Equatable {
  factory PhoneNumberField(String value, IsoCode? callerCountry) =>
      PhoneNumberField._(_validatePhoneNumber(value, callerCountry));
  factory PhoneNumberField.error(ValidationFailure failure) =>
      PhoneNumberField._(Left(failure));

  const PhoneNumberField._(this.value);

  final Either<ValidationFailure, String> value;

  static Either<ValidationFailure, String> _validatePhoneNumber(
      String value, IsoCode? callerCountry) {
    bool phoneNumberValid = false;
    PhoneNumber? phone;
    String number = value;
    try {
      if (value.trim().isEmpty) {
        phoneNumberValid = false;
      } else {

        // if (!number.startsWith('+')) {
        //   number = '+$number';
        // }

        phone = PhoneNumber.parse(
          number,
          callerCountry: callerCountry ?? IsoCode.SA,
          destinationCountry: callerCountry ?? IsoCode.SA,
        );
        phoneNumberValid = phone.isValid(
          type: PhoneNumberType.mobile,
        );
      }
    } catch (e) {
      phoneNumberValid = false;
    }
    log(phone.toString());
    if (phoneNumberValid) {
      return Right('+${phone?.countryCode}${phone?.nsn ?? value}');
    }
    //return Right('+20${phone?.nsn ?? value}');

    return Left(ValidationFailure('enter_mobile_number', value));
  }

  @override
  List<Object> get props => [value];
}
