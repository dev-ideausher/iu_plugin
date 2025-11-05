import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:developer' as developer;

/// Encryption service for secure data storage
/// Uses AES-CBC encryption compatible with CryptoJS
class Enigma {
  // Get passphrase from environment or use default
  // TODO: Use environment variables or secure storage for production
  // For production, use: const String.fromEnvironment('ENCRYPTION_PASSPHRASE')
  static String get passphrase {
    // Try to get from environment variable first
    const envPassphrase = String.fromEnvironment('ENCRYPTION_PASSPHRASE');
    if (envPassphrase.isNotEmpty) {
      return envPassphrase;
    }
    
    // Fallback to a default (should be changed in production)
    // In production, this should come from secure storage or environment config
    if (kDebugMode) {
      return 'default_debug_passphrase_change_in_production';
    }
    
    // Production default (should be overridden)
    return 'production_passphrase_change_this';
  }

  /// Encrypt plain text using AES-CBC (CryptoJS compatible)
  /// Returns base64 encoded encrypted string with salt
  static String? encryptAESCryptoJS(String? plainText) {
    if (plainText == null || plainText.isEmpty) {
      return null;
    }

    try {
      // Generate random salt
      final salt = genRandomWithNonZero(8);
      
      // Derive key and IV from passphrase and salt
      final keyAndIV = deriveKeyAndIV(passphrase, salt);
      final key = encrypt.Key(keyAndIV.item1);
      final iv = encrypt.IV(keyAndIV.item2);

      // Create encrypter with AES-CBC and PKCS7 padding
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"),
      );
      
      // Encrypt the plain text
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      
      // Combine "Salted__" prefix + salt + encrypted bytes
      final encryptedBytesWithSalt = Uint8List.fromList(
        createUint8ListFromString("Salted__") + salt + encrypted.bytes,
      );
      
      // Return base64 encoded string
      return base64.encode(encryptedBytesWithSalt);
    } catch (error) {
      if (kDebugMode) {
        developer.log('Encryption error: $error', error: error);
      }
      return null;
    }
  }

  /// Decrypt encrypted string (CryptoJS compatible format)
  /// Expects base64 encoded string with salt prefix
  static String? decryptAESCryptoJS(String? encrypted) {
    if (encrypted == null || encrypted.isEmpty) {
      return null;
    }

    try {
      // Decode base64
      final encryptedBytesWithSalt = base64.decode(encrypted);
      
      // Validate minimum length
      if (encryptedBytesWithSalt.length < 16) {
        if (kDebugMode) {
          developer.log('Invalid encrypted data: too short');
        }
        return null;
      }

      // Extract encrypted bytes (skip "Salted__" prefix and salt)
      final encryptedBytes = encryptedBytesWithSalt.sublist(
        16,
        encryptedBytesWithSalt.length,
      );
      
      // Extract salt (8 bytes after "Salted__" prefix)
      final salt = encryptedBytesWithSalt.sublist(8, 16);
      
      // Derive key and IV from passphrase and salt
      final keyAndIV = deriveKeyAndIV(passphrase, salt);
      final key = encrypt.Key(keyAndIV.item1);
      final iv = encrypt.IV(keyAndIV.item2);

      // Create encrypter
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"),
      );
      
      // Decrypt
      final decrypted = encrypter.decrypt64(
        base64.encode(encryptedBytes),
        iv: iv,
      );
      
      return decrypted;
    } catch (error) {
      if (kDebugMode) {
        developer.log('Decryption error: $error', error: error);
      }
      return null;
    }
  }

  /// Derive key and IV from passphrase and salt using MD5 (CryptoJS compatible)
  static Tuple2<Uint8List, Uint8List> deriveKeyAndIV(
    String passphrase,
    Uint8List salt,
  ) {
    final password = createUint8ListFromString(passphrase);
    Uint8List concatenatedHashes = Uint8List(0);
    Uint8List currentHash = Uint8List(0);
    bool enoughBytesForKey = false;
    Uint8List preHash = Uint8List(0);

    // Hash until we have enough bytes (32 for key + 16 for IV = 48 total)
    while (!enoughBytesForKey) {
      if (currentHash.isNotEmpty) {
        preHash = Uint8List.fromList(currentHash + password + salt);
      } else {
        preHash = Uint8List.fromList(password + salt);
      }

      currentHash = md5.convert(preHash).bytes as Uint8List;
      concatenatedHashes = Uint8List.fromList(concatenatedHashes + currentHash);
      
      if (concatenatedHashes.length >= 48) {
        enoughBytesForKey = true;
      }
    }

    // Extract key (32 bytes) and IV (16 bytes)
    final keyBytes = concatenatedHashes.sublist(0, 32);
    final ivBytes = concatenatedHashes.sublist(32, 48);
    
    return Tuple2(keyBytes, ivBytes);
  }

  /// Convert string to Uint8List
  static Uint8List createUint8ListFromString(String s) {
    final ret = Uint8List(s.length);
    for (var i = 0; i < s.length; i++) {
      ret[i] = s.codeUnitAt(i);
    }
    return ret;
  }

  /// Generate random bytes with non-zero values
  static Uint8List genRandomWithNonZero(int seedLength) {
    final random = Random.secure();
    const int randomMax = 245;
    final Uint8List uint8list = Uint8List(seedLength);
    
    for (int i = 0; i < seedLength; i++) {
      uint8list[i] = random.nextInt(randomMax) + 1;
    }
    
    return uint8list;
  }

  /// Validate if encrypted string is valid format
  static bool isValidEncryptedFormat(String? encrypted) {
    if (encrypted == null || encrypted.isEmpty) {
      return false;
    }

    try {
      final decoded = base64.decode(encrypted);
      
      // Must have at least "Salted__" (8 bytes) + salt (8 bytes) + some data
      if (decoded.length < 16) {
        return false;
      }

      // Check for "Salted__" prefix
      final prefix = String.fromCharCodes(decoded.sublist(0, 8));
      return prefix == "Salted__";
    } catch (e) {
      return false;
    }
  }
}

// Legacy function exports for backward compatibility
String? encryptAESCryptoJS(String? plainText) => Enigma.encryptAESCryptoJS(plainText);
String? decryptAESCryptoJS(String? encrypted) => Enigma.decryptAESCryptoJS(encrypted);
