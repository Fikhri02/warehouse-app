import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF01483E);
  static const Color primaryDark = Color(0xFF003028);

  // Light mode
  static const Color background = Color(0xFFF0F4F3);
  static const Color surface = Colors.white;
  static const Color onPrimary = Colors.white;
  static const Color onBackground = Color(0xFF222222);
  static const Color subtitle = Color(0xFF666666);
  static const Color border = Color(0xFFDDDDDD);
  static const Color divider = Color(0xFFF0F0F0);

  // Dark mode
  static const Color darkBackground = Color(0xFF111111);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkAccent = Color(0xFF00C896);
  static const Color darkOnSurface = Color(0xFFEEEEEE);
  static const Color darkSubtitle = Color(0xFFAAAAAA);
  static const Color darkBorder = Color(0xFF333333);

  // Semantic
  static const Color error = Color(0xFFC62828);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFF8F00);
  static const Color unread = Color(0xFFE53935);
}
