import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Network connectivity checker
/// Monitors network connection status and provides callbacks
class NetworkConnectivity {
  static NetworkConnectivity? _instance;
  static NetworkConnectivity get instance {
    _instance ??= NetworkConnectivity._internal();
    return _instance!;
  }

  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectionController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = true;

  NetworkConnectivity._internal();

  /// Initialize network monitoring
  Future<void> initialize() async {
    _connectionController = StreamController<bool>.broadcast();
    
    // Check initial status
    await checkConnectivity();

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        await checkConnectivity();
      },
    );
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasConnection = await _hasRealConnection(results);
      
      if (_isConnected != hasConnection) {
        _isConnected = hasConnection;
        _connectionController?.add(_isConnected);
        
        if (kDebugMode) {
          developer.log(
            'Network connectivity changed: $_isConnected',
          );
        }
      }
      
      return _isConnected;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error checking connectivity: $e', error: e);
      }
      return false;
    }
  }

  /// Check if device has real internet connection (not just network)
  Future<bool> _hasRealConnection(List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.none)) {
      return false;
    }

    // Try to reach a reliable server
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get current connection status
  bool get isConnected => _isConnected;

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged =>
      _connectionController?.stream ?? const Stream<bool>.empty();

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectionController?.close();
    _connectionController = null;
  }
}

/// Network-aware mixin for repositories
mixin NetworkAware {
  Future<T> executeWithNetworkCheck<T>(
    Future<T> Function() networkCall, {
    T Function()? offlineFallback,
  }) async {
    final connectivity = NetworkConnectivity.instance;
    
    if (!connectivity.isConnected) {
      if (offlineFallback != null) {
        return offlineFallback();
      }
      throw Exception('No internet connection');
    }

    return await networkCall();
  }
}


