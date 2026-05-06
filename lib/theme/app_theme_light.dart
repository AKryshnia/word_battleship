import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme_foundation.dart';
import 'theme_tokens.dart';

ThemeData buildLightTheme() {
  final manropeTextTheme = GoogleFonts.manropeTextTheme(
    ThemeData.light().textTheme,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.manrope().fontFamily,
    textTheme: manropeTextTheme,
    scaffoldBackgroundColor: AppColors.background,
    extensions: const [WordBattleThemeTokens.light],
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.text1,
      outline: AppColors.border,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      error: AppColors.cellHitBg,
      onError: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusShell),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    dividerColor: AppColors.borderSubtle,
    dividerTheme: const DividerThemeData(
      color: AppColors.borderSubtle,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.text1,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.text1,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
        textStyle: AppTextStyles.newGameButton,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
  );
}
