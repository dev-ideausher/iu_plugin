// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// Advanced Hex Color utility with validation and error handling
/// Supports multiple hex color formats: #RGB, #RRGGBB, #AARRGGBB
class HexColor extends Color {
  /// Default color to use if parsing fails
  static const Color defaultColor = Colors.transparent;

  /// Parse hex color string to integer
  /// Supports formats: RGB, RRGGBB, AARRGGBB
  /// Returns 0xFFFFFFFF (transparent white) on error
  static int _getColorFromHex(String hexColor) {
    try {
      // Remove # if present and convert to uppercase
      hexColor = hexColor.toUpperCase().replaceAll("#", "").trim();

      // Validate hex string contains only valid characters
      if (!_isValidHex(hexColor)) {
        if (kDebugMode) {
          developer.log('Invalid hex color format: $hexColor');
        }
        return defaultColor.value;
      }

      // Handle different hex color formats
      if (hexColor.length == 6) {
        // RRGGBB format - add alpha channel (FF = fully opaque)
        hexColor = "FF$hexColor";
      } else if (hexColor.length == 3) {
        // RGB format - expand to RRGGBB and add alpha
        // Example: #F0A -> #FF00AA
        hexColor = "FF${hexColor[0]}${hexColor[0]}${hexColor[1]}${hexColor[1]}${hexColor[2]}${hexColor[2]}";
      } else if (hexColor.length == 8) {
        // AARRGGBB format - already complete
        // No changes needed
      } else if (hexColor.length == 4) {
        // ARGB format - expand to AARRGGBB
        hexColor = "${hexColor[0]}${hexColor[0]}${hexColor[1]}${hexColor[1]}${hexColor[2]}${hexColor[2]}${hexColor[3]}${hexColor[3]}";
      } else {
        if (kDebugMode) {
          developer.log('Unsupported hex color length: ${hexColor.length}');
        }
        return defaultColor.value;
      }

      // Parse hex string to integer
      return int.parse(hexColor, radix: 16);
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error parsing hex color: $hexColor', error: e);
      }
      return defaultColor.value;
    }
  }

  /// Validate if string is a valid hex color
  static bool _isValidHex(String hex) {
    if (hex.isEmpty) return false;
    final hexRegex = RegExp(r'^[0-9A-F]+$');
    return hexRegex.hasMatch(hex);
  }

  /// Create HexColor from hex string
  /// 
  /// Examples:
  /// ```dart
  /// HexColor('#FF5733')      // Red color
  /// HexColor('FF5733')       // Red color (without #)
  /// HexColor('#F0A')         // Short format RGB
  /// HexColor('#80FF5733')    // With alpha channel
  /// ```
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  /// Create HexColor with alpha channel
  /// 
  /// [hexColor] - RGB hex string (without alpha)
  /// [alpha] - Alpha value (0.0 to 1.0)
  /// 
  /// Example:
  /// ```dart
  /// HexColor.withAlpha('#FF5733', 0.5) // 50% opacity red
  /// ```
  HexColor.withAlpha(String hexColor, double alpha)
      : super(Color(_getColorFromHex(hexColor)).withAlpha((alpha * 255).round()).value);

  /// Create HexColor from RGB values
  /// 
  /// Example:
  /// ```dart
  /// HexColor.fromRGB(255, 87, 51) // Red color
  /// ```
  HexColor.fromRGB(int r, int g, int b)
      : super(Color.fromARGB(255, r, g, b).value);

  /// Create HexColor from RGBA values
  /// 
  /// Example:
  /// ```dart
  /// HexColor.fromRGBA(255, 87, 51, 128) // Red with alpha
  /// ```
  HexColor.fromRGBA(int r, int g, int b, int a)
      : super(Color.fromARGB(a, r, g, b).value);

  /// Get hex string representation
  /// 
  /// [includeAlpha] - Whether to include alpha channel in output
  /// [includeHash] - Whether to include # prefix
  String toHex({bool includeAlpha = false, bool includeHash = true}) {
    final hex = value.toRadixString(16).toUpperCase().padLeft(8, '0');
    
    if (includeAlpha) {
      return includeHash ? '#$hex' : hex;
    } else {
      final rgb = hex.substring(2); // Remove alpha
      return includeHash ? '#$rgb' : rgb;
    }
  }

  /// Get RGB values
  Map<String, int> get rgb => {
    'r': red,
    'g': green,
    'b': blue,
  };

  /// Get RGBA values
  Map<String, int> get rgba => {
    'r': red,
    'g': green,
    'b': blue,
    'a': alpha,
  };

  /// Get alpha as double (0.0 to 1.0)
  double get alphaDouble => alpha / 255.0;

  /// Create lighter version of color
  /// [amount] - Amount to lighten (0.0 to 1.0)
  Color lighter([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final lighterHsl = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lighterHsl.toColor();
  }

  /// Create darker version of color
  /// [amount] - Amount to darken (0.0 to 1.0)
  Color darker([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final darkerHsl = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkerHsl.toColor();
  }
}

/// Extension for Color to add hex conversion
extension ColorHexExtension on Color {
  /// Convert Color to hex string
  String toHex({bool includeAlpha = false, bool includeHash = true}) {
    final hex = value.toRadixString(16).toUpperCase().padLeft(8, '0');
    
    if (includeAlpha) {
      return includeHash ? '#$hex' : hex;
    } else {
      final rgb = hex.substring(2);
      return includeHash ? '#$rgb' : rgb;
    }
  }
}
