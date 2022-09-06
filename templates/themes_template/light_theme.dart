import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/services/responsiveSize.dart';
import '/app/services/colors.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  backgroundColor: Colors.white,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    unselectedItemColor: Colors.black,
    selectedItemColor: Get.context?.brandColor2 ?? Colors.white,
    elevation: 0,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.white,
    elevation: 0,
  ),
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
  appBarTheme: AppBarTheme(
    color: Colors.white,
    elevation: 0, toolbarTextStyle: TextTheme(
      headline6: TextStyle(
        color: Colors.black,
        fontSize: 18.ksp,
      ),
    ).bodyText2, titleTextStyle: TextTheme(
      headline6: TextStyle(
        color: Colors.black,
        fontSize: 18.ksp,
      ),
    ).headline6,
  ),
);
