import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'theme/app_colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColors.colorScheme();

    return MaterialApp(
      title: 'Só na Obra',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
        ),
        chipTheme: ChipThemeData(
          selectedColor: colorScheme.secondaryContainer,
          checkmarkColor: colorScheme.onSecondaryContainer,
          side: BorderSide(color: colorScheme.outlineVariant),
          labelStyle: TextStyle(color: colorScheme.onSurface),
        ),
        cardTheme: CardThemeData(
          color: colorScheme.surface,
          surfaceTintColor: colorScheme.primary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
