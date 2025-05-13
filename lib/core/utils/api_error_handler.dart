import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';

class ApiErrorHandler {
  /// Display an error message to the user based on the exception type
  static void showErrorSnackBar(BuildContext context, Exception error) {
    final errorMessage = _getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Get a user-friendly error message based on the exception type
  static String _getErrorMessage(Exception error) {
    if (error is UnauthorizedException) {
      return 'جلسة المستخدم منتهية. يرجى تسجيل الدخول مرة أخرى.';
    } else if (error is NotFoundException) {
      return 'لم يتم العثور على المورد المطلوب.';
    } else if (error is ServerException) {
      return 'حدث خطأ في الخادم. يرجى المحاولة لاحقاً.';
    } else if (error is NoInternetConnectionException) {
      return 'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى.';
    } else if (error is TimeoutException) {
      return 'استغرق الطلب وقتًا طويلاً. يرجى المحاولة مرة أخرى.';
    } else if (error is RequestCancelledException) {
      return 'تم إلغاء الطلب.';
    } else if (error is ApiException) {
      return (error as ApiException).message;
    } else {
      return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
    }
  }

  /// Wrap API calls with error handling
  static Future<T> call<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on UnauthorizedException {
      // Handle authentication errors - could navigate to login screen
      rethrow;
    } on Exception catch (e) {
      // Log all other exceptions
      print('API Error: $e');
      rethrow;
    }
  }
}
