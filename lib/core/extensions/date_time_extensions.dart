import 'package:intl/intl.dart';

const languageCode = 'en-us';
extension DateTimeExtended on DateTime {
  static DateTime fromSecondsSinceEpoch(int secondsSinceEpoch) {
    return DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000);
  }
  //   String? get languageCode => di<PreferencesCubit>().state.language;
  String toFormattedStringEEEdd() => DateFormat('EEE dd,', languageCode).add_jm().format(toLocal());

  String toFormattedStringdMMMy() => DateFormat('d MMMM y', languageCode).format(toLocal());

//data

  String toddMMyyyy() => DateFormat( 'yyyy-MM-dd', languageCode).format(toLocal());

  String toddMMyyyySlashes() => DateFormat('dd/MM/yyyy', languageCode).format(toLocal());

  String toDateTimeSlashes() => DateFormat('dd/MM/yyyy - hh:mm a', languageCode).format(toLocal());
  String toDateSlashes() => DateFormat('dd/MM/yyyy', languageCode).format(toLocal());

  String toMonthYear() => DateFormat('yyyy MMM', languageCode).format(toLocal());

  String toYearLocale() => DateFormat('yyyy', languageCode).format(toLocal());

  String toMonthLocale() => DateFormat('MMM', languageCode).format(toLocal());

  String toddMMyyyyNamed() => DateFormat('EEE, d MMM', languageCode).format(toLocal());
  String toddMMNamed() => DateFormat('EEE, d', languageCode).format(toLocal());

  String tohhmm() => DateFormat('hh:mm', languageCode).format(toLocal());

  String tohhmmSystem12() => DateFormat('hh:mm a', languageCode).format(toLocal());

  String specialFormatting({required String formatter, String? locale}) {
    return DateFormat(formatter, languageCode).format(toLocal());
  }

//View
  String toFormattedStringMMMMY() => DateFormat('d MMM y', languageCode).format(toLocal());

  String toAuctionStartFormatString() =>
      DateFormat('EEE, MMMM d, y', languageCode).add_jm().format(toLocal());

  String toMarketPlaceFormatFormatString() =>
      DateFormat('d MMMM،', languageCode).add_jm().format(toLocal());

  String toUtcFormmatedString() => DateFormat('yyyy-MM-dd HH:mm:ss', languageCode).format(toUtc());

  DateTime toMidnight(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  bool isWeekend() {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  bool isToday() {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }

  bool isPastDay() {
    final today = toMidnight(DateTime.now());
    return isBefore(today);
  }

  DateTime addDaysToDate(int days) {
    DateTime newDate = add(Duration(days: days));

    if (hour != newDate.hour) {
      final hoursDifference = hour - newDate.hour;

      if (hoursDifference <= 3 && hoursDifference >= -3) {
        newDate = newDate.add(Duration(hours: hoursDifference));
      } else if (hoursDifference <= -21) {
        newDate = newDate.add(Duration(hours: 24 + hoursDifference));
      } else if (hoursDifference >= 21) {
        newDate = newDate.add(Duration(hours: hoursDifference - 24));
      }
    }
    return newDate;
  }

  bool isSpecialPastDay() {
    return isPastDay() || (isToday() && DateTime.now().hour >= 12);
  }

  DateTime getFirstDayOfNextMonth() {
    var dateTime = getFirstDayOfMonth();
    dateTime = addDaysToDate(31);
    dateTime = getFirstDayOfMonth();
    return dateTime;
  }

  DateTime getFirstDayOfMonth() {
    return DateTime(year, month);
  }

  DateTime getLastDayOfMonth() {
    final firstDayOfMonth = DateTime(year, month);
    final nextMonth = firstDayOfMonth.add(const Duration(days: 32));
    final firstDayOfNextMonth = DateTime(nextMonth.year, nextMonth.month);
    return firstDayOfNextMonth.subtract(const Duration(days: 1));
  }

  bool isSameDay(DateTime date2) {
    return day == date2.day && month == date2.month && year == date2.year;
  }

  bool isCurrentMonth() {
    final now = DateTime.now();
    return month == now.month && year == now.year;
  }

  int calculateMonthsDifference(DateTime endDate) {
    final yearsDifference = endDate.year - year;
    return 12 * yearsDifference + endDate.month - month;
  }

  int calculateWeeksNumber(DateTime monthEndDate) {
    int rowsNumber = 1;

    DateTime currentDay = this;
    while (currentDay.isBefore(monthEndDate)) {
      currentDay = currentDay.add(const Duration(days: 1));
      if (currentDay.weekday == DateTime.monday) {
        rowsNumber += 1;
      }
    }

    return rowsNumber;
  }
}
extension MinusFormatter on String {
  String moveMinusToEnd() {
    if (startsWith('-')) {
      return substring(1) + '-'; // Move the minus sign to the end
    }
    return this;
  }
}

extension PhoneFormatter on String {

  String formatPhoneNumber() {
    final phoneNumberFormat = NumberFormat('+# ##########', languageCode);
    return phoneNumberFormat.format(int.parse(this));
  }
  String formatToLocale({bool isBalance = false}) {
    if (isEmpty) {
      return this;
    }

    final double? value = double.tryParse(this);
    if (value == null) {
      return this;
    }

    final format = NumberFormat.decimalPattern(languageCode);

    String formattedValue = format.format(value);

    if (isBalance) {
      formattedValue = formattedValue.replaceAll("٫", "."); // Replace Arabic decimal with standard dot
      formattedValue = formattedValue.replaceAll("٬", ","); // Ensure thousand separators are commas
      if (!formattedValue.contains(".")) {
        formattedValue = "$formattedValue.00";
      }
    }
    else {
      formattedValue = formattedValue.replaceAll("٫", ""); //fractions
      formattedValue = formattedValue.replaceAll("٬", "");
      formattedValue = formattedValue.replaceAll(",", "");
    }

    return formattedValue;
  }
  String formatToEnglish() {
    Map<String, String> arabicToEnglishNumbers = {
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    };

    String result = '';

    for (int i = 0; i < length; i++) {
      String currentChar = this[i];
      result += arabicToEnglishNumbers[currentChar] ?? currentChar;
    }
    return result;
  }
}
