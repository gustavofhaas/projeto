import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF0EA5E9);
  static const Color successGreen = Color(0xFF10B981);
  static const Color darkBackground = Color(0xFF0F172A);

  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: darkBackground,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: successGreen,
      background: darkBackground,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}