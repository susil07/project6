import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFFF4B3A);
  
  // Light Mode Colors
  static const Color backgroundLight = Color(0xFFF2F2F2);
  static const Color surfaceLight = Colors.white;
  static const Color onBackgroundLight = Colors.black;
  static const Color onSurfaceLight = Colors.black;
  static const Color secondaryLight = Color(0xFF9A9A9D);
  
  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surfaceDark = Color(0xFF2C2C2C);
  static const Color onBackgroundDark = Colors.white;
  static const Color onSurfaceDark = Colors.white;
  static const Color secondaryDark = Color(0xFFB3B3B3);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondaryLight,
        onSecondary: Colors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.onSurfaceLight,
        // Using surface for background as background is deprecated
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.onSurfaceLight,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondaryDark,
        onSecondary: Colors.black,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.onSurfaceDark,
        elevation: 0,
      ),
    );
  }
}
