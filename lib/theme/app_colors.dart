import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFFFF6D00);
  static const onPrimary = Colors.white;
  static const primaryContainer = Color(0xFFFFE0C2);
  static const onPrimaryContainer = Color(0xFF431500);

  static const secondary = Color(0xFF00A896);
  static const onSecondary = Colors.white;
  static const secondaryContainer = Color(0xFFC8F7EA);
  static const onSecondaryContainer = Color(0xFF002E26);

  static const tertiary = Color(0xFFFFC400);
  static const onTertiary = Color(0xFF2E2500);
  static const tertiaryContainer = Color(0xFFFFF0A8);
  static const onTertiaryContainer = Color(0xFF302700);

  static const surface = Color(0xFFFFFBF5);
  static const scaffoldBackground = Color(0xFFFFF7EE);
  static const surfaceContainerHighest = Color(0xFFFFEFD9);
  static const outlineVariant = Color(0xFFE9CDB3);
  static const inversePrimary = Color(0xFFFFB36B);

  static ColorScheme colorScheme() {
    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      surface: surface,
      surfaceContainerHighest: surfaceContainerHighest,
      outlineVariant: outlineVariant,
      inversePrimary: inversePrimary,
    );
  }
}
