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

@immutable
class WordBattleThemeTokens extends ThemeExtension<WordBattleThemeTokens> {
  final Color background;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color border;
  final Color borderSubtle;
  final Color borderStrong;
  final Color text1;
  final Color text2;
  final Color text3;
  final Color accent;
  final Color accentHover;
  final Color accentPressed;
  final Color accentFaint;
  final Color accentMid;
  final Color accentGlow;
  final Color amber;
  final Color red;
  final Color green;
  final Color onAccent;

  const WordBattleThemeTokens({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.border,
    required this.borderSubtle,
    required this.borderStrong,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.accent,
    required this.accentHover,
    required this.accentPressed,
    required this.accentFaint,
    required this.accentMid,
    required this.accentGlow,
    required this.amber,
    required this.red,
    required this.green,
    required this.onAccent,
  });

  static const light = WordBattleThemeTokens(
    background: AppColors.background,
    surface: AppColors.surface,
    surface2: AppColors.surface2,
    surface3: Color(0xFFEDE9E0),
    border: AppColors.border,
    borderSubtle: AppColors.borderSubtle,
    borderStrong: Color(0xFFC8C2BA),
    text1: AppColors.text1,
    text2: AppColors.text2,
    text3: AppColors.text3,
    accent: AppColors.accent,
    accentHover: Color(0xFF2A9490),
    accentPressed: Color(0xFF1A4F4C),
    accentFaint: AppColors.accentFaint,
    accentMid: AppColors.accentMid,
    accentGlow: AppColors.accentGlow,
    amber: Color(0xFFC06A14),
    red: AppColors.cellHitBg,
    green: AppColors.statusWon,
    onAccent: Colors.white,
  );

  static const dark = WordBattleThemeTokens(
    background: Color(0xFF181715),
    surface: Color(0xFF222220),
    surface2: Color(0xFF2A2A28),
    surface3: Color(0xFF33332F),
    border: Color(0xFF3A3A37),
    borderSubtle: Color(0xFF2E2E2C),
    borderStrong: Color(0xFF4A4A45),
    text1: Color(0xFFF0EAD9),
    text2: Color(0xFFADA89B),
    text3: Color(0xFF6E6A60),
    accent: Color(0xFF3FB6B0),
    accentHover: Color(0xFF5BC8C2),
    accentPressed: Color(0xFF2C9A94),
    accentFaint: Color(0x1C3FB6B0),
    accentMid: Color(0x383FB6B0),
    accentGlow: Color(0x4D3FB6B0),
    amber: Color(0xFFE2A340),
    red: Color(0xFFDC5A32),
    green: Color(0xFF42C17A),
    onAccent: Color(0xFF0A2827),
  );

  @override
  WordBattleThemeTokens copyWith({
    Color? background,
    Color? surface,
    Color? surface2,
    Color? surface3,
    Color? border,
    Color? borderSubtle,
    Color? borderStrong,
    Color? text1,
    Color? text2,
    Color? text3,
    Color? accent,
    Color? accentHover,
    Color? accentPressed,
    Color? accentFaint,
    Color? accentMid,
    Color? accentGlow,
    Color? amber,
    Color? red,
    Color? green,
    Color? onAccent,
  }) {
    return WordBattleThemeTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      text1: text1 ?? this.text1,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      accentPressed: accentPressed ?? this.accentPressed,
      accentFaint: accentFaint ?? this.accentFaint,
      accentMid: accentMid ?? this.accentMid,
      accentGlow: accentGlow ?? this.accentGlow,
      amber: amber ?? this.amber,
      red: red ?? this.red,
      green: green ?? this.green,
      onAccent: onAccent ?? this.onAccent,
    );
  }

  @override
  WordBattleThemeTokens lerp(
    ThemeExtension<WordBattleThemeTokens>? other,
    double t,
  ) {
    if (other is! WordBattleThemeTokens) return this;
    return WordBattleThemeTokens(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      text1: Color.lerp(text1, other.text1, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      accentPressed: Color.lerp(accentPressed, other.accentPressed, t)!,
      accentFaint: Color.lerp(accentFaint, other.accentFaint, t)!,
      accentMid: Color.lerp(accentMid, other.accentMid, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      red: Color.lerp(red, other.red, t)!,
      green: Color.lerp(green, other.green, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
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

  static ThemeData dark() {
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
}
