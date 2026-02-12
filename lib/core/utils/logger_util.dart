import 'package:flutter/foundation.dart';

/// Simple logging utility for printer operations.
class LoggerUtil {
  LoggerUtil._();

  static void log(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[BluetoothPrinter] $message');
      if (error != null) {
        debugPrint('[BluetoothPrinter] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[BluetoothPrinter] StackTrace: $stackTrace');
      }
    }
  }
}
