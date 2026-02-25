import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.cardDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textWhite,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textDark,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textWhite,
        side: const BorderSide(color: AppColors.surfaceGrey),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: AppColors.textGrey),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 28),
      headlineMedium: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 24),
      titleLarge: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 20),
      titleMedium: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w500, fontSize: 16),
      bodyLarge: TextStyle(color: AppColors.textWhite, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textWhite, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.textGrey, fontSize: 12),
    ),
  );
}
