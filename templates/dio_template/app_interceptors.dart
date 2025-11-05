import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import '../../routes/app_pages.dart';
import '../dialog_helper.dart';
import '../snackbar.dart';
import '../storage.dart';
import 'exceptions.dart';
import 'jwt_decoder.dart';
import 'endpoints.dart';
import 'request_logger.dart';
import 'rate_limiter.dart';

/// Advanced HTTP interceptor for handling authentication, errors, and retries
class AppInterceptors extends Interceptor {
  final bool isOverlayLoader;
  final bool showSnackbar;
  final int maxRetries;
  final int retryDelay;
  final bool enableLogging;
  final bool enableRateLimiting;
  
  int _retryCount = 0;
  bool _isRefreshingToken = false;
  final List<Completer> _pendingRequests = [];
  final EndpointRateLimiter _rateLimiter = EndpointRateLimiter();

  AppInterceptors({
    this.isOverlayLoader = true,
    this.showSnackbar = true,
    this.maxRetries = 3,
    this.retryDelay = 1000,
    this.enableLogging = true,
    this.enableRateLimiting = true,
  });

  @override
  FutureOr<dynamic> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Show loading overlay if enabled
    if (isOverlayLoader) {
      DialogHelper.showLoading();
    }

    // Add default headers
    options.headers.addAll({
      'Content-Type': Endpoints.contentType,
      'Accept': Endpoints.accept,
    });

    // Validate and add authentication token
    try {
      final isValid = await _validateAndAddToken(options);
      if (!isValid) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: 'Authentication failed',
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 401,
            ),
          ),
        );
        return;
      }
    } catch (e) {
      debugPrint('Error in onRequest: $e');
      handler.reject(
        DioException(
          requestOptions: options,
          error: e.toString(),
        ),
      );
      return;
    }

    // Rate limiting
    if (enableRateLimiting) {
      final endpoint = options.path;
      if (!_rateLimiter.canMakeRequest(endpoint)) {
        await _rateLimiter.waitUntilCanRequest(endpoint);
      }
      _rateLimiter.recordRequest(endpoint);
    }

    // Log request
    if (enableLogging) {
      RequestLogger.logRequest(options);
    }

    handler.next(options);
  }

  @override
  FutureOr<dynamic> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // Hide loading overlay
    if (isOverlayLoader) {
      DialogHelper.hideDialog();
    }

    // Log response
    if (enableLogging) {
      RequestLogger.logResponse(response);
    }

    // Reset retry count on successful response
    _retryCount = 0;

    handler.next(response);
  }

  @override
  Future<dynamic> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Hide loading overlay
    if (isOverlayLoader) {
      DialogHelper.hideDialog();
    }

    // Handle token expiration
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      final refreshed = await _handleTokenRefresh(err);
      if (refreshed) {
        // Retry the original request with new token
        return handler.resolve(await _retry(err.requestOptions));
      }
    }

    // Handle 500 errors with token expiration message
    if (err.response?.statusCode == 500) {
      final data = err.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] as String? ?? '';
        if (message.contains('id-token-expired') || message.contains('auth/id-token-expired')) {
          final refreshed = await _handleTokenRefresh(err);
          if (refreshed) {
            return handler.resolve(await _retry(err.requestOptions));
          }
        }
      }
    }

    // Handle network errors with retry
    if (_shouldRetry(err) && _retryCount < maxRetries) {
      _retryCount++;
      await Future.delayed(Duration(milliseconds: retryDelay * _retryCount));
      
      try {
        final response = await _retry(err.requestOptions);
        _retryCount = 0;
        return handler.resolve(response);
      } catch (e) {
        // Continue to error handling if retry fails
      }
    }

    // Log error
    if (enableLogging) {
      RequestLogger.logError(err);
    }

    // Show error message
    try {
      final errorMessage = DioExceptions.fromDioError(err);
      if (showSnackbar) {
        showMySnackbar(
          msg: errorMessage.message,
          title: 'Error',
        );
      }
      
      if (kDebugMode) {
        debugPrint('Error: ${errorMessage.message}');
        debugPrint('Status Code: ${errorMessage.statusCode}');
      }
    } catch (e) {
      debugPrint('Error handling exception: $e');
    }

    handler.next(err);
  }

  /// Validate token and add to headers
  Future<bool> _validateAndAddToken(RequestOptions options) async {
    try {
      final storageService = Get.find<GetStorageService>();
      final token = storageService.getEncjwToken;

      if (token.isEmpty) {
        // Try to get token from Firebase if available
        final firebaseToken = await _getFirebaseToken();
        if (firebaseToken != null) {
          storageService.setEncjwToken = firebaseToken;
          options.headers[Endpoints.tokenHeader] = firebaseToken;
          return true;
        }
        return false;
      }

      // Check if token is valid
      if (JwtDecoder.isValid(token)) {
        options.headers[Endpoints.tokenHeader] = token;
        return true;
      }

      // Token expired, try to refresh
      final newToken = await _refreshToken();
      if (newToken != null) {
        options.headers[Endpoints.tokenHeader] = newToken;
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error validating token: $e');
      return false;
    }
  }

  /// Handle token refresh for 401/403 errors
  Future<bool> _handleTokenRefresh(DioException err) async {
    if (_isRefreshingToken) {
      // Wait for ongoing refresh
      final completer = Completer<bool>();
      _pendingRequests.add(completer);
      return await completer.future;
    }

    _isRefreshingToken = true;

    try {
      final newToken = await _refreshToken();
      if (newToken != null) {
        // Complete all pending requests
        for (var completer in _pendingRequests) {
          completer.complete(true);
        }
        _pendingRequests.clear();
        _isRefreshingToken = false;
        return true;
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }

    // Complete all pending requests with failure
    for (var completer in _pendingRequests) {
      completer.complete(false);
    }
    _pendingRequests.clear();
    _isRefreshingToken = false;

    // Logout user on refresh failure
    try {
      Get.find<GetStorageService>().logout();
      Get.offAllNamed(Routes.SPLASH);
      showMySnackbar(
        msg: "Session Expired. Please Login Again",
        title: 'Error',
      );
    } catch (e) {
      debugPrint('Error during logout: $e');
    }

    return false;
  }

  /// Refresh Firebase token
  Future<String?> _refreshToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken(true);
        if (token.isNotEmpty) {
          Get.find<GetStorageService>().setEncjwToken = token;
          return token;
        }
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
    }
    return null;
  }

  /// Get Firebase token if available
  Future<String?> _getFirebaseToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken(true);
      }
    } catch (e) {
      debugPrint('Error getting Firebase token: $e');
    }
    return null;
  }

  /// Check if error should be retried
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }

  /// Retry failed request
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
      contentType: requestOptions.contentType,
      responseType: requestOptions.responseType,
    );

    final dio = Dio();
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
      cancelToken: requestOptions.cancelToken,
    );
  }
}
