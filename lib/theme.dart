import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFFF5F5F3);
  static const Color dark = Color(0xFF2E3338);
  static const Color cardBack = Color(0xFF2E3338);
  static const Color cardFront = Colors.white;
  static const Color accent = Color(0xFF2E3338);
  static const Color muted = Color(0xFF9E9E9E);
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData.light();
    final textTheme = GoogleFonts.jetBrainsMonoTextTheme(base.textTheme).apply(
      bodyColor: AppColors.dark,
      displayColor: AppColors.dark,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.dark,
        onPrimary: AppColors.background,
        surface: AppColors.background,
        onSurface: AppColors.dark,
      ),
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
