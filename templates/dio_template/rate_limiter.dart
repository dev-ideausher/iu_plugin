import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Rate limiter to prevent too many requests
class RateLimiter {
  final int maxRequests;
  final Duration timeWindow;
  final List<DateTime> _requestTimestamps = [];

  RateLimiter({
    required this.maxRequests,
    required this.timeWindow,
  });

  /// Check if request can be made
  bool canMakeRequest() {
    final now = DateTime.now();
    _requestTimestamps.removeWhere(
      (timestamp) => now.difference(timestamp) > timeWindow,
    );

    return _requestTimestamps.length < maxRequests;
  }

  /// Record a request
  void recordRequest() {
    _requestTimestamps.add(DateTime.now());
    
    if (kDebugMode) {
      developer.log(
        'Rate limiter: ${_requestTimestamps.length}/$maxRequests requests in window',
      );
    }
  }

  /// Get time until next request can be made
  Duration? getTimeUntilNextRequest() {
    if (canMakeRequest()) return null;

    final oldestRequest = _requestTimestamps.first;
    final timeSinceOldest = DateTime.now().difference(oldestRequest);
    final timeUntilAvailable = timeWindow - timeSinceOldest;

    return timeUntilAvailable.isNegative ? Duration.zero : timeUntilAvailable;
  }

  /// Wait until request can be made
  Future<void> waitUntilCanRequest() async {
    final waitTime = getTimeUntilNextRequest();
    if (waitTime != null && waitTime.inMilliseconds > 0) {
      if (kDebugMode) {
        developer.log('Rate limiter: Waiting ${waitTime.inSeconds}s');
      }
      await Future.delayed(waitTime);
    }
  }

  /// Reset rate limiter
  void reset() {
    _requestTimestamps.clear();
  }
}

/// Per-endpoint rate limiter
class EndpointRateLimiter {
  final Map<String, RateLimiter> _limiters = {};
  final int defaultMaxRequests;
  final Duration defaultTimeWindow;

  EndpointRateLimiter({
    this.defaultMaxRequests = 10,
    this.defaultTimeWindow = const Duration(seconds: 60),
  });

  /// Get or create rate limiter for endpoint
  RateLimiter _getLimiter(String endpoint) {
    return _limiters.putIfAbsent(
      endpoint,
      () => RateLimiter(
        maxRequests: defaultMaxRequests,
        timeWindow: defaultTimeWindow,
      ),
    );
  }

  /// Set custom rate limit for endpoint
  void setRateLimit(
    String endpoint, {
    required int maxRequests,
    required Duration timeWindow,
  }) {
    _limiters[endpoint] = RateLimiter(
      maxRequests: maxRequests,
      timeWindow: timeWindow,
    );
  }

  /// Check if request can be made for endpoint
  bool canMakeRequest(String endpoint) {
    return _getLimiter(endpoint).canMakeRequest();
  }

  /// Record request for endpoint
  void recordRequest(String endpoint) {
    _getLimiter(endpoint).recordRequest();
  }

  /// Wait until request can be made for endpoint
  Future<void> waitUntilCanRequest(String endpoint) async {
    await _getLimiter(endpoint).waitUntilCanRequest();
  }

  /// Reset rate limiter for endpoint
  void resetEndpoint(String endpoint) {
    _limiters.remove(endpoint);
  }

  /// Reset all rate limiters
  void resetAll() {
    _limiters.clear();
  }
}

