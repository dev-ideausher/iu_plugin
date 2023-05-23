import 'package:flutter/material.dart';

class TextStyleUtil {
  static TextStyle genSans300({
    Color color = Colors.white,
    required double fontSize,
  }) {
    return TextStyle(
      fontFamily: 'General Sans',
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w300,
    );
  }

  static TextStyle genSans400({
    Color color = Colors.white,
    required double fontSize,
  }) {
    return TextStyle(
      fontFamily: 'General Sans',
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle genSans500({
    Color color = Colors.white,
    required double fontSize,
  }) {
    return TextStyle(
      fontFamily: 'General Sans',
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle genSans600({
    Color color = Colors.white,
    required double fontSize,
  }) {
    return TextStyle(
      fontFamily: 'General Sans',
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
    );
  }
}

extension AppText on String {
  String get string => this;

  Widget text300(double fontSize,
          {Color color = Colors.black, TextAlign? textAlign}) =>
      Text(
        string,
        textAlign: textAlign,
        style: TextStyle(
          fontFamily: 'General Sans',
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w300,
        ),
      );

  Widget text400(double fontSize,
          {Color color = Colors.black, TextAlign? textAlign}) =>
      Text(
        string,
        textAlign: textAlign,
        style: TextStyle(
          fontFamily: 'General Sans',
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
        ),
      );

  Widget text500(double fontSize,
          {Color color = Colors.black, TextAlign? textAlign}) =>
      Text(
        string,
        textAlign: textAlign,
        style: TextStyle(
          fontFamily: 'General Sans',
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget text600(double fontSize,
          {Color color = Colors.black,
          TextAlign? textAlign,
          TextStyle? style}) =>
      Text(
        string,
        textAlign: textAlign,
        style: style ??
            TextStyle(
              fontFamily: 'General Sans',
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
      );
}
