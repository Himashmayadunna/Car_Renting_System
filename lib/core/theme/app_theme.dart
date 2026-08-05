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
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppColors.textWhite),
      titleTextStyle: TextStyle(
        color: AppColors.textWhite,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.backgroundDark,
      modalBackgroundColor: AppColors.backgroundDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      elevation: 16,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 16,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textDark,
        minimumSize: const Size(double.infinity, 54),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 4,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textWhite,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.2),
        minimumSize: const Size(double.infinity, 54),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w800, fontSize: 30, letterSpacing: -0.5),
      headlineMedium: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w700, fontSize: 24, letterSpacing: -0.3),
      titleLarge: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w700, fontSize: 20),
      titleMedium: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600, fontSize: 16),
      bodyLarge: TextStyle(color: AppColors.textWhite, fontSize: 16, height: 1.4),
      bodyMedium: TextStyle(color: AppColors.textWhite, fontSize: 14, height: 1.4),
      bodySmall: TextStyle(color: AppColors.textGrey, fontSize: 12, height: 1.3),
    ),
  );
}
