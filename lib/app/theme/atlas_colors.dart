import 'package:flutter/material.dart';

/// Official Atlas Finance color tokens.
/// Keep feature screens on these tokens instead of hard-coded colors.
abstract final class AtlasColors {
  static const green = Color(0xFF10B981);
  static const greenDark = Color(0xFF059669);
  static const greenDeep = Color(0xFF064E3B);
  static const slate = Color(0xFF1F2937);
  static const white = Color(0xFFF3F4F6);

  static const background = Color(0xFF111512);
  static const surface = Color(0xFF252B27);
  static const surfaceSoft = Color(0xFF303832);
  static const textMuted = Color(0xFFAEB7B0);
  static const expense = Color(0xFFF08A78);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF13C987), green],
  );
}