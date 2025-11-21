import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import 'exceptions.dart';

/// Retry policy configuration
class RetryPolicy {
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final List<int> retryableStatusCodes;
  final List<DioExceptionType> retryableExceptionTypes;

  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.retryableExceptionTypes = const [
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.connectionError,
    ],
  });

  /// Calculate delay for retry attempt
  Duration calculateDelay(int attempt) {
    final delay = initialDelay * pow(backoffMultiplier, attempt - 1);
    return delay > maxDelay ? maxDelay : delay;
  }

  /// Check if error should be retried
  bool shouldRetry(DioExceptions error, int attempt) {
    if (attempt >= maxRetries) return false;

    // Check status code
    if (error.statusCode != null &&
        retryableStatusCodes.contains(error.statusCode)) {
      return true;
    }

    // Check exception type
    if (error.type != null &&
        retryableExceptionTypes.contains(error.type)) {
      return true;
    }

    return false;
  }
}

/// Retry helper with exponential backoff
class RetryHelper {
  /// Execute function with retry logic
  static Future<T> executeWithRetry<T>({
    required Future<T> Function() operation,
    RetryPolicy? policy,
    void Function(int attempt, Duration delay)? onRetry,
    bool Function(dynamic error, int attempt)? shouldRetry,
  }) async {
    final retryPolicy = policy ?? const RetryPolicy();
    int attempt = 0;

    while (true) {
      try {
        return await operation();
      } catch (error) {
        attempt++;

        // Check custom retry condition
        if (shouldRetry != null && !shouldRetry(error, attempt)) {
          rethrow;
        }

        // Check if should retry based on policy
        if (error is DioExceptions) {
          if (!retryPolicy.shouldRetry(error, attempt)) {
            rethrow;
          }
        } else if (attempt >= retryPolicy.maxRetries) {
          rethrow;
        }

        // Calculate delay
        final delay = retryPolicy.calculateDelay(attempt);

        if (kDebugMode) {
          developer.log(
            'Retry attempt $attempt/${retryPolicy.maxRetries} after ${delay.inSeconds}s',
          );
        }

        // Callback
        onRetry?.call(attempt, delay);

        // Wait before retry
        await Future.delayed(delay);
      }
    }
  }
}

