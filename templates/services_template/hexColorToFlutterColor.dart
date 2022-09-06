// ignore_for_file: file_names

import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    } else if (hexColor.length == 3) {
      String hexColor2 = hexColor.split('').reversed.join('');
      hexColor = "FF" + hexColor + hexColor2;
    }
    //print(int.parse(hexColor, radix: 16));
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
