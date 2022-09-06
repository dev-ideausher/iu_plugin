import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class GetStorageService extends GetxService {
  static final _runData = GetStorage('runData');

  Future<GetStorageService> initState() async {
    await GetStorage.init('runData');
    return this;
  }

  int get themeMode =>
      _runData.read('themeMode') ?? 0; // 2:follow system 1:dark 0:light
  set themeMode(int themeMode) => _runData.write('themeMode', themeMode);

  bool get isLoggedIn => _runData.read('isLoggedIn') ?? false;

  set isLoggedIn(bool isLoggedIn) => _runData.write('isLoggedIn', isLoggedIn);

  String get token => _runData.read('token') ?? '';

  set token(String token) => _runData.write('token', token);

  void logout() {
    _runData.erase();
  }
}
