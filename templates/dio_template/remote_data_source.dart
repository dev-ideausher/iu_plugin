import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import 'api_response.dart';
import 'client.dart';
import 'exceptions.dart';

/// Abstract base class for remote data sources
/// Provides common functionality for all remote API calls
abstract class RemoteDataSource {
  /// Get DioClient instance
  DioClient get client => DioClient.instance;

  /// Handle API response and convert to ApiResponse
  ApiResponse<T> handleResponse<T>(
    Response response, {
    T Function(dynamic)? parser,
  }) {
    return ApiResponse.fromResponse<T>(response, parser);
  }

  /// Handle errors and convert to ApiResponse
  ApiResponse<T> handleError<T>(dynamic error) {
    if (error is DioExceptions) {
      if (kDebugMode) {
        developer.log('Remote data source error: ${error.message}', error: error);
      }
      return ApiResponse.error(
        message: error.message,
        statusCode: error.statusCode,
        error: error,
      );
    }

    final dioException = DioExceptions.fromError(error);
    if (kDebugMode) {
      developer.log('Unexpected remote data source error: $error', error: error);
    }
    return ApiResponse.error(
      message: dioException.message,
      error: dioException,
    );
  }

  /// Execute GET request
  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
    bool showSnackbar = true,
    bool isOverlayLoader = true,
  }) async {
    try {
      final response = await client.get<T>(
        endpoint,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        showSnackbar: showSnackbar,
        isOverlayLoader: isOverlayLoader,
      );
      return handleResponse<T>(response, parser: parser);
    } catch (e) {
      return handleError<T>(e);
    }
  }

  /// Execute POST request
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
    try {
      final response = await client.post<T>(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return handleResponse<T>(response, parser: parser);
    } catch (e) {
      return handleError<T>(e);
    }
  }

  /// Execute PUT request
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
    try {
      final response = await client.put<T>(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return handleResponse<T>(response, parser: parser);
    } catch (e) {
      return handleError<T>(e);
    }
  }

  /// Execute PATCH request
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
    try {
      final response = await client.patch<T>(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return handleResponse<T>(response, parser: parser);
    } catch (e) {
      return handleError<T>(e);
    }
  }

  /// Execute DELETE request
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
    try {
      final response = await client.delete<T>(
        endpoint,
        data: body,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return handleResponse<T>(response, parser: parser);
    } catch (e) {
      return handleError<T>(e);
    }
  }

  /// Upload file
  Future<ApiResponse<T>> uploadFile<T>({
    required String endpoint,
    required FormData formData,
    ProgressCallback? onSendProgress,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
    bool showSnackbar = true,
    bool isOverlayLoader = true,
  }) async {
    try {
      final response = await client.uploadFile<T>(
        endpoint,
        formData,
        onSendProgress: onSendProgress,
        options: options,
        cancelToken: cancelToken,
      );
      return handleResponse<T>(response, parser: parser);
    } catch (e) {
      return handleError<T>(e);
    }
  }

  /// Download file
  Future<ApiResponse<String>> downloadFile({
    required String urlPath,
    required String savePath,
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool showSnackbar = true,
    bool isOverlayLoader = true,
  }) async {
    try {
      final response = await client.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(
        data: savePath,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return handleError<String>(e);
    }
  }
}

