import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

import 'api_response.dart';
import 'local_data_source.dart';
import 'remote_data_source.dart';

/// Abstract base repository class following clean architecture
/// Combines remote and local data sources
abstract class Repository {
  /// Remote data source for API calls
  final RemoteDataSource remoteDataSource;
  
  /// Local data source for caching
  final LocalDataSource? localDataSource;

  Repository({
    required this.remoteDataSource,
    this.localDataSource,
  });

  /// Execute request with caching strategy
  /// If cache is available and not expired, return cached data
  /// Otherwise, fetch from remote and update cache
  Future<ApiResponse<T>> executeWithCache<T>({
    required Future<ApiResponse<T>> Function() remoteCall,
    String? cacheKey,
    Duration? cacheDuration,
    T Function(dynamic)? parser,
  }) async {
    // Check cache if available
    if (localDataSource != null && 
        cacheKey != null && 
        cacheDuration != null) {
      final cachedData = _getCachedData<T>(cacheKey, cacheDuration, parser);
      if (cachedData != null) {
        if (kDebugMode) {
          developer.log('Returning cached data for: $cacheKey');
        }
        return ApiResponse.success(data: cachedData);
      }
    }

    // Fetch from remote
    final response = await remoteCall();

    // Cache successful responses
    if (response.success && 
        response.data != null && 
        localDataSource != null && 
        cacheKey != null) {
      await _cacheData(cacheKey, response.data);
    }

    return response;
  }

  /// Get cached data if available and not expired
  T? _getCachedData<T>(
    String cacheKey,
    Duration cacheDuration,
    T Function(dynamic)? parser,
  ) {
    try {
      final cacheData = localDataSource!.get<Map<String, dynamic>>(cacheKey);
      if (cacheData == null) return null;

      final timestamp = cacheData['timestamp'] as int?;
      if (timestamp == null) return null;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      if (now.difference(cacheTime) > cacheDuration) {
        // Cache expired
        localDataSource!.remove(cacheKey);
        return null;
      }

      final data = cacheData['data'];
      return parser != null ? parser(data) : data as T?;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error reading cache: $e', error: e);
      }
      return null;
    }
  }

  /// Cache data with timestamp
  Future<void> _cacheData(String cacheKey, dynamic data) async {
    try {
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await localDataSource!.save(cacheKey, cacheData);
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error caching data: $e', error: e);
      }
    }
  }

  /// Clear cache for specific key
  Future<void> clearCache(String cacheKey) async {
    if (localDataSource != null) {
      await localDataSource!.remove(cacheKey);
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    if (localDataSource != null) {
      await localDataSource!.clear();
    }
  }
}

