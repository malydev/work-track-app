import 'package:flutter/material.dart';
import 'package:work_track/app/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return _buildTheme(brightness: Brightness.light, colors: AppColors.light);
  }

  static ThemeData dark() {
    return _buildTheme(brightness: Brightness.dark, colors: AppColors.dark);
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppColors colors,
  }) {
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: brightness,
      ).copyWith(
        surface: colors.surface,
        onSurface: colors.onSurface,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
      ),
      scaffoldBackgroundColor: colors.background,
      useMaterial3: true,
      extensions: [colors],
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 1.2),
        ),
      ),
    );
  }
}
