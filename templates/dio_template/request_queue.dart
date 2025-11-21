import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import 'api_response.dart';
import 'network_connectivity.dart';

/// Queued request item
class QueuedRequest<T> {
  final String id;
  final Future<ApiResponse<T>> Function() request;
  final Completer<ApiResponse<T>> completer;
  final DateTime timestamp;
  final int priority;
  final int? maxRetries;
  int _retryCount = 0;

  QueuedRequest({
    required this.id,
    required this.request,
    required this.completer,
    DateTime? timestamp,
    this.priority = 0,
    this.maxRetries,
  }) : timestamp = timestamp ?? DateTime.now();

  int get retryCount => _retryCount;
  bool get canRetry => maxRetries == null || _retryCount < (maxRetries??0);

  void incrementRetry() {
    _retryCount++;
  }
}

/// Request queue manager for offline scenarios
/// Queues requests when offline and executes when online
class RequestQueue {
  static RequestQueue? _instance;
  static RequestQueue get instance {
    _instance ??= RequestQueue._internal();
    return _instance!;
  }

  final List<QueuedRequest> _queue = [];
  bool _isProcessing = false;
  StreamSubscription<bool>? _connectivitySubscription;

  RequestQueue._internal() {
    _initialize();
  }

  /// Initialize queue and listen to connectivity
  void _initialize() {
    _connectivitySubscription =
        NetworkConnectivity.instance.onConnectivityChanged.listen((isConnected) {
          if (isConnected) {
            _processQueue();
          }
        });
  }

  /// Add request to queue
  Future<ApiResponse<T>> enqueue<T>({
    required String id,
    required Future<ApiResponse<T>> Function() request,
    int priority = 0,
    int? maxRetries,
  }) async {
    final completer = Completer<ApiResponse<T>>();

    final queuedRequest = QueuedRequest<T>(
      id: id,
      request: request,
      completer: completer,
      priority: priority,
      maxRetries: maxRetries,
    );

    _queue.add(queuedRequest);
    _queue.sort((a, b) => b.priority.compareTo(a.priority));

    if (kDebugMode) {
      developer.log('Request queued: $id (Priority: $priority)');
    }

    // Try to process if online
    if (NetworkConnectivity.instance.isConnected) {
      _processQueue();
    }

    return completer.future;
  }

  /// Process queued requests
  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;

    while (_queue.isNotEmpty && NetworkConnectivity.instance.isConnected) {
      final request = _queue.removeAt(0);

      try {
        final response = await request.request();

        if (request.completer.isCompleted) continue;
        request.completer.complete(response);

        if (kDebugMode) {
          developer.log('Queued request completed: ${request.id}');
        }
      } catch (e) {
        if (request.canRetry) {
          request.incrementRetry();
          _queue.add(request);

          if (kDebugMode) {
            developer.log(
              'Request failed, retrying: ${request.id} (${request.retryCount}/${request.maxRetries})',
            );
          }

          // Wait before retry
          await Future.delayed(Duration(seconds: request.retryCount));
        } else {
          if (request.completer.isCompleted) continue;
          request.completer.completeError(e);

          if (kDebugMode) {
            developer.log('Request failed permanently: ${request.id}');
          }
        }
      }
    }

    _isProcessing = false;
  }

  /// Get queue size
  int get queueSize => _queue.length;

  /// Clear queue
  void clearQueue() {
    for (final request in _queue) {
      if (!request.completer.isCompleted) {
        request.completer.completeError(Exception('Queue cleared'));
      }
    }
    _queue.clear();

    if (kDebugMode) {
      developer.log('Request queue cleared');
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    clearQueue();
  }
}

