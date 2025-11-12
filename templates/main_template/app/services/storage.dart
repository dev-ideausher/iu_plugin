import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'enigma.dart';

/// Secure storage service using GetStorage with encryption support
class GetStorageService extends GetxService {
  static final GetStorage _runData = GetStorage('runData');

  Future<GetStorageService> initState() async {
    await GetStorage.init('runData');
    return this;
  }

  /// Get encrypted JWT token (decrypted automatically)
  String get getEncjwToken =>
      decryptAESCryptoJS(_runData.read('jwToken')) ?? '';

  /// Set encrypted JWT token (encrypted automatically)
  set setEncjwToken(String val) =>
      _runData.write('jwToken', encryptAESCryptoJS(val));

  /// Logout and clear stored data
  void logout() {
    _runData.erase();
  }
}


