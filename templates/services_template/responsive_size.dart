import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Responsive size extension for making UI elements adapt to different screen sizes
/// Provides percentage-based and pixel-based sizing utilities
extension ResponsiveSize on num {
  /// Scale factor for height calculations
  /// Formula: 100 / device screen height
  static const double scaleFactorH = 0.123;

  /// Scale factor for width calculations
  /// Formula: 100 / device screen width
  static const double scaleFactorW = 0.266;

  // ==================== Percentage-Based Sizing ====================

  /// Calculates the height as a percentage of the device's screen height
  ///
  /// Example: `20.h` will take 20% of the screen's height
  ///
  /// Usage:
  /// ```dart
  /// Container(height: 50.h) // 50% of screen height
  /// ```
  double get h => this * Get.height / 100;

  /// Calculates the width as a percentage of the device's screen width
  ///
  /// Example: `20.w` will take 20% of the screen's width
  ///
  /// Usage:
  /// ```dart
  /// Container(width: 80.w) // 80% of screen width
  /// ```
  double get w => this * Get.width / 100;

  // ==================== Pixel-Based Sizing ====================

  /// Calculates responsive height in logical pixels
  /// Uses scale factor to ensure consistent sizing across devices
  ///
  /// Example: `20.kh` will calculate 20 logical pixels based on screen height
  ///
  /// Usage:
  /// ```dart
  /// Container(height: 48.kh) // 48 logical pixels
  /// ```
  double get kh => (this * Get.height * scaleFactorH) / 100;

  /// Calculates responsive width in logical pixels
  /// Uses scale factor to ensure consistent sizing across devices
  ///
  /// Example: `20.kw` will calculate 20 logical pixels based on screen width
  ///
  /// Usage:
  /// ```dart
  /// Container(width: 100.kw) // 100 logical pixels
  /// ```
  double get kw => (this * Get.width * scaleFactorW) / 100;

  // ==================== Font Size Sizing ====================

  /// Calculates scalable pixel (sp) for font sizes
  /// Ensures text scales properly across different screen sizes
  ///
  /// Example: `16.ksp` will calculate responsive font size
  ///
  /// Usage:
  /// ```dart
  /// TextStyle(fontSize: 16.ksp)
  /// ```
  double get ksp => this * (Get.width / 3) / 100;

  /// Standard scalable pixel (sp) - same as ksp
  /// Provided for consistency with Flutter's sp unit
  double get sp => ksp;

  // ==================== Widget Helpers ====================

  /// Creates a SizedBox with height in responsive pixels
  ///
  /// Example: `20.kheightBox` creates a SizedBox with height 20.kh
  ///
  /// Usage:
  /// ```dart
  /// Column(
  ///   children: [
  ///     Text('Hello'),
  ///     16.kheightBox, // 16 logical pixels spacing
  ///     Text('World'),
  ///   ],
  /// )
  /// ```
  Widget get kheightBox => SizedBox(height: kh);

  /// Creates a SizedBox with width in responsive pixels
  ///
  /// Example: `20.kwidthBox` creates a SizedBox with width 20.kw
  ///
  /// Usage:
  /// ```dart
  /// Row(
  ///   children: [
  ///     Icon(Icons.home),
  ///     12.kwidthBox, // 12 logical pixels spacing
  ///     Text('Home'),
  ///   ],
  /// )
  /// ```
  Widget get kwidthBox => SizedBox(width: kw);

  /// Creates a SizedBox with height as percentage
  ///
  /// Example: `10.heightBox` creates a SizedBox with height 10% of screen
  Widget get heightBox => SizedBox(height: h);

  /// Creates a SizedBox with width as percentage
  ///
  /// Example: `10.widthBox` creates a SizedBox with width 10% of screen
  Widget get widthBox => SizedBox(width: w);

  /// Creates a square SizedBox with responsive size
  ///
  /// Example: `50.squareBox` creates a 50x50 logical pixel square
  Widget get squareBox => SizedBox(width: kw, height: kh);

  // ==================== Edge Insets Helpers ====================

  /// Creates EdgeInsets with all sides using responsive pixels
  ///
  /// Example: `16.allPadding` creates EdgeInsets.all(16.kh)
  EdgeInsets get allPadding => EdgeInsets.all(kh);

  /// Creates EdgeInsets with symmetric vertical padding
  ///
  /// Example: `16.verticalPadding` creates EdgeInsets.symmetric(vertical: 16.kh)
  EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: kh);

  /// Creates EdgeInsets with symmetric horizontal padding
  ///
  /// Example: `16.horizontalPadding` creates EdgeInsets.symmetric(horizontal: 16.kw)
  EdgeInsets get horizontalPadding => EdgeInsets.symmetric(horizontal: kw);

  /// Creates EdgeInsets with symmetric padding (vertical and horizontal)
  ///
  /// Example: `16.symmetricPadding` creates EdgeInsets.symmetric(vertical: 16.kh, horizontal: 16.kw)
  EdgeInsets get symmetricPadding => EdgeInsets.symmetric(vertical: kh, horizontal: kw);
}

/// Additional responsive utilities
class ResponsiveUtils {
  ResponsiveUtils._(); // Private constructor

  /// Get screen width
  static double get screenWidth => Get.width;

  /// Get screen height
  static double get screenHeight => Get.height;

  /// Check if device is tablet (width > 600)
  static bool get isTablet => Get.width > 600;

  /// Check if device is phone
  static bool get isPhone => !isTablet;

  /// Check if device is in landscape orientation
  static bool get isLandscape => Get.width > Get.height;

  /// Check if device is in portrait orientation
  static bool get isPortrait => Get.height > Get.width;

  /// Get responsive value based on screen size
  /// Returns tablet value if tablet, otherwise phone value
  static T responsive<T>({
    required T phone,
    T? tablet,
  }) {
    return isTablet && tablet != null ? tablet : phone;
  }

  /// Get responsive font size
  static double fontSize({
    required double phone,
    double? tablet,
  }) {
    return responsive(phone: phone, tablet: tablet);
  }

  /// Get responsive padding
  static EdgeInsets padding({
    required EdgeInsets phone,
    EdgeInsets? tablet,
  }) {
    return responsive(phone: phone, tablet: tablet);
  }
}
