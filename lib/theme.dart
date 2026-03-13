import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light mode
  static const Color background = Color(0xFFF5F5F3);
  static const Color dark = Color(0xFF2E3338);
  static const Color cardBack = Color(0xFF2E3338);
  static const Color cardFront = Colors.white;
  static const Color accent = Color(0xFF2E3338);
  static const Color muted = Color(0xFF9E9E9E);

  // Dark mode
  static const Color backgroundDark = Color(0xFF1A1D21);
  static const Color darkDark = Color(0xFFE8E8E8);
  static const Color cardBackDark = Color(0xFFE8E8E8);
  static const Color cardFrontDark = Color(0xFF2E3338);
  static const Color accentDark = Color(0xFFE8E8E8);
  static const Color mutedDark = Color(0xFF6B6B6B);
}

extension GameColorsExtension on ColorScheme {
  Color get cardBack =>
      brightness == Brightness.dark ? AppColors.cardBackDark : AppColors.cardBack;
  Color get cardFront =>
      brightness == Brightness.dark ? AppColors.cardFrontDark : AppColors.cardFront;
  Color get muted =>
      brightness == Brightness.dark ? AppColors.mutedDark : AppColors.muted;
  Color get foreground =>
      brightness == Brightness.dark ? AppColors.darkDark : AppColors.dark;
  Color get bg =>
      brightness == Brightness.dark ? AppColors.backgroundDark : AppColors.background;
}

class AppTheme {
  static ThemeData get light {
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

  static ThemeData get dark {
    final base = ThemeData.dark();
    final textTheme = GoogleFonts.jetBrainsMonoTextTheme(base.textTheme).apply(
      bodyColor: AppColors.darkDark,
      displayColor: AppColors.darkDark,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkDark,
        onPrimary: AppColors.backgroundDark,
        surface: AppColors.backgroundDark,
        onSurface: AppColors.darkDark,
      ),
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
