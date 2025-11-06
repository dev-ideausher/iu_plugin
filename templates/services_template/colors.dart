import 'package:flutter/material.dart';
import 'hexColorToFlutterColor.dart';

/// Advanced color utilities with theme support
extension ColorUtil on BuildContext {
  /// Get dynamic color based on theme brightness
  /// [light] - Color value for light theme (ARGB integer)
  /// [dark] - Color value for dark theme (ARGB integer)
  Color dynamicColor({required int light, required int dark}) {
    return (Theme.of(this).brightness == Brightness.light)
        ? Color(light)
        : Color(dark);
  }

  /// Get dynamic color based on theme brightness
  /// [light] - Color for light theme
  /// [dark] - Color for dark theme
  Color dynamicColour({required Color light, required Color dark}) {
    return (Theme.of(this).brightness == Brightness.light) ? light : dark;
  }

  /// Primary brand color
  Color get brandColor1 =>
      dynamicColour(light: HexColor("#5D48D0"), dark: HexColor("#5D48D0"));

  /// Secondary brand color
  Color get brandColor2 =>
      dynamicColour(light: HexColor("#8032A8"), dark: HexColor("#8032A8"));

  /// Get color from theme
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  
  /// Get secondary color from theme
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  
  /// Get background color from theme
  Color get backgroundColor => Theme.of(this).colorScheme.surface;
  
  /// Get text color from theme
  Color get textColor => Theme.of(this).colorScheme.onSurface;
  
  /// Get error color from theme
  Color get errorColor => Theme.of(this).colorScheme.error;
  
  /// Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Check if current theme is light
  bool get isLightMode => Theme.of(this).brightness == Brightness.light;
}

/// Color constants for the application
class AppColors {
  AppColors._(); // Private constructor

  // ==================== Brand Colors ====================
  
  /// Primary brand color (Purple)
  static const Color primary = Color(0xFF5D48D0);
  
  /// Secondary brand color (Purple variant)
  static const Color secondary = Color(0xFF8032A8);
  
  /// Accent color
  static const Color accent = Color(0xFF5D48D0);

  // ==================== Semantic Colors ====================
  
  /// Success color (Green)
  static const Color success = Color(0xFF4CAF50);
  
  /// Error color (Red)
  static const Color error = Color(0xFFF44336);
  
  /// Warning color (Orange)
  static const Color warning = Color(0xFFFF9800);
  
  /// Info color (Blue)
  static const Color info = Color(0xFF2196F3);

  // ==================== Neutral Colors ====================
  
  /// Black
  static const Color black = Color(0xFF000000);
  
  /// White
  static const Color white = Color(0xFFFFFFFF);
  
  /// Grey shades
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ==================== Helper Methods ====================
  
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Get color from hex string
  static Color fromHex(String hex) => HexColor(hex);
  
  /// Get lighter shade of color
  static Color lighter(Color color, [double amount = 0.1]) {
    if (color is HexColor) {
      return color.lighter(amount);
    }
    return Color.fromRGBO(
      (color.red + (255 - color.red) * amount).round(),
      (color.green + (255 - color.green) * amount).round(),
      (color.blue + (255 - color.blue) * amount).round(),
      color.opacity,
    );
  }
  
  /// Get darker shade of color
  static Color darker(Color color, [double amount = 0.1]) {
    if (color is HexColor) {
      return color.darker(amount);
    }
    return Color.fromRGBO(
      (color.red * (1 - amount)).round(),
      (color.green * (1 - amount)).round(),
      (color.blue * (1 - amount)).round(),
      color.opacity,
    );
  }
}
