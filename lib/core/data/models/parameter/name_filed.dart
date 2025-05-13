import 'package:promoter_app/qara_ksa.dart';

class NameField extends Equatable {
  factory NameField(String value) => NameField._(_validatePhoneNumber(value));
  factory NameField.error(ValidationFailure failure) =>
      NameField._(Left(failure));

  const NameField._(this.value);

  final Either<ValidationFailure, String> value;

  static Either<ValidationFailure, String> _validatePhoneNumber(String value) {
    bool nameValid = false;
    try {
      if ((value.trim().isEmpty || value.length > 32 || value.length < 2) ||
          !RegExp(r'[\p{L}A-Za-z\u0600-\u06FF\u0750-\u077F]+')
              .hasMatch(value.toLowerCase().trim())) {
        nameValid = false;
      } else {
        nameValid = true;
      }
    } catch (e) {
      nameValid = false;
    }

    if (nameValid) return Right(value);

    return Left(ValidationFailure('enter_name', value));
  }

  @override
  List<Object> get props => [value];
}
