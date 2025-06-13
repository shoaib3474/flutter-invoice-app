import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static void handleError(dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }

    // Log to crash reporting service in production
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  static String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  static bool isNetworkError(dynamic error) {
    return error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException') ||
        error.toString().contains('HandshakeException');
  }

  static bool isAuthError(dynamic error) {
    return error.toString().contains('auth') ||
        error.toString().contains('unauthorized') ||
        error.toString().contains('permission');
  }

  static void logError(String s, Object e) {}

  static void showError(BuildContext context, String s, Object e) {}
}
