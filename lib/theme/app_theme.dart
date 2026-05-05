import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════
// COLORS
// Warm light theme — decisive pass.
// Key principle: default cells are warm cream (no blue cast).
// Blue appears only in active hover/path states as interaction signal.
// Surfaces use warm paper-white. Text uses warm brown-gray.
// Hit/sunk/statusWon unchanged.
// ═══════════════════════════════════════════════════════

abstract final class AppColors {
  // Surface — light, clean, slightly warm
  static const background = Color(0xFFF8F6F1); // very light warm white
  static const surface = Color(0xFFFFFFFF); // pure white card
  static const surface2 = Color(0xFFF4F2EB); // light secondary panels
  static const border = Color(0xFFDDD8D1); // warm light-medium
  static const borderSubtle = Color(0xFFEBE7E1); // barely-there warm line

  // Text — warm brown-gray
  static const text1 = Color(0xFF1E1B17);
  static const text2 = Color(0xFF5A5450);
  static const text3 = Color(0xFF9C9488);

  // Accent — teal (brand #3FB6B0)
  static const accent = Color(0xFF3FB6B0);
  static const accentFaint = Color(0x173FB6B0); // opacity ≈ 0.09
  static const accentMid = Color(0x2E3FB6B0); // opacity ≈ 0.18
  static const accentGlow = Color(0x383FB6B0); // opacity ≈ 0.22

  // Cell: default — very light warm cream
  static const cellDefaultBg = Color(0xFFF2F0EB);
  static const cellDefaultBorder = Color(0xFFDAD5CE);

  // Cell: path — light warm highlight
  static const cellPathBg = Color(0xFFE9E4DC);
  static const cellPathBorder = Color(0xFFCBC5BC);

  // Cell: hover / active — vivid blue (unchanged — pops against cream)
  static const cellHoverBg = Color(0xFFC0CCF6);
  static const cellHoverBorder = Color(0xFF6890E0);
  static const cellHoverGlow = Color(0x333D5CE8); // opacity ≈ 0.20

  // Cell: hit — warm terracotta (less aggressive than pure red)
  static const cellHitBg = Color(0xFFC05C3C);
  static const cellHitBorder = Color(0xFF9A4428);

  // Cell: miss — light warm stone; × mark color used by _MissPainter
  static const cellMissBg = Color(0xFFE1DDD6);
  static const cellMissBorder = Color(0xFFC8C2BA);
  static const cellMissX = Color(0xFF888078); // visible on miss bg

  // Cell: blocked — medium warm stone (clearly darker than miss)
  static const cellBlockedBg = Color(0xFFD2CEC8);
  static const cellBlockedBorder = Color(0xFFB8B2AC);

  // Cell: sunk — dark brick (denser than hit, clearly distinct)
  static const cellSunkBg = Color(0xFF8E3828);
  static const cellSunkBorder = Color(0xFF6C2414);

  // Status (unchanged)
  static const statusWon = Color(0xFF1A9E60);
}

// ═══════════════════════════════════════════════════════
// DIMENSIONS
// ═══════════════════════════════════════════════════════

abstract final class AppDimensions {
  // Cell sizes (desktop / mobile)
  static const cellSize = 46.0;
  static const cellSizeMd = 30.0;
  static const cellGap = 2.0;

  // Axis sizes
  static const adjAxisWidth = 112.0;
  static const adjAxisWidthMd = 76.0;
  static const nounAxisH = 118.0;
  static const nounAxisHMd = 76.0;

  // Axis font sizes
  static const axisFs = 11.0;
  static const axisFsMd = 9.0;

  // Shell sections
  static const hudHeight = 54.0;
  static const eventStripH = 56.0; // 2-line event zone
  // 10 top + 24 header + 6 gap + (24 * 2 chips + 5 row gap) + 10 bottom.
  static const moveLogBarH = 103.0; // collapsed bar: header + 2 chip rows

  // Border radii
  static const radiusShell = 18.0;
  static const radiusCell = 6.0;
  static const radiusButton = 8.0;
  static const radiusChip = 5.0;

  // Shell padding
  static const shellPadH = 22.0;
  static const shellPadV = 22.0;
}

// ═══════════════════════════════════════════════════════
// TEXT STYLES
// Font: Manrope (google_fonts)
// Note: uppercase transforms must be applied at widget level (.toUpperCase())
// ═══════════════════════════════════════════════════════

abstract final class AppTextStyles {
  // HUD bar: "WordBattle" brand
  static final hudBrand = GoogleFonts.manrope(
    fontSize: 13.5,
    fontWeight: FontWeight.w800,
    color: AppColors.text1,
    letterSpacing: -0.02 * 13.5,
  );

  // HUD bar: status text ("Игра идёт")
  static final hudStatus = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.text2,
  );

  // HUD bar: stat number (large value)
  static final hudStatNum = GoogleFonts.manrope(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.text1,
    height: 1,
  );

  // HUD bar: stat label ("ходов", "попадания")
  static final hudStatLabel = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.text3,
  );

  // Board axis: word label (default state)
  static final axisLabel = GoogleFonts.manrope(
    fontSize: AppDimensions.axisFs,
    fontWeight: FontWeight.w500,
    color: AppColors.text3,
    letterSpacing: 0.025 * AppDimensions.axisFs,
  );

  // Board axis: word label (active / highlighted state)
  static final axisLabelActive = GoogleFonts.manrope(
    fontSize: AppDimensions.axisFs,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
    letterSpacing: 0.025 * AppDimensions.axisFs,
  );

  // Event strip: type tag ("ПОТОПЛЕН", "ПОБЕДА") — apply .toUpperCase() at widget
  static final eventTag = GoogleFonts.manrope(
    fontSize: 9.5,
    fontWeight: FontWeight.w800,
    color: AppColors.text3,
    letterSpacing: 0.12 * 9.5,
  );

  // Event strip: event message ("нетерпеливое чудо")
  static final eventMessage = GoogleFonts.manrope(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.text1,
  );

  // Move log chip label
  static final chipLabel = GoogleFonts.manrope(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.01 * 11,
  );

  // Move log section label ("ХОДЫ") — apply .toUpperCase() at widget
  static final moveLogLabel = GoogleFonts.manrope(
    fontSize: 9.5,
    fontWeight: FontWeight.w800,
    color: AppColors.text3,
    letterSpacing: 0.12 * 9.5,
  );

  // "Новая игра" button — color is set by foregroundColor in the button widget
  static final newGameButton = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.01 * 12,
  );
}

// ═══════════════════════════════════════════════════════
// THEME
// ═══════════════════════════════════════════════════════

abstract final class AppTheme {
  static ThemeData light() {
    final manropeTextTheme = GoogleFonts.manropeTextTheme(
      ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.manrope().fontFamily,
      textTheme: manropeTextTheme,
      scaffoldBackgroundColor: AppColors.background,
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
}
