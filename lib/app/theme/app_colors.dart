import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.card,
    required this.inputFill,
    required this.border,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color primary;
  final Color onPrimary;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color card;
  final Color inputFill;
  final Color border;
  final Color success;
  final Color warning;
  final Color danger;

  static const light = AppColors(
    primary: Color(0xFF0F766E),
    onPrimary: Color(0xFFFFFFFF),
    background: Color(0xFFF4F7F6),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF172121),
    card: Color(0xFFFFFFFF),
    inputFill: Color(0xFFFFFFFF),
    border: Color(0xFFD6E1DF),
    success: Color(0xFF15803D),
    warning: Color(0xFFB45309),
    danger: Color(0xFFB91C1C),
  );

  static const dark = AppColors(
    primary: Color(0xFF3ECFBC),
    onPrimary: Color(0xFF042F2E),
    background: Color(0xFF0E1716),
    surface: Color(0xFF14211F),
    onSurface: Color(0xFFE7F2F0),
    card: Color(0xFF14211F),
    inputFill: Color(0xFF1B2B29),
    border: Color(0xFF29403D),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? background,
    Color? surface,
    Color? onSurface,
    Color? card,
    Color? inputFill,
    Color? border,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      card: card ?? this.card,
      inputFill: inputFill ?? this.inputFill,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    return AppColors(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t) ?? onPrimary,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      onSurface: Color.lerp(onSurface, other.onSurface, t) ?? onSurface,
      card: Color.lerp(card, other.card, t) ?? card,
      inputFill: Color.lerp(inputFill, other.inputFill, t) ?? inputFill,
      border: Color.lerp(border, other.border, t) ?? border,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
