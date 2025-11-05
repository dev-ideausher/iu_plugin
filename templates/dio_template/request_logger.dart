import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'dart:convert';

/// Advanced request/response logger for debugging
class RequestLogger {
  static bool _enabled = kDebugMode;
  static LogLevel _logLevel = LogLevel.all;

  /// Enable or disable logging
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Set log level
  static void setLogLevel(LogLevel level) {
    _logLevel = level;
  }

  /// Log request
  static void logRequest(RequestOptions options) {
    if (!_enabled) return;
    if (!_shouldLog(LogLevel.request)) return;

    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📤 REQUEST');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('${options.method} ${options.uri}');
    buffer.writeln('Headers: ${_formatHeaders(options.headers)}');
    
    if (options.data != null) {
      buffer.writeln('Body: ${_formatData(options.data)}');
    }
    
    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('Query: ${options.queryParameters}');
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    developer.log(buffer.toString());
  }

  /// Log response
  static void logResponse(Response response) {
    if (!_enabled) return;
    if (!_shouldLog(LogLevel.response)) return;

    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📥 RESPONSE');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('${response.requestOptions.method} ${response.requestOptions.uri}');
    buffer.writeln('Status: ${response.statusCode} ${response.statusMessage ?? ''}');
    buffer.writeln('Headers: ${_formatHeaders(response.headers.map)}');
    buffer.writeln('Data: ${_formatData(response.data)}');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    developer.log(buffer.toString());
  }

  /// Log error
  static void logError(DioException error) {
    if (!_enabled) return;
    if (!_shouldLog(LogLevel.error)) return;

    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('❌ ERROR');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('${error.requestOptions.method} ${error.requestOptions.uri}');
    buffer.writeln('Type: ${error.type}');
    buffer.writeln('Message: ${error.message}');
    
    if (error.response != null) {
      buffer.writeln('Status: ${error.response?.statusCode}');
      buffer.writeln('Data: ${_formatData(error.response?.data)}');
    }
    
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    developer.log(buffer.toString());
  }

  /// Format headers for logging
  static String _formatHeaders(Map<String, dynamic> headers) {
    final filtered = Map<String, dynamic>.from(headers);
    
    // Mask sensitive headers
    if (filtered.containsKey('Authorization')) {
      filtered['Authorization'] = '***';
    }
    if (filtered.containsKey('token')) {
      filtered['token'] = '***';
    }

    return filtered.toString();
  }

  /// Format data for logging
  static String _formatData(dynamic data) {
    if (data == null) return 'null';
    
    try {
      if (data is String) {
        // Try to parse as JSON
        try {
          final json = jsonDecode(data);
          return const JsonEncoder.withIndent('  ').convert(json);
        } catch (e) {
          return data;
        }
      } else if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      } else {
        return data.toString();
      }
    } catch (e) {
      return data.toString();
    }
  }

  /// Check if should log based on level
  static bool _shouldLog(LogLevel level) {
    switch (_logLevel) {
      case LogLevel.none:
        return false;
      case LogLevel.error:
        return level == LogLevel.error;
      case LogLevel.request:
        return level == LogLevel.request || level == LogLevel.error;
      case LogLevel.response:
        return level == LogLevel.response || level == LogLevel.error;
      case LogLevel.all:
        return true;
    }
  }
}

/// Log levels
enum LogLevel {
  none,
  error,
  request,
  response,
  all,
}

