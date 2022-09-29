import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension ResponsiveSize on num {
  static const double scaleFactorH = 0.123; //100/devide screen height
  static const double scalefactorW = 0.266; //100/device screen width

  /// Calculates the height depending on the device's screen size
  ///
  /// Eg: 20.h -> will take 20% of the screen's height
  double get h => this * Get.height / 100;

  /// Calculates the width depending on the device's screen size
  ///
  /// Eg: 20.w -> will take 20% of the screen's width
  double get w => this * Get.width / 100;

  /// Calculates the sp (Scalable Pixel) depending on the device's screen size
  double get ksp => this * (Get.width / 3) / 100;

  /// Calculates the number of pixel depending on the device's screen size
  ///
  /// Eg: 20.kh -> will take 20 logical pixel of the screen's height
  double get kh => (this * Get.height * scaleFactorH) / 100;

  /// Calculates the number of pixel depending on the device's screen size
  ///
  /// Eg: 20.kw -> will take 20 logical pixel of the screen's width
  double get kw => (this * Get.width * scalefactorW) / 100;

///Create a SizedBox widget with height provided in number of pixels
///
///Eg: 20.kheightBox creates a SizedBox with height 20.kh
  Widget get kheightBox => SizedBox(height: kh);

///Create a SizedBox widget with width provided in number of pixels
///
///Eg: 20.kwidthBox creates a SizedBox with width 20.kw
  Widget get kwidthBox => SizedBox(width: kw);
}
