import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import 'exceptions.dart';

/// API Response model for standardized responses
/// Used throughout the application for consistent error handling
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final DioExceptions? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.error,
  });

  /// Create success response
  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Create error response
  factory ApiResponse.error({
    String? message,
    int? statusCode,
    DioExceptions? error,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      error: error,
    );
  }

  /// Create ApiResponse from Dio Response
  factory ApiResponse.fromResponse(Response response, T Function(dynamic)? parser) {
    try {
      final data = response.data;
      
      // Handle different response formats
      if (data is Map<String, dynamic>) {
        final success = data['success'] as bool? ?? 
                       data['status'] == 'success' ||
                       (response.statusCode != null && 
                        response.statusCode! >= 200 && 
                        response.statusCode! < 300);
        
        final message = data['message'] as String? ?? 
                       data['msg'] as String?;
        
        final responseData = data['data'] ?? data;
        
        return ApiResponse(
          success: success,
          data: parser != null ? parser(responseData) : responseData as T?,
          message: message,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: response.statusCode != null && 
                  response.statusCode! >= 200 && 
                  response.statusCode! < 300,
          data: parser != null ? parser(data) : data as T?,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error parsing API response: $e', error: e);
      }
      return ApiResponse.error(
        message: 'Failed to parse response',
        statusCode: response.statusCode,
      );
    }
  }

  /// Check if response has data
  bool get hasData => data != null;

  /// Get data or throw exception
  T get dataOrThrow {
    if (!success || data == null) {
      throw error ?? DioExceptions(
        message: message ?? 'No data available',
        statusCode: statusCode,
      );
    }
    return data as T;
  }

  /// Get data or return default value
  T dataOr(T defaultValue) {
    return success && data != null ? data as T : defaultValue;
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}
