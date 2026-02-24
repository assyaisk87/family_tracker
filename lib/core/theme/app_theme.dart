import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: Colors.black87,
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),

    checkboxTheme: CheckboxThemeData(
      side: const BorderSide(color: AppColors.primary, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),

    iconTheme: IconThemeData(color: AppColors.primary),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        iconColor: WidgetStateProperty.all(AppColors.primary),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.secondary,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      actionTextColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkBackground,
    brightness: Brightness.dark,

    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: Colors.black,
      secondary: AppColors.secondary,
      onSecondary: Colors.black,
      error: Colors.redAccent,
      onError: Colors.black,
      surface: AppColors.darkSurface,
      onSurface: Colors.white,
    ),

    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
    ),
  );
}
