import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

import '../services_template/storage.dart';

/// Abstract base class for local data sources
/// Provides common functionality for local storage operations
abstract class LocalDataSource {
  /// Get storage service instance
  GetStorageService get storage => Get.find<GetStorageService>();

  /// Save data to local storage
  Future<void> save<T>(String key, T value) async {
    try {
      await storage.write(key, value);
      if (kDebugMode) {
        developer.log('Saved to local storage: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error saving to local storage: $e', error: e);
      }
      rethrow;
    }
  }

  /// Get data from local storage
  T? get<T>(String key) {
    try {
      return storage.read<T>(key);
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error reading from local storage: $e', error: e);
      }
      return null;
    }
  }

  /// Remove data from local storage
  Future<void> remove(String key) async {
    try {
      await storage.remove(key);
      if (kDebugMode) {
        developer.log('Removed from local storage: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error removing from local storage: $e', error: e);
      }
    }
  }

  /// Check if key exists in local storage
  bool hasKey(String key) {
    return storage.hasData(key);
  }

  /// Clear all local storage
  Future<void> clear() async {
    try {
      await storage.erase();
      if (kDebugMode) {
        developer.log('Local storage cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error clearing local storage: $e', error: e);
      }
      rethrow;
    }
  }

  /// Get all keys from local storage
  List<String> getAllKeys() {
    return storage.getKeys();
  }
}

