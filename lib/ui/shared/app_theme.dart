import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // --- Light Theme ---
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light(
      useMaterial3: true,
    ); // Start with M3 light defaults
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryPurple,
      brightness: Brightness.light,

      primary: AppColors.primaryPurple,
      error: AppColors.errorRed,
    );

    return baseTheme.copyWith(
      colorScheme: lightColorScheme,
      // --- Component Themes ---
      scaffoldBackgroundColor: lightColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.onPrimary,
        elevation: 4.0,
        titleTextStyle: GoogleFonts.lato(
          // Example using Google Fonts
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: lightColorScheme.onPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              lightColorScheme.primary, // Default button background
          foregroundColor:
              lightColorScheme.onPrimary, // Default button text/icon
          textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightColorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightColorScheme.error, width: 2),
        ),
        labelStyle: TextStyle(color: lightColorScheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: lightColorScheme.primary),
        errorStyle: TextStyle(color: lightColorScheme.error, fontSize: 12),
        errorMaxLines: 2, // Allow error text to wrap
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return lightColorScheme.primary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return lightColorScheme.primary.withValues(alpha: 0.5);
          }
          return null;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return null;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        // Default style (errors will override background color)
        backgroundColor: lightColorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: lightColorScheme.onInverseSurface),
        actionTextColor: lightColorScheme.inversePrimary,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: lightColorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: TextStyle(
          color: lightColorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: lightColorScheme.onSurfaceVariant,
          fontSize: 16,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: lightColorScheme.primary,
      ),
      textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme).copyWith(
        // Customize specific text styles if needed
        bodyMedium: GoogleFonts.lato(color: lightColorScheme.onSurface),
        titleMedium: GoogleFonts.lato(color: lightColorScheme.onSurface),
        labelLarge: GoogleFonts.lato(fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- Dark Theme ---
  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark(
      useMaterial3: true,
    ); // Start with M3 dark defaults
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryPurple,
      brightness: Brightness.dark,
      // Override specific roles if needed
      primary: AppColors.primaryPurpleLight,
      error: AppColors.errorRedShade300,
    );

    return baseTheme.copyWith(
      colorScheme: darkColorScheme,
      // --- Component Themes (Dark Variants) ---
      scaffoldBackgroundColor: darkColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkColorScheme.onSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkColorScheme.primary,
          foregroundColor: darkColorScheme.onPrimary, // Text color on primary
          textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkColorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkColorScheme.error, width: 2),
        ),
        labelStyle: TextStyle(color: darkColorScheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: darkColorScheme.primary),
        errorStyle: TextStyle(color: darkColorScheme.error, fontSize: 12),
        errorMaxLines: 2, // Allow error text to wrap
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return darkColorScheme.primary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return darkColorScheme.primary.withValues(alpha: 0.5);
          }
          return null;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return null;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        // Default style (errors will override background color)
        backgroundColor: darkColorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: darkColorScheme.onInverseSurface),
        actionTextColor: darkColorScheme.inversePrimary,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: darkColorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: TextStyle(
          color: darkColorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: darkColorScheme.onSurfaceVariant,
          fontSize: 16,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: darkColorScheme.primary,
      ),
      textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme).copyWith(
        // Customize specific text styles if needed
        bodyMedium: GoogleFonts.lato(color: darkColorScheme.onSurface),
        titleMedium: GoogleFonts.lato(color: darkColorScheme.onSurface),
        labelLarge: GoogleFonts.lato(fontWeight: FontWeight.bold),
      ),
    );
  }
}
