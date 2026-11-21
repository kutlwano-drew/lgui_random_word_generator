// lib/core/errors/app_exception.dart

import 'package:flutter/foundation.dart';

@immutable
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => '[$code] $message';
}

class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code = 'NETWORK_ERROR',
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}

class CacheException extends AppException {
  const CacheException({
    required String message,
    String? code = 'CACHE_ERROR',
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}

class WordGenerationException extends AppException {
  const WordGenerationException({
    required String message,
    String? code = 'GENERATION_ERROR',
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}

class UrlLauncherException extends AppException {
  const UrlLauncherException({
    required String message,
    String? code = 'URL_LAUNCH_ERROR',
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}

class UnknownException extends AppException {
  const UnknownException({
    required String message,
    String? code = 'UNKNOWN_ERROR',
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}