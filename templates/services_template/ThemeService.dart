import 'package:get/get.dart';

import 'package:flutter/material.dart';

import 'storage.dart';

class ThemeService extends GetxService {


  @override
  Future<void> onInit() async {
    super.onInit();
    setTheme(theme);
  }

  ThemeMode get theme => Get.find<GetStorageService>().themeMode == 1
      ? ThemeMode.dark
      : Get.find<GetStorageService>().themeMode == 0
          ? ThemeMode.light
          : ThemeMode.system;

  void setTheme(ThemeMode thememode) {
    Get.changeThemeMode(thememode);
    Get.find<GetStorageService>().themeMode = thememode == ThemeMode.light
        ? 0
        : thememode == ThemeMode.dark
            ? 1
            : 2;
  }
}
