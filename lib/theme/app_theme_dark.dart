import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme_foundation.dart';
import 'theme_tokens.dart';

ThemeData buildDarkTheme() {
  final manropeTextTheme = GoogleFonts.manropeTextTheme(
    ThemeData.dark().textTheme,
  );
  const tokens = WordBattleThemeTokens.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.manrope().fontFamily,
    textTheme: manropeTextTheme,
    scaffoldBackgroundColor: tokens.background,
    extensions: const [tokens],
    colorScheme: ColorScheme.dark(
      primary: tokens.accent,
      onPrimary: tokens.onAccent,
      surface: tokens.surface,
      onSurface: tokens.text1,
      outline: tokens.border,
      secondary: tokens.accent,
      onSecondary: tokens.onAccent,
      error: tokens.red,
      onError: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: tokens.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusShell),
        side: BorderSide(color: tokens.border),
      ),
    ),
    dividerColor: tokens.borderSubtle,
    dividerTheme: DividerThemeData(
      color: tokens.borderSubtle,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.surface,
      foregroundColor: tokens.text1,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: tokens.text1,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tokens.accent,
        foregroundColor: tokens.onAccent,
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
