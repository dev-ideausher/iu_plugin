import 'package:flutter/material.dart';
import 'responsive_size.dart';

/// Font weight enumeration for better type safety
enum FontWeightType {
  light,      // 300
  regular,    // 400
  medium,     // 500
  semiBold,   // 600
  bold,       // 700
  extraBold,  // 800
}

/// Advanced text style utility with comprehensive typography support
class TextStyleUtil {
  TextStyleUtil._(); // Private constructor

  /// Default font family
  static const String defaultFontFamily = 'General Sans';

  /// Get font weight from enum
  static FontWeight _getFontWeight(FontWeightType type) {
    switch (type) {
      case FontWeightType.light:
        return FontWeight.w300;
      case FontWeightType.regular:
        return FontWeight.w400;
      case FontWeightType.medium:
        return FontWeight.w500;
      case FontWeightType.semiBold:
        return FontWeight.w600;
      case FontWeightType.bold:
        return FontWeight.w700;
      case FontWeightType.extraBold:
        return FontWeight.w800;
    }
  }

  // ==================== General Sans Font Family ====================

  /// Create General Sans 300 (Light) text style
  static TextStyle genSans300({
    Color color = Colors.white,
    required double fontSize,
    String? fontFamily,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? defaultFontFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
    );
  }

  /// Create General Sans 400 (Regular) text style
  static TextStyle genSans400({
    Color color = Colors.white,
    required double fontSize,
    String? fontFamily,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? defaultFontFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
    );
  }

  /// Create General Sans 500 (Medium) text style
  static TextStyle genSans500({
    Color color = Colors.white,
    required double fontSize,
    String? fontFamily,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? defaultFontFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
    );
  }

  /// Create General Sans 600 (SemiBold) text style
  static TextStyle genSans600({
    Color color = Colors.white,
    required double fontSize,
    String? fontFamily,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? defaultFontFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
    );
  }

  /// Create General Sans 700 (Bold) text style
  static TextStyle genSans700({
    Color color = Colors.white,
    required double fontSize,
    String? fontFamily,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? defaultFontFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
    );
  }

  /// Create custom text style with font weight enum
  static TextStyle genSans({
    required FontWeightType weight,
    Color color = Colors.white,
    required double fontSize,
    String? fontFamily,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? defaultFontFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: _getFontWeight(weight),
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decorationThickness,
    );
  }

  // ==================== Responsive Text Styles ====================

  /// Create responsive text style (uses ksp for font size)
  static TextStyle genSansResponsive({
    required FontWeightType weight,
    Color color = Colors.white,
    required double fontSize,
    String? fontFamily,
    double? letterSpacing,
    double? height,
  }) {
    return genSans(
      weight: weight,
      color: color,
      fontSize: fontSize.ksp,
      fontFamily: fontFamily,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}

/// Extension on String for easy text widget creation
extension AppText on String {
  /// Get the string itself
  String get string => this;

  /// Create Text widget with 300 weight
  Widget text300(
    double fontSize, {
    Color color = Colors.black,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextStyle? style,
    String? fontFamily,
  }) =>
      Text(
        string,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
        style: style ??
            TextStyleUtil.genSans300(
              color: color,
              fontSize: fontSize,
              fontFamily: fontFamily,
            ),
      );

  /// Create Text widget with 400 weight
  Widget text400(
    double fontSize, {
    Color color = Colors.black,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextStyle? style,
    String? fontFamily,
  }) =>
      Text(
        string,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
        style: style ??
            TextStyleUtil.genSans400(
              color: color,
              fontSize: fontSize,
              fontFamily: fontFamily,
            ),
      );

  /// Create Text widget with 500 weight
  Widget text500(
    double fontSize, {
    Color color = Colors.black,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextStyle? style,
    String? fontFamily,
  }) =>
      Text(
        string,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
        style: style ??
            TextStyleUtil.genSans500(
              color: color,
              fontSize: fontSize,
              fontFamily: fontFamily,
            ),
      );

  /// Create Text widget with 600 weight
  Widget text600(
    double fontSize, {
    Color color = Colors.black,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextStyle? style,
    String? fontFamily,
  }) =>
      Text(
        string,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
        style: style ??
            TextStyleUtil.genSans600(
              color: color,
              fontSize: fontSize,
              fontFamily: fontFamily,
            ),
      );

  /// Create Text widget with 700 weight (Bold)
  Widget text700(
    double fontSize, {
    Color color = Colors.black,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextStyle? style,
    String? fontFamily,
  }) =>
      Text(
        string,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
        style: style ??
            TextStyleUtil.genSans700(
              color: color,
              fontSize: fontSize,
              fontFamily: fontFamily,
            ),
      );

  /// Create responsive Text widget (uses ksp for font size)
  Widget textResponsive(
    double fontSize, {
    FontWeightType weight = FontWeightType.regular,
    Color color = Colors.black,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    TextStyle? style,
    String? fontFamily,
  }) =>
      Text(
        string,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
        style: style ??
            TextStyleUtil.genSansResponsive(
              weight: weight,
              color: color,
              fontSize: fontSize,
              fontFamily: fontFamily,
            ),
      );
}
