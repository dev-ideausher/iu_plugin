import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

import 'enigma.dart';

/// Advanced secure storage service with encryption
/// Provides type-safe storage operations with automatic encryption/decryption
/// Uses flutter_secure_storage for platform-level encryption
class GetStorageService extends GetxService {
  // Configure secure storage with platform-specific options
  static final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Storage key prefix for organization
  static const String _keyPrefix = 'secure_';

  // Cache for synchronous access
  String _cachedToken = '';
  String _cachedFirebaseUid = '';
  String _cachedUserId = '';
  String _cachedUserEmail = '';
  String _cachedUserName = '';
  String _cachedLanguage = 'en';
  String _cachedThemeMode = 'light';
  bool _cachedIsFirstLaunch = true;

  /// Initialize storage service and load cache
  Future<GetStorageService> initState() async {
    try {
      // Verify storage is accessible
      await _storage.containsKey(key: '${_keyPrefix}init_check');

      // Load all cached values
      await _loadAllCache();

      if (kDebugMode) {
        developer.log('Secure storage service initialized successfully');
      }
      return this;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Storage initialization error: $e', error: e);
      }
      rethrow;
    }
  }

  /// Load all values into cache
  Future<void> _loadAllCache() async {
    await Future.wait([
      _loadTokenCache(),
      _loadFirebaseUidCache(),
      _loadUserIdCache(),
      _loadUserEmailCache(),
      _loadUserNameCache(),
      _loadLanguageCache(),
      _loadThemeModeCache(),
      _loadFirstLaunchCache(),
    ]);
  }

  Future<void> _loadTokenCache() async {
    try {
      final encrypted = await _storage.read(key: '${_keyPrefix}jwToken');
      if (encrypted != null && encrypted.isNotEmpty) {
        final decrypted = decryptAESCryptoJS(encrypted);
        _cachedToken = decrypted ?? '';
      }
    } catch (e) {
      if (kDebugMode) developer.log('Error loading token cache: $e');
    }
  }

  Future<void> _loadFirebaseUidCache() async {
    try {
      _cachedFirebaseUid =
          await _storage.read(key: '${_keyPrefix}firebaseUid') ?? '';
    } catch (e) {
      if (kDebugMode) developer.log('Error loading Firebase UID cache: $e');
    }
  }

  Future<void> _loadUserIdCache() async {
    try {
      _cachedUserId = await _storage.read(key: '${_keyPrefix}userId') ?? '';
    } catch (e) {
      if (kDebugMode) developer.log('Error loading user ID cache: $e');
    }
  }

  Future<void> _loadUserEmailCache() async {
    try {
      _cachedUserEmail =
          await _storage.read(key: '${_keyPrefix}userEmail') ?? '';
    } catch (e) {
      if (kDebugMode) developer.log('Error loading user email cache: $e');
    }
  }

  Future<void> _loadUserNameCache() async {
    try {
      _cachedUserName = await _storage.read(key: '${_keyPrefix}userName') ?? '';
    } catch (e) {
      if (kDebugMode) developer.log('Error loading user name cache: $e');
    }
  }

  Future<void> _loadLanguageCache() async {
    try {
      _cachedLanguage =
          await _storage.read(key: '${_keyPrefix}language') ?? 'en';
    } catch (e) {
      if (kDebugMode) developer.log('Error loading language cache: $e');
    }
  }

  Future<void> _loadThemeModeCache() async {
    try {
      _cachedThemeMode =
          await _storage.read(key: '${_keyPrefix}themeMode') ?? 'light';
    } catch (e) {
      if (kDebugMode) developer.log('Error loading theme mode cache: $e');
    }
  }

  Future<void> _loadFirstLaunchCache() async {
    try {
      final value = await _storage.read(key: '${_keyPrefix}isFirstLaunch');
      _cachedIsFirstLaunch = value == null || value == 'true';
    } catch (e) {
      if (kDebugMode) developer.log('Error loading first launch cache: $e');
    }
  }

  // ==================== Authentication Tokens ====================

  /// Get encrypted JWT token (decrypted automatically)
  String get getEncjwToken => _cachedToken;

  /// Set encrypted JWT token (encrypted automatically)
  set setEncjwToken(String val) {
    _cachedToken = val;
    _setEncjwTokenAsync(val);
  }

  Future<void> _setEncjwTokenAsync(String val) async {
    try {
      if (val.isEmpty) {
        await _storage.delete(key: '${_keyPrefix}jwToken');
        return;
      }
      final encrypted = encryptAESCryptoJS(val);
      if (encrypted != null) {
        await _storage.write(key: '${_keyPrefix}jwToken', value: encrypted);
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error setting token: $e', error: e);
      }
    }
  }

  // ==================== User Data ====================

  /// Get Firebase UID
  String get getFirebaseUid => _cachedFirebaseUid;

  /// Set Firebase UID
  set setFirebaseUid(String val) {
    _cachedFirebaseUid = val;
    _setFirebaseUidAsync(val);
  }

  Future<void> _setFirebaseUidAsync(String val) async {
    try {
      if (val.isEmpty) {
        await _storage.delete(key: '${_keyPrefix}firebaseUid');
      } else {
        await _storage.write(key: '${_keyPrefix}firebaseUid', value: val);
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error setting Firebase UID: $e', error: e);
      }
    }
  }

  /// Get user email
  String get getUserEmail => _cachedUserEmail;

  /// Set user email
  set setUserEmail(String val) {
    _cachedUserEmail = val;
    _setUserEmailAsync(val);
  }

  Future<void> _setUserEmailAsync(String val) async {
    try {
      if (val.isEmpty) {
        await _storage.delete(key: '${_keyPrefix}userEmail');
      } else {
        await _storage.write(key: '${_keyPrefix}userEmail', value: val);
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error setting user email: $e', error: e);
      }
    }
  }

  /// Get user name
  String get getUserName => _cachedUserName;

  /// Set user name
  set setUserName(String val) {
    _cachedUserName = val;
    _setUserNameAsync(val);
  }

  Future<void> _setUserNameAsync(String val) async {
    try {
      if (val.isEmpty) {
        await _storage.delete(key: '${_keyPrefix}userName');
      } else {
        await _storage.write(key: '${_keyPrefix}userName', value: val);
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error setting user name: $e', error: e);
      }
    }
  }

  /// Get user ID
  String get getUserId => _cachedUserId;

  /// Set user ID
  set setUserId(String val) {
    _cachedUserId = val;
    _setUserIdAsync(val);
  }

  Future<void> _setUserIdAsync(String val) async {
    try {
      if (val.isEmpty) {
        await _storage.delete(key: '${_keyPrefix}userId');
      } else {
        await _storage.write(key: '${_keyPrefix}userId', value: val);
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error setting user ID: $e', error: e);
      }
    }
  }

  // ==================== App Settings ====================

  /// Get app language
  String get getLanguage => _cachedLanguage;

  /// Set app language
  set setLanguage(String val) {
    _cachedLanguage = val;
    _setLanguageAsync(val);
  }

  Future<void> _setLanguageAsync(String val) async {
    try {
      await _storage.write(key: '${_keyPrefix}language', value: val);
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error setting language: $e', error: e);
      }
    }
  }

  /// Get theme mode (light/dark)
  String get getThemeMode => _cachedThemeMode;

  /// Set theme mode
  set setThemeMode(String val) {
    _cachedThemeMode = val;
    _setThemeModeAsync(val);
  }

  Future<void> _setThemeModeAsync(String val) async {
    try {
      await _storage.write(key: '${_keyPrefix}themeMode', value: val);
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error setting theme mode: $e', error: e);
      }
    }
  }

  /// Check if first launch
  bool get isFirstLaunch => _cachedIsFirstLaunch;

  /// Set first launch flag
  set setIsFirstLaunch(bool val) {
    _cachedIsFirstLaunch = val;
    _setIsFirstLaunchAsync(val);
  }

  Future<void> _setIsFirstLaunchAsync(bool val) async {
    try {
      await _storage.write(
        key: '${_keyPrefix}isFirstLaunch',
        value: val.toString(),
      );
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error setting first launch: $e', error: e);
      }
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => getEncjwToken.isNotEmpty && getFirebaseUid.isNotEmpty;

  // ==================== Generic Storage Methods ====================

  /// Write data to storage
  Future<void> write(String key, dynamic value) async {
    try {
      await _storage.write(key: '$_keyPrefix$key', value: value.toString());
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error writing to storage: $e', error: e);
      }
      rethrow;
    }
  }

  /// Read data from storage
  T? read<T>(String key) {
    // Note: This is synchronous but reads from async storage
    // For proper async reading, use readAsync method
    try {
      // This will return null for now, use readAsync for actual reading
      return null;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error reading from storage: $e', error: e);
      }
      return null;
    }
  }

  /// Read data from storage (async)
  Future<String?> readAsync(String key) async {
    try {
      return await _storage.read(key: '$_keyPrefix$key');
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
      await _storage.delete(key: '$_keyPrefix$key');
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error removing from storage: $e', error: e);
      }
    }
  }

  /// Check if key exists
  bool hasData(String key) {
    // Note: This is synchronous wrapper, actual check is async
    // For proper async checking, use hasDataAsync method
    return false;
  }

  /// Check if key exists (async)
  Future<bool> hasDataAsync(String key) async {
    try {
      return await _storage.containsKey(key: '$_keyPrefix$key');
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error checking key existence: $e', error: e);
      }
      return false;
    }
  }

  /// Get all keys
  List<String> getKeys() {
    // Note: This is synchronous wrapper, actual retrieval is async
    // For proper async retrieval, use getKeysAsync method
    return [];
  }

  /// Get all keys (async)
  Future<List<String>> getKeysAsync() async {
    try {
      final allKeys = await _storage.readAll();
      return allKeys.keys
          .where((key) => key.startsWith(_keyPrefix))
          .map((key) => key.substring(_keyPrefix.length))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error getting keys: $e', error: e);
      }
      return [];
    }
  }

  /// Clear all data (logout)
  Future<void> logout() async {
    try {
      // Remove sensitive data
      await _storage.delete(key: '${_keyPrefix}jwToken');
      await _storage.delete(key: '${_keyPrefix}firebaseUid');
      await _storage.delete(key: '${_keyPrefix}userId');
      await _storage.delete(key: '${_keyPrefix}userEmail');
      await _storage.delete(key: '${_keyPrefix}userName');

      // Clear cache
      _cachedToken = '';
      _cachedFirebaseUid = '';
      _cachedUserId = '';
      _cachedUserEmail = '';
      _cachedUserName = '';

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
      await _storage.deleteAll();

      // Clear all cache
      _cachedToken = '';
      _cachedFirebaseUid = '';
      _cachedUserId = '';
      _cachedUserEmail = '';
      _cachedUserName = '';
      _cachedLanguage = 'en';
      _cachedThemeMode = 'light';
      _cachedIsFirstLaunch = true;

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

  /// Get storage size (not available for secure storage)
  int getStorageSize() {
    if (kDebugMode) {
      developer.log(
        'Storage size calculation not available for flutter_secure_storage',
      );
    }
    return 0;
  }
}
