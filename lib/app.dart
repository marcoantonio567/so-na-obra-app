import 'package:flutter/material.dart';

import 'screens/login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF6D00);
    const secondary = Color(0xFF00A896);
    const tertiary = Color(0xFFFFC400);

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: primary,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFFFE0C2),
          onPrimaryContainer: const Color(0xFF431500),
          secondary: secondary,
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFC8F7EA),
          onSecondaryContainer: const Color(0xFF002E26),
          tertiary: tertiary,
          onTertiary: const Color(0xFF2E2500),
          tertiaryContainer: const Color(0xFFFFF0A8),
          onTertiaryContainer: const Color(0xFF302700),
          surface: const Color(0xFFFFFBF5),
          surfaceContainerHighest: const Color(0xFFFFEFD9),
          outlineVariant: const Color(0xFFE9CDB3),
          inversePrimary: const Color(0xFFFFB36B),
        );

    return MaterialApp(
      title: 'Só na Obra',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFFFF7EE),
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
