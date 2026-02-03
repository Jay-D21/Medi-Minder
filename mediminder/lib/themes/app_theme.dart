import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryBlue = Color(0xFF2D9CDB);
  static const Color canvasWhite = Color(0xFFFAFAFA);
  static const Color successGreen = Color(0xFF27AE60);
  static const Color errorCoral = Color(0xFFEB5757);
  static const Color neutralGrey = Color(0xFF828282);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: canvasWhite,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: successGreen,
        surface: Colors.white,
        onSurface: Colors.black87,
        onError: Colors.white,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
        displayMedium: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        bodySmall: TextStyle(fontSize: 14, color: neutralGrey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize:
              const Size(double.infinity, 56), // 48dp+ for accessibility
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      // cardTheme: const CardTheme(
      //   elevation: 2,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      //   color: Colors.white,
      // ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: successGreen,
        surface: darkSurface,
        onSurface: Color(0xFFE0E0E0), // 90% White
        onError: Colors.white,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE0E0E0)),
        displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE0E0E0)),
        bodyLarge: TextStyle(fontSize: 18, color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)),
        bodySmall: TextStyle(fontSize: 14, color: Color(0xFFB0B0B0)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      // cardTheme: const CardTheme(
      //   elevation: 2,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      //   color: darkSurface,
      // ),
    );
  }
}
