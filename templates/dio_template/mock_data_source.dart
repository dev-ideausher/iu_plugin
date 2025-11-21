import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import 'api_response.dart';
import 'remote_data_source.dart';

/// Mock remote data source for testing and development
/// Returns predefined mock data instead of making actual API calls
class MockRemoteDataSource extends RemoteDataSource {
  final Map<String, dynamic> _mockResponses = {};
  final Duration _mockDelay;
  final bool _simulateErrors;
  final double _errorRate; // 0.0 to 1.0

  MockRemoteDataSource({
    Duration mockDelay = const Duration(milliseconds: 500),
    bool simulateErrors = false,
    double errorRate = 0.1,
  })  : _mockDelay = mockDelay,
        _simulateErrors = simulateErrors,
        _errorRate = errorRate;

  /// Register mock response for endpoint
  void registerMockResponse<T>({
    required String endpoint,
    required ApiResponse<T> response,
  }) {
    _mockResponses[endpoint] = response;
    
    if (kDebugMode) {
      developer.log('Registered mock response for: $endpoint');
    }
  }

  /// Register mock data for endpoint
  void registerMockData<T>({
    required String endpoint,
    required T data,
    String? message,
    int? statusCode,
  }) {
    _mockResponses[endpoint] = ApiResponse.success(
      data: data,
      message: message,
      statusCode: statusCode ?? 200,
    );
  }

  /// Clear all mock responses
  void clearMocks() {
    _mockResponses.clear();
    
    if (kDebugMode) {
      developer.log('All mock responses cleared');
    }
  }

  /// Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(_mockDelay);
  }

  /// Simulate random errors
  bool _shouldSimulateError() {
    if (!_simulateErrors) return false;
    return (DateTime.now().millisecondsSinceEpoch % 100) / 100 < _errorRate;
  }

  @override
  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
    bool showSnackbar = true,
    bool isOverlayLoader = true,
  }) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return ApiResponse.error(
        message: 'Simulated network error',
        statusCode: 500,
      );
    }

    final mockResponse = _mockResponses[endpoint];
    if (mockResponse != null) {
      return mockResponse as ApiResponse<T>;
    }

    return ApiResponse.error(
      message: 'No mock response registered for: $endpoint',
      statusCode: 404,
    );
  }

  @override
  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
    bool showSnackbar = true,
    bool isOverlayLoader = true,
  }) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return ApiResponse.error(
        message: 'Simulated network error',
        statusCode: 500,
      );
    }

    final mockResponse = _mockResponses[endpoint];
    if (mockResponse != null) {
      // Apply parser if provided
      if (parser != null && mockResponse is ApiResponse) {
        final data = parser(mockResponse.data);
        return ApiResponse.success(data: data);
      }
      return mockResponse as ApiResponse<T>;
    }

    // Default success response for POST
    return ApiResponse.success(
      data: body as T?,
      message: 'Mock success',
      statusCode: 201,
    );
  }

  @override
  Future<ApiResponse<T>> put<T>({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
    bool showSnackbar = true,
    bool isOverlayLoader = true,
  }) async {
    return await post<T>(
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      parser: parser,
      showSnackbar: showSnackbar,
      isOverlayLoader: isOverlayLoader,
    );
  }

  @override
  Future<ApiResponse<T>> patch<T>({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
    bool showSnackbar = true,
    bool isOverlayLoader = true,
  }) async {
    return await post<T>(
      endpoint: endpoint,
      body: body,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      parser: parser,
      showSnackbar: showSnackbar,
      isOverlayLoader: isOverlayLoader,
    );
  }

  @override
  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
    bool showSnackbar = true,
    bool isOverlayLoader = true,
  }) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return ApiResponse.error(
        message: 'Simulated network error',
        statusCode: 500,
      );
    }

    return ApiResponse.success(
      message: 'Mock delete success',
      statusCode: 200,
    );
  }
}

