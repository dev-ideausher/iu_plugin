import 'package:dio/dio.dart';

/// Advanced exception handling for Dio HTTP client
/// Provides comprehensive error parsing and user-friendly messages
class DioExceptions implements Exception {
  final String message;
  final int? statusCode;
  final DioExceptionType? type;
  final dynamic originalError;

  DioExceptions({
    required this.message,
    this.statusCode,
    this.type,
    this.originalError,
  });

  /// Factory constructor to create DioExceptions from DioException
  factory DioExceptions.fromDioError(DioException dioException) {
    String message;
    int? statusCode;
    DioExceptionType? type = dioException.type;

    switch (dioException.type) {
      case DioExceptionType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with API server. Please check your internet connection.";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout in connection with API server";
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      case DioExceptionType.badResponse:
        statusCode = dioException.response?.statusCode;
        message = _handleError(
          statusCode,
          dioException.response?.data,
        );
        break;
      case DioExceptionType.connectionError:
        message = "No internet connection. Please check your network settings.";
        break;
      case DioExceptionType.badCertificate:
        message = "SSL certificate error. Please contact support.";
        break;
      case DioExceptionType.unknown:
        if (dioException.message?.contains("SocketException") == true ||
            dioException.message?.contains("Network is unreachable") == true) {
          message = 'No internet connection';
        } else {
          message = "Unexpected error occurred: ${dioException.message ?? 'Unknown error'}";
        }
        break;
      default:
        message = "Something went wrong";
        break;
    }

    return DioExceptions(
      message: message,
      statusCode: statusCode,
      type: type,
      originalError: dioException,
    );
  }

  /// Handle HTTP status code errors
  static String _handleError(int? statusCode, dynamic error) {
    if (error == null) {
      return 'An unknown error occurred';
    }

    // Try to extract message from error response
    String? errorMessage;
    if (error is Map<String, dynamic>) {
      errorMessage = error['message'] as String? ?? 
                    error['error'] as String? ?? 
                    error['msg'] as String?;
    } else if (error is String) {
      errorMessage = error;
    }

    switch (statusCode) {
      case 400:
        return errorMessage ?? 'Bad request. Please check your input.';
      case 401:
        return errorMessage ?? 'Unauthorized. Please login again.';
      case 403:
        return errorMessage ?? 'Forbidden. You don\'t have permission to access this resource.';
      case 404:
        return errorMessage ?? "Resource not found";
      case 409:
        return errorMessage ?? 'Conflict. The resource already exists.';
      case 422:
        return errorMessage ?? 'Validation error. Please check your input.';
      case 429:
        return errorMessage ?? 'Too many requests. Please try again later.';
      case 500:
        return errorMessage ?? 'Internal server error. Please try again later.';
      case 502:
        return errorMessage ?? 'Bad gateway. The server is temporarily unavailable.';
      case 503:
        return errorMessage ?? 'Service unavailable. Please try again later.';
      case 504:
        return errorMessage ?? 'Gateway timeout. The server took too long to respond.';
      default:
        return errorMessage ?? 'An error occurred. Status code: $statusCode';
    }
  }

  /// Create a DioExceptions from a generic error
  factory DioExceptions.fromError(dynamic error) {
    if (error is DioException) {
      return DioExceptions.fromDioError(error);
    }
    return DioExceptions(
      message: error.toString(),
      originalError: error,
    );
  }

  @override
  String toString() => message;

  /// Get detailed error information for debugging
  Map<String, dynamic> toJson() => {
    'message': message,
    'statusCode': statusCode,
    'type': type?.toString(),
    'error': originalError?.toString(),
  };
}
