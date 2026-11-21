// lib/core/errors/error_handler.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'app_exception.dart';

class ErrorHandler {
  ErrorHandler._();

  /// Formatted console logger with timestamps for reliable debugging.
  static void log(Object error, StackTrace? stackTrace) {
    debugPrint('----------------------------------------');
    debugPrint('[ERROR REPORT] - ${DateTime.now().toUtc()}');
    debugPrint('Type: ${error.runtimeType}');
    debugPrint('Details: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace:\n$stackTrace');
    }
    debugPrint('----------------------------------------');
  }

  /// Map raw developer errors into soft, understandable messages.
  static String getReadableMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    if (error is TimeoutException) {
      return 'The connection is taking too long. Please check your network stability.';
    }
    return 'Something unexpected occurred, but we have captured the issue and are resolving it.';
  }

  /// Instantly renders a floating error indicator anywhere on the active screen.
  static void showErrorSnackbar(BuildContext context, Object error) {
    final message = getReadableMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.redAccent.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}