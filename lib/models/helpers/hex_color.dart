import 'package:flutter/material.dart';

/// This class represents a hex color and allows to work with hex colors
class HexColor extends Color {
  /// Method to get color hex as int
  static int _getColor(String hex) {
    String formattedHex = "FF${hex.toUpperCase().replaceAll("#", "")}";
    return int.parse(formattedHex, radix: 16);
  }

  /// Method to conver the type [Color] to a hex color [String]
  ///
  /// If no hash sign is needed [leadingHashSign] must be null
  static String toHex({required Color color, bool leadingHashSign = true}) =>
      '#${(color.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  HexColor(final String hex) : super(_getColor(hex));
}
