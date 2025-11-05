import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer' as developer;

import 'enigma.dart';

/// Advanced secure storage service with encryption
/// Provides type-safe storage operations with automatic encryption/decryption
class GetStorageService extends GetxService {
  static final GetStorage _runData = GetStorage('runData');
  static const String _storageBoxName = 'runData';

  /// Initialize storage service
  Future<GetStorageService> initState() async {
    try {
      await GetStorage.init(_storageBoxName);
      if (kDebugMode) {
        developer.log('Storage service initialized successfully');
      }
      return this;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Storage initialization error: $e', error: e);
      }
      rethrow;
    }
  }

  // ==================== Authentication Tokens ====================
  
  /// Get encrypted JWT token (decrypted automatically)
  String get getEncjwToken {
    try {
      final encrypted = _runData.read<String>('jwToken');
      if (encrypted == null || encrypted.isEmpty) return '';
      final decrypted = decryptAESCryptoJS(encrypted);
      return decrypted ?? '';
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error getting token: $e', error: e);
      }
      return '';
    }
  }

  /// Set encrypted JWT token (encrypted automatically)
  set setEncjwToken(String val) {
    try {
      if (val.isEmpty) {
        _runData.remove('jwToken');
        return;
      }
      final encrypted = encryptAESCryptoJS(val);
      if (encrypted != null) {
        _runData.write('jwToken', encrypted);
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error setting token: $e', error: e);
      }
    }
  }

  // ==================== User Data ====================
  
  /// Get Firebase UID
  String get getFirebaseUid => _runData.read<String>('firebaseUid') ?? '';

  /// Set Firebase UID
  set setFirebaseUid(String val) {
    if (val.isEmpty) {
      _runData.remove('firebaseUid');
    } else {
      _runData.write('firebaseUid', val);
    }
  }

  /// Get user email
  String get getUserEmail => _runData.read<String>('userEmail') ?? '';

  /// Set user email
  set setUserEmail(String val) {
    if (val.isEmpty) {
      _runData.remove('userEmail');
    } else {
      _runData.write('userEmail', val);
    }
  }

  /// Get user name
  String get getUserName => _runData.read<String>('userName') ?? '';

  /// Set user name
  set setUserName(String val) {
    if (val.isEmpty) {
      _runData.remove('userName');
    } else {
      _runData.write('userName', val);
    }
  }

  /// Get user ID
  String get getUserId => _runData.read<String>('userId') ?? '';

  /// Set user ID
  set setUserId(String val) {
    if (val.isEmpty) {
      _runData.remove('userId');
    } else {
      _runData.write('userId', val);
    }
  }

  // ==================== App Settings ====================
  
  /// Get app language
  String get getLanguage => _runData.read<String>('language') ?? 'en';

  /// Set app language
  set setLanguage(String val) {
    _runData.write('language', val);
  }

  /// Get theme mode (light/dark)
  String get getThemeMode => _runData.read<String>('themeMode') ?? 'light';

  /// Set theme mode
  set setThemeMode(String val) {
    _runData.write('themeMode', val);
  }

  /// Check if first launch
  bool get isFirstLaunch => _runData.read<bool>('isFirstLaunch') ?? true;

  /// Set first launch flag
  set setIsFirstLaunch(bool val) {
    _runData.write('isFirstLaunch', val);
  }

  /// Check if user is logged in
  bool get isLoggedIn => getEncjwToken.isNotEmpty && getFirebaseUid.isNotEmpty;

  // ==================== Generic Storage Methods ====================
  
  /// Write data to storage
  Future<void> write(String key, dynamic value) async {
    try {
      await _runData.write(key, value);
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error writing to storage: $e', error: e);
      }
      rethrow;
    }
  }

  /// Read data from storage
  T? read<T>(String key) {
    try {
      return _runData.read<T>(key);
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error reading from storage: $e', error: e);
      }
      return null;
    }
  }

  /// Remove data from storage
  Future<void> remove(String key) async {
    try {
      await _runData.remove(key);
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error removing from storage: $e', error: e);
      }
    }
  }

  /// Check if key exists
  bool hasData(String key) {
    return _runData.hasData(key);
  }

  /// Get all keys
  List<String> getKeys() {
    return _runData.getKeys();
  }

  /// Clear all data (logout)
  Future<void> logout() async {
    try {
      // Remove sensitive data
      await _runData.remove('jwToken');
      await _runData.remove('firebaseUid');
      await _runData.remove('userId');
      await _runData.remove('userEmail');
      await _runData.remove('userName');
      
      if (kDebugMode) {
        developer.log('User data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error during logout: $e', error: e);
      }
      rethrow;
    }
  }

  /// Erase all storage data
  Future<void> erase() async {
    try {
      await _runData.erase();
      if (kDebugMode) {
        developer.log('All storage data erased');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error erasing storage: $e', error: e);
      }
      rethrow;
    }
  }

  /// Get storage size (approximate)
  int getStorageSize() {
    try {
      final keys = _runData.getKeys();
      int size = 0;
      for (final key in keys) {
        final value = _runData.read(key);
        if (value is String) {
          size += value.length;
        } else if (value is Map || value is List) {
          size += value.toString().length;
        }
      }
      return size;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error calculating storage size: $e', error: e);
      }
      return 0;
    }
  }
}
