import 'package:flutter/foundation.dart';
import 'package:erp_alianca_dev/core/security/sensitive_data_sanitizer.dart';

abstract class AppLogger {
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '[DEBUG]';
      debugPrint('$prefix $message');
    }
  }

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '[INFO]';
      debugPrint('$prefix $message');
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) {
        debugPrint('Error: ${SensitiveDataSanitizer.sanitizeForLog(error)}');
      }
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }
}
