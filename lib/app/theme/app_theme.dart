import 'package:flutter/material.dart';

import 'atlas_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AtlasColors.green,
          brightness: Brightness.dark,
          surface: AtlasColors.surface,
        ).copyWith(
          primary: AtlasColors.green,
          secondary: AtlasColors.greenDark,
          error: AtlasColors.expense,
          surface: AtlasColors.surface,
          onSurface: AtlasColors.white,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AtlasColors.background,
      fontFamily: 'Poppins',
      cardTheme: CardThemeData(
        color: AtlasColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AtlasColors.surface,
        labelStyle: const TextStyle(color: AtlasColors.textMuted),
        hintStyle: const TextStyle(color: AtlasColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
