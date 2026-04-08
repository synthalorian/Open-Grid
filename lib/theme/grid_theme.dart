import 'package:flutter/material.dart';

class GridTheme {
  static const Color background = Color(0xFF05050F);
  static const Color surface = Color(0xFF0A0A1E);
  static const Color surfaceLight = Color(0xFF101030);
  static const Color scanline = Color(0x08FFFFFF);
  static const Color neonMagenta = Color(0xFFFF00FF);
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonYellow = Color(0xFFFFFF00);
  static const Color neonGreen = Color(0xFF00FF66);
  static const Color neonRed = Color(0xFFFF3366);
  static const Color neonOrange = Color(0xFFFF8800);
  static const Color gridLine = Color(0xFF151540);
  static const Color textPrimary = Color(0xFFCCCCFF);
  static const Color textSecondary = Color(0xFF6666AA);
  static const Color textDim = Color(0xFF333366);

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: neonCyan,
          secondary: neonMagenta,
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: neonCyan,
          elevation: 0,
        ),
        useMaterial3: true,
      );
}
