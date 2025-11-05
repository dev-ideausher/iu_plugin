import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import 'api_response.dart';
import 'client.dart';
import 'endpoints.dart';
import 'exceptions.dart';
import 'remote_data_source.dart';

/// Advanced API Manager with singleton pattern and clean architecture
/// Uses RemoteDataSource for all API calls
/// This class provides a simple interface for making API calls
/// For better architecture, use Repository pattern with RemoteDataSource and LocalDataSource
class APIManager {
  // Singleton instance
  static APIManager? _instance;
  static APIManager get instance {
    _instance ??= APIManager._internal();
    return _instance!;
  }

  // Remote data source instance
  final RemoteDataSource _remoteDataSource;

  /// Private constructor for singleton
  APIManager._internal() : _remoteDataSource = _DefaultRemoteDataSource();

  /// Generic GET request
  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
    bool showSnackbar = true,
    bool isOverlayLoader = true,
  }) async {
    return await _remoteDataSource.get<T>(
      endpoint: endpoint,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      parser: parser,
      showSnackbar: showSnackbar,
      isOverlayLoader: isOverlayLoader,
    );
  }

  /// Generic POST request
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
    // Convert body to JSON if it's a Map or List
    dynamic requestData = body;
    if (body is Map || body is List) {
      requestData = jsonEncode(body);
    }

    return await _remoteDataSource.post<T>(
      endpoint: endpoint,
      body: requestData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      parser: parser,
      showSnackbar: showSnackbar,
      isOverlayLoader: isOverlayLoader,
    );
  }

  /// Generic PUT request
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
    dynamic requestData = body;
    if (body is Map || body is List) {
      requestData = jsonEncode(body);
    }

    return await _remoteDataSource.put<T>(
      endpoint: endpoint,
      body: requestData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      parser: parser,
      showSnackbar: showSnackbar,
      isOverlayLoader: isOverlayLoader,
    );
  }

  /// Generic PATCH request
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
    dynamic requestData = body;
    if (body is Map || body is List) {
      requestData = jsonEncode(body);
    }

    return await _remoteDataSource.patch<T>(
      endpoint: endpoint,
      body: requestData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      parser: parser,
      showSnackbar: showSnackbar,
      isOverlayLoader: isOverlayLoader,
    );
  }

  /// Generic DELETE request
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
    dynamic requestData = body;
    if (body is Map || body is List) {
      requestData = jsonEncode(body);
    }

    return await _remoteDataSource.delete<T>(
      endpoint: endpoint,
      body: requestData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      parser: parser,
      showSnackbar: showSnackbar,
      isOverlayLoader: isOverlayLoader,
    );
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
    return await _remoteDataSource.uploadFile<T>(
      endpoint: endpoint,
      formData: formData,
      onSendProgress: onSendProgress,
      options: options,
      cancelToken: cancelToken,
      parser: parser,
      showSnackbar: showSnackbar,
      isOverlayLoader: isOverlayLoader,
    );
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
    return await _remoteDataSource.downloadFile(
      urlPath: urlPath,
      savePath: savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      showSnackbar: showSnackbar,
      isOverlayLoader: isOverlayLoader,
    );
  }
}

/// Default remote data source implementation
class _DefaultRemoteDataSource extends RemoteDataSource {}
