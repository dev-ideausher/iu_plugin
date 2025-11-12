import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:tuple/tuple.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Encryption service for secure data storage
/// Uses AES-CBC encryption compatible with CryptoJS
class Enigma {
  // Get passphrase from environment or use default
  static String get passphrase {
    const envPassphrase = String.fromEnvironment('ENCRYPTION_PASSPHRASE');
    if (envPassphrase.isNotEmpty) {
      return envPassphrase;
    }

    if (kDebugMode) {
      return 'default_debug_passphrase_change_in_production';
    }

    return 'production_passphrase_change_this';
  }

  static String? encryptAESCryptoJS(String? plainText) {
    if (plainText == null || plainText.isEmpty) {
      return null;
    }

    try {
      final salt = genRandomWithNonZero(8);
      final keyAndIV = deriveKeyAndIV(passphrase, salt);
      final key = encrypt.Key(keyAndIV.item1);
      final iv = encrypt.IV(keyAndIV.item2);

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
      );

      final encrypted = encrypter.encrypt(plainText, iv: iv);
      final encryptedBytesWithSalt = Uint8List.fromList(
        createUint8ListFromString('Salted__') + salt + encrypted.bytes,
      );

      return base64.encode(encryptedBytesWithSalt);
    } catch (error) {
      if (kDebugMode) {
        developer.log('Encryption error', error: error);
      }
      return null;
    }
  }

  static String? decryptAESCryptoJS(String? encrypted) {
    if (encrypted == null || encrypted.isEmpty) {
      return null;
    }

    try {
      final encryptedBytesWithSalt = base64.decode(encrypted);

      final encryptedBytes = encryptedBytesWithSalt.sublist(16);
      final salt = encryptedBytesWithSalt.sublist(8, 16);
      final keyAndIV = deriveKeyAndIV(passphrase, salt);
      final key = encrypt.Key(keyAndIV.item1);
      final iv = encrypt.IV(keyAndIV.item2);

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
      );

      final decrypted = encrypter.decrypt64(
        base64.encode(encryptedBytes),
        iv: iv,
      );

      return decrypted;
    } catch (error) {
      if (kDebugMode) {
        developer.log('Decryption error', error: error);
      }
      return null;
    }
  }

  static Tuple2<Uint8List, Uint8List> deriveKeyAndIV(
    String passphrase,
    Uint8List salt,
  ) {
    final password = createUint8ListFromString(passphrase);
    Uint8List concatenatedHashes = Uint8List(0);
    Uint8List currentHash = Uint8List(0);
    bool enoughBytesForKey = false;
    Uint8List preHash;

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

    final keyBytes = concatenatedHashes.sublist(0, 32);
    final ivBytes = concatenatedHashes.sublist(32, 48);

    return Tuple2(keyBytes, ivBytes);
  }

  static Uint8List createUint8ListFromString(String s) {
    final ret = Uint8List(s.length);

    for (var i = 0; i < s.length; i++) {
      ret[i] = s.codeUnitAt(i);
    }

    return ret;
  }

  static Uint8List genRandomWithNonZero(int seedLength) {
    final random = Random.secure();
    const randomMax = 245;
    final uint8list = Uint8List(seedLength);

    for (var i = 0; i < seedLength; i++) {
      uint8list[i] = random.nextInt(randomMax) + 1;
    }

    return uint8list;
  }
}

// Legacy exports
String? encryptAESCryptoJS(String? plainText) =>
    Enigma.encryptAESCryptoJS(plainText);

String? decryptAESCryptoJS(String? encrypted) =>
    Enigma.decryptAESCryptoJS(encrypted);


