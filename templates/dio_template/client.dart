import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'app_interceptors.dart';
import 'endpoints.dart';
import 'exceptions.dart';

/// Advanced Dio HTTP Client with singleton pattern
/// Provides comprehensive API management with error handling and interceptors
class DioClient {
  // Singleton instance
  static DioClient? _instance;
  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  // Dio instance
  late final Dio _dio;
  final bool isOverlayLoader;
  final bool showSnackbar;

  /// Private constructor for singleton
  DioClient._internal({
    this.isOverlayLoader = false,
    this.showSnackbar = false,
  }) {
    _dio = Dio(_createDioOptions());
    _dio.interceptors.add(AppInterceptors(
      isOverlayLoader: isOverlayLoader,
      showSnackbar: showSnackbar,
    ));
  }

  /// Factory constructor for creating custom instances
  factory DioClient.custom({
    required Dio dio,
    bool isOverlayLoader = false,
    bool showSnackbar = false,
  }) {
    return DioClient._internal(
      isOverlayLoader: isOverlayLoader,
      showSnackbar: showSnackbar,
    ).._dio = dio;
  }

  /// Create Dio options with proper configuration
  BaseOptions _createDioOptions() {
    return BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: const Duration(milliseconds: Endpoints.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: Endpoints.receiveTimeout),
      sendTimeout: const Duration(milliseconds: Endpoints.sendTimeout),
      responseType: ResponseType.json,
      headers: {
        'Content-Type': Endpoints.contentType,
        'Accept': Endpoints.accept,
      },
      validateStatus: (status) => status != null && status < 500,
    );
  }

  /// Update base URL dynamically
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Get:-----------------------------------------------------------------------
  Future<Response<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool isOverlayLoader = true,
    bool showSnackbar = true,
  }) async {
    try {
      final response = await _dio.get<T>(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    } catch (e) {
      throw DioExceptions.fromError(e);
    }
  }

  /// Post:----------------------------------------------------------------------
  Future<Response<T>> post<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post<T>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    } catch (e) {
      throw DioExceptions.fromError(e);
    }
  }

  /// Put:-----------------------------------------------------------------------
  Future<Response<T>> put<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put<T>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    } catch (e) {
      throw DioExceptions.fromError(e);
    }
  }

  /// Delete:--------------------------------------------------------------------
  Future<Response<T>> delete<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.delete<T>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    } catch (e) {
      throw DioExceptions.fromError(e);
    }
  }

  /// Patch:-----------------------------------------------------------------------
  Future<Response<T>> patch<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch<T>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    } catch (e) {
      throw DioExceptions.fromError(e);
    }
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    try {
      final response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    } catch (e) {
      throw DioExceptions.fromError(e);
    }
  }

  /// Upload file with FormData
  Future<Response<T>> uploadFile<T>(
    String url,
    FormData formData, {
    ProgressCallback? onSendProgress,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        url,
        data: formData,
        onSendProgress: onSendProgress,
        options: options ?? Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw DioExceptions.fromDioError(e);
    } catch (e) {
      throw DioExceptions.fromError(e);
    }
  }

  /// Clear interceptors
  void clearInterceptors() {
    _dio.interceptors.clear();
  }

  /// Add custom interceptor
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }
}
