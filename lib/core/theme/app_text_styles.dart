import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  /// IBM Plex Sans everywhere (set on the theme); its I, l and 1 are all distinct and its figures line up.
  static const String sans = 'IBMPlexSans';

  /// IBM Plex Mono for codes, so 0/O, 1/l/I, 8/B and 5/S never blur together.
  static const String mono = 'IBMPlexMono';

  /// SKUs, barcodes, bins, PO and order numbers.
  static const TextStyle code = TextStyle(
    fontFamily: mono,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Canonical styles
  static const TextStyle display = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.4,
  );

  static const TextStyle title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.6,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.6,
  );

  static const TextStyle micro = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // Material-naming aliases used in later feature screens
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  static TextStyle get headlineSmall => display; // 20sp bold
  static TextStyle get bodyMedium => body; // 13sp regular
  static TextStyle get bodySmall => caption; // 11sp medium
}
