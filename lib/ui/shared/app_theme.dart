import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static const double buttonBorderRadius = 12.0;
  static const double cardBorderRadius = 12.0;
  static const double inputBorderRadius = 8.0;

  static const double buttonFontSize = 16.0;
  static const FontWeight buttonFontWeight = FontWeight.bold;

  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light(useMaterial3: true);
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryPurple,
      brightness: Brightness.light,
      primary: AppColors.primaryPurple,
      error: AppColors.errorRed,
    );

    final baseTextTheme = GoogleFonts.latoTextTheme(baseTheme.textTheme);

    return baseTheme.copyWith(
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: lightColorScheme.surface,

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightColorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TextStyle(
            fontWeight: buttonFontWeight,
            fontSize: buttonFontSize,
          ),
        ),
      ),

      listTileTheme: ListTileThemeData(
        tileColor: null,
        selectedTileColor: lightColorScheme.primaryContainer.withValues(
          alpha: 0.4,
        ),
        iconColor: lightColorScheme.onSurfaceVariant,
        textColor: lightColorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: lightColorScheme.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: lightColorScheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
      ),

      cardTheme: CardTheme(
        color: lightColorScheme.surface,
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightColorScheme.onPrimary,
        elevation: 4.0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: lightColorScheme.onPrimary,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          textStyle: TextStyle(
            fontWeight: buttonFontWeight,
            fontSize: buttonFontSize,
            overflow: TextOverflow.ellipsis,
          ),
          elevation: 3.0,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: lightColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: lightColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: lightColorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: lightColorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(color: lightColorScheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: lightColorScheme.primary),
        errorStyle: TextStyle(
          color: lightColorScheme.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        errorMaxLines: 4,
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
        backgroundColor: lightColorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: lightColorScheme.onInverseSurface),
        actionTextColor: lightColorScheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogTheme(
        backgroundColor: lightColorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: lightColorScheme.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontSize: 16,
          color: lightColorScheme.onSurface,
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: lightColorScheme.primary,
        circularTrackColor: lightColorScheme.primary.withValues(alpha: 0.2),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: lightColorScheme.primary,
        selectionColor: lightColorScheme.primary.withValues(alpha: 0.4),
        selectionHandleColor: lightColorScheme.primary,
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: lightColorScheme.surface,
        scrimColor: lightColorScheme.scrim.withValues(alpha: 0.6),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 57,
          color: lightColorScheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontSize: 45,
          color: lightColorScheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontSize: 36,
          color: lightColorScheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 32,
          color: lightColorScheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 28,
          color: lightColorScheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 24,
          color: lightColorScheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 22,
          color: lightColorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16,
          color: lightColorScheme.onSurface,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          fontSize: 14,
          color: lightColorScheme.onSurface,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 14,
          color: lightColorScheme.onSurface,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontSize: 12,
          color: lightColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 11,
          color: lightColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          color: lightColorScheme.onSurface,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: lightColorScheme.onSurface,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: lightColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryPurple,
      brightness: Brightness.dark,
      primary: AppColors.primaryPurpleLight,
      error: AppColors.errorRedShade300,
    );

    final baseTextTheme = GoogleFonts.latoTextTheme(baseTheme.textTheme);

    return baseTheme.copyWith(
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: darkColorScheme.surface,

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkColorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TextStyle(
            fontWeight: buttonFontWeight,
            fontSize: buttonFontSize,
          ),
        ),
      ),

      listTileTheme: ListTileThemeData(
        tileColor: null,
        selectedTileColor: darkColorScheme.primaryContainer.withValues(
          alpha: 0.4,
        ),
        iconColor: darkColorScheme.onSurfaceVariant,
        textColor: darkColorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkColorScheme.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: darkColorScheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
      ),

      cardTheme: CardTheme(
        color: darkColorScheme.surfaceContainerHighest,
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkColorScheme.onSurface,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkColorScheme.primary,
          foregroundColor: darkColorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          textStyle: TextStyle(
            fontWeight: buttonFontWeight,
            fontSize: buttonFontSize,
            overflow: TextOverflow.ellipsis,
          ),
          elevation: 3.0,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: darkColorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: darkColorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: darkColorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: BorderSide(color: darkColorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(color: darkColorScheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: darkColorScheme.primary),
        errorStyle: TextStyle(
          color: darkColorScheme.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        errorMaxLines: 4,
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
        backgroundColor: darkColorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: darkColorScheme.onInverseSurface),
        actionTextColor: darkColorScheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogTheme(
        backgroundColor: darkColorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkColorScheme.onSurface,
        ),
        contentTextStyle: TextStyle(
          fontSize: 16,
          color: darkColorScheme.onSurface,
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: darkColorScheme.primary,
        circularTrackColor: darkColorScheme.primary.withValues(alpha: 0.2),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: darkColorScheme.primary,
        selectionColor: darkColorScheme.primary.withValues(alpha: 0.4),
        selectionHandleColor: darkColorScheme.primary,
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: darkColorScheme.surface,
        scrimColor: darkColorScheme.scrim.withValues(alpha: 0.6),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 57,
          color: darkColorScheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontSize: 45,
          color: darkColorScheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontSize: 36,
          color: darkColorScheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 32,
          color: darkColorScheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 28,
          color: darkColorScheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 24,
          color: darkColorScheme.onSurface,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 22,
          color: darkColorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16,
          color: darkColorScheme.onSurface,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          fontSize: 14,
          color: darkColorScheme.onSurface,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 14,
          color: darkColorScheme.onSurface,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontSize: 12,
          color: darkColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 11,
          color: darkColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          color: darkColorScheme.onSurface,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: darkColorScheme.onSurface,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: darkColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
