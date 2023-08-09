import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColor(String hex) {
    String formattedHex = "FF${hex.toUpperCase().replaceAll("#", "")}";
    return int.parse(formattedHex, radix: 16);
  }

  static String toHex({required Color color, bool leadingHashSign = true}) =>
      '#${(color.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  HexColor(final String hex) : super(_getColor(hex));
}
