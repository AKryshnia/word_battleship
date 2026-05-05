import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'cell_painters.dart';
export 'cell_painters.dart';

// ═════════════════════════════════════════════════════════════════════════════
// BoardVisualStyle
//
// Public selector for the visual look of the board. The game logic is
// completely independent from the visual style — picking a different value here
// only changes colors, borders, axis label typography, and the icons rendered
// inside revealed cells. Geometry (cell size, gap, axis placement) stays the
// same as the existing Modern look so adaptive layout is not affected.
//
// References: basics/Board Variants.html (4 themes).
// ═════════════════════════════════════════════════════════════════════════════

enum BoardVisualStyle {
  modernInk,
  navalRetro,
  candyFluffy,
  gridScan;

  String get label => switch (this) {
        BoardVisualStyle.modernInk => 'Modern — Ink on Paper',
        BoardVisualStyle.navalRetro => 'Retro — Naval Chart',
        BoardVisualStyle.candyFluffy => 'Fluffy — Candy Tiles',
        BoardVisualStyle.gridScan => 'Futuristic — Grid Scan',
      };

  String get shortLabel => switch (this) {
        BoardVisualStyle.modernInk => 'Modern',
        BoardVisualStyle.navalRetro => 'Retro',
        BoardVisualStyle.candyFluffy => 'Fluffy',
        BoardVisualStyle.gridScan => 'Futuristic',
      };
}

// ═════════════════════════════════════════════════════════════════════════════
// CellVisual — colors + border for a single cell state.
// ═════════════════════════════════════════════════════════════════════════════

@immutable
class CellVisual {
  final Color background;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow> shadows;

  /// Optional diagonal-stripe overlay color. When non-null, the cell paints
  /// a `repeating-linear-gradient(45deg, …)`-style hatch on top of
  /// [background] using this color for the darker stripes. Used by Modern's
  /// blocked state to read as a "не доступная зона" the way the HTML
  /// reference does, without affecting other states or styles.
  final Color? hatchColor;

  const CellVisual({
    required this.background,
    required this.borderColor,
    this.borderWidth = 1.0,
    this.shadows = const [],
    this.hatchColor,
  });
}

// ═════════════════════════════════════════════════════════════════════════════
// CellIconKind
//
// Discriminator for the painter used inside a cell. Each visual style maps
// its hit / miss icon to one of these — the cell widget then dispatches to
// the right CustomPainter. This keeps each cell free of style-aware ifs.
// ═════════════════════════════════════════════════════════════════════════════

// ═════════════════════════════════════════════════════════════════════════════
// BoardStyleConfig — every per-style parameter the UI needs.
//
// Keep the API narrow on purpose: cells, axis labels, and the board mat are
// the only surfaces that need to know about the style.
// ═════════════════════════════════════════════════════════════════════════════

@immutable
class BoardStyleConfig {
  final BoardVisualStyle id;

  // Background of the board "mat" — the area inside the shell, behind cells.
  final Color boardBackground;

  // Optional faint horizontal scanline overlay (Futuristic).
  final bool scanlines;
  final Color scanlineColor;

  // Cell state visuals
  final CellVisual cellDefault;
  final CellVisual cellPath;
  final CellVisual cellHover;
  final CellVisual cellHit;
  final CellVisual cellSunk;
  final CellVisual cellMiss;
  final CellVisual cellBlocked;

  // Cell icon dispatch
  final CellIconKind hitIcon;
  final Color hitIconColor;
  final CellIconKind missIcon;
  final Color missIconColor;

  // Axis labels (rotated nouns + horizontal adjectives)
  final TextStyle axisLabel;
  final TextStyle axisLabelActive;

  // Whether axis labels should be uppercased (Futuristic).
  final bool axisUppercase;

  const BoardStyleConfig({
    required this.id,
    required this.boardBackground,
    required this.scanlines,
    required this.scanlineColor,
    required this.cellDefault,
    required this.cellPath,
    required this.cellHover,
    required this.cellHit,
    required this.cellSunk,
    required this.cellMiss,
    required this.cellBlocked,
    required this.hitIcon,
    required this.hitIconColor,
    required this.missIcon,
    required this.missIconColor,
    required this.axisLabel,
    required this.axisLabelActive,
    required this.axisUppercase,
  });
}

// ═════════════════════════════════════════════════════════════════════════════
// Presets
//
// Modern keeps the existing Ink-on-Paper look (default). The other three
// reproduce the reference HTML themes. Geometry is intentionally inherited
// from AppDimensions so layout tests and responsive math stay valid.
// ═════════════════════════════════════════════════════════════════════════════

class BoardStylePresets {
  const BoardStylePresets._();

  static const BoardVisualStyle defaultStyle = BoardVisualStyle.modernInk;

  static BoardStyleConfig of(BoardVisualStyle style) {
    switch (style) {
      case BoardVisualStyle.modernInk:
        return _modern;
      case BoardVisualStyle.navalRetro:
        return _retro;
      case BoardVisualStyle.candyFluffy:
        return _fluffy;
      case BoardVisualStyle.gridScan:
        return _future;
    }
  }

  // ── 1. Modern — Ink on Paper ────────────────────────────────────────────────
  // Faithful port of the HTML reference T_MODERN preset. Self-contained color
  // values (intentionally NOT wired through AppColors.cellHit/cellMiss/etc) —
  // the legacy AppColors palette is terracotta-tinted, while the reference
  // calls for crisp black-on-white ink. AppColors stays untouched so the rest
  // of the UI (HUD, event strip) keeps its warm tone.
  static final BoardStyleConfig _modern = BoardStyleConfig(
    id: BoardVisualStyle.modernInk,
    boardBackground: const Color(0xFFF5F0E6),
    scanlines: false,
    scanlineColor: const Color(0x00000000),
    cellDefault: const CellVisual(
      background: Color(0xFFFFFFFF),
      borderColor: Color(0xFFD8CEC0),
    ),
    cellPath: const CellVisual(
      background: Color(0xFFFFF6EA),
      borderColor: Color(0xFFE8D8B0),
    ),
    cellHover: const CellVisual(
      background: Color(0xFFFFF0C8),
      borderColor: Color(0xFFCC8A0A),
      borderWidth: 1.5,
      shadows: [BoxShadow(color: Color(0x2EA06400), blurRadius: 14, offset: Offset(0, 2))],
    ),
    cellHit: const CellVisual(
      background: Color(0xFF111111),
      borderColor: Color(0xFF000000),
    ),
    // Sunk reuses the same ink-black tone (no terracotta); a soft outer halo
    // sets it apart from a fresh hit without introducing a new hue.
    cellSunk: const CellVisual(
      background: Color(0xFF111111),
      borderColor: Color(0xFF000000),
      shadows: [BoxShadow(color: Color(0x40000000), spreadRadius: 2)],
    ),
    cellMiss: const CellVisual(
      background: Color(0xFFFFFFFF),
      borderColor: Color(0xFFD8CEC0),
    ),
    // Blocked: light cream base with a slightly darker diagonal stripe
    // overlay — exactly the `repeating-linear-gradient(45deg,#EDE6DC, …,
    // #DDD4C8 …)` from the reference, ported as a CustomPainter overlay.
    cellBlocked: const CellVisual(
      background: Color(0xFFEDE6DC),
      borderColor: Color(0xFFC8BEB4),
      hatchColor: Color(0xFFDDD4C8),
    ),
    hitIcon: CellIconKind.inkX,
    hitIconColor: const Color(0xFFFFFFFF),
    missIcon: CellIconKind.ring,
    missIconColor: const Color(0xFFC8BEB4),
    axisLabel: GoogleFonts.manrope(
      fontSize: AppDimensions.axisFs,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFB0A090),
      letterSpacing: 0.025 * AppDimensions.axisFs,
    ),
    axisLabelActive: GoogleFonts.manrope(
      fontSize: AppDimensions.axisFs,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFB06010),
      letterSpacing: 0.025 * AppDimensions.axisFs,
    ),
    axisUppercase: false,
  );

  // ── 2. Retro — Naval Chart ──────────────────────────────────────────────────
  static final BoardStyleConfig _retro = BoardStyleConfig(
    id: BoardVisualStyle.navalRetro,
    boardBackground: const Color(0xFF0C1B30),
    scanlines: false,
    scanlineColor: const Color(0x00000000),
    cellDefault: const CellVisual(
      background: Color(0xFF122440),
      borderColor: Color(0xFF284868),
    ),
    cellPath: const CellVisual(
      background: Color(0xFF1A3050),
      borderColor: Color(0xFF3A6090),
    ),
    cellHover: const CellVisual(
      background: Color(0xFF1E3E5A),
      borderColor: Color(0xFF5A8AB0),
      borderWidth: 1.5,
      shadows: [BoxShadow(color: Color(0x52508CB4), blurRadius: 12)],
    ),
    cellHit: const CellVisual(
      background: Color(0xFFE86010),
      borderColor: Color(0xFFFF8030),
      borderWidth: 1.5,
      shadows: [BoxShadow(color: Color(0x73F06414), blurRadius: 8)],
    ),
    cellSunk: const CellVisual(
      background: Color(0xFFB04008),
      borderColor: Color(0xFFE05010),
      borderWidth: 1.5,
      shadows: [BoxShadow(color: Color(0x80F06414), blurRadius: 12, spreadRadius: 1)],
    ),
    cellMiss: const CellVisual(
      background: Color(0xFFD0E8F8),
      borderColor: Color(0xFFA8C8E8),
    ),
    cellBlocked: const CellVisual(
      background: Color(0xFF081420),
      borderColor: Color(0xFF162236),
    ),
    hitIcon: CellIconKind.burst8,
    hitIconColor: const Color(0xFF1A0800),
    missIcon: CellIconKind.wave,
    missIconColor: const Color(0xFF0C1B30),
    axisLabel: GoogleFonts.spaceMono(
      fontSize: AppDimensions.axisFs,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF3A5870),
      letterSpacing: 0.025 * AppDimensions.axisFs,
    ),
    axisLabelActive: GoogleFonts.spaceMono(
      fontSize: AppDimensions.axisFs,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFC8A030),
      letterSpacing: 0.025 * AppDimensions.axisFs,
    ),
    axisUppercase: false,
  );

  // ── 3. Fluffy — Candy Tiles ─────────────────────────────────────────────────
  static final BoardStyleConfig _fluffy = BoardStyleConfig(
    id: BoardVisualStyle.candyFluffy,
    boardBackground: const Color(0xFFFFF3F8),
    scanlines: false,
    scanlineColor: const Color(0x00000000),
    cellDefault: const CellVisual(
      background: Color(0xFFFFFFFF),
      borderColor: Color(0xFFFFD0E8),
      borderWidth: 1.5,
      shadows: [BoxShadow(color: Color(0x12FF508C), blurRadius: 10, offset: Offset(0, 3))],
    ),
    cellPath: const CellVisual(
      background: Color(0xFFFFE8F4),
      borderColor: Color(0xFFFFAAD4),
      borderWidth: 1.5,
      shadows: [BoxShadow(color: Color(0x1AFF5096), blurRadius: 8, offset: Offset(0, 2))],
    ),
    cellHover: const CellVisual(
      background: Color(0xFFFFC8E8),
      borderColor: Color(0xFFFF60BE),
      borderWidth: 1.5,
      shadows: [BoxShadow(color: Color(0x52FF28A0), blurRadius: 16, offset: Offset(0, 4))],
    ),
    cellHit: const CellVisual(
      background: Color(0xFFFF3CAB),
      borderColor: Color(0xFFE800A0),
      borderWidth: 1.5,
      shadows: [BoxShadow(color: Color(0x66FF3CAA), blurRadius: 14, offset: Offset(0, 3))],
    ),
    cellSunk: const CellVisual(
      background: Color(0xFFE0008C),
      borderColor: Color(0xFFB00060),
      borderWidth: 1.5,
      shadows: [BoxShadow(color: Color(0x80E0008C), blurRadius: 16, offset: Offset(0, 4))],
    ),
    cellMiss: const CellVisual(
      background: Color(0xFFB8E4FF),
      borderColor: Color(0xFF80C4F8),
      borderWidth: 1.5,
      shadows: [BoxShadow(color: Color(0x263C96FF), blurRadius: 8, offset: Offset(0, 2))],
    ),
    cellBlocked: const CellVisual(
      background: Color(0xFFEDE8FF),
      borderColor: Color(0xFFC8B8F0),
      borderWidth: 1.5,
    ),
    hitIcon: CellIconKind.sparkle,
    hitIconColor: const Color(0xFFFFFFFF),
    missIcon: CellIconKind.teardrop,
    missIconColor: const Color(0xFF2A80D0),
    axisLabel: GoogleFonts.nunito(
      fontSize: AppDimensions.axisFs,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFDDB0C8),
      letterSpacing: 0.025 * AppDimensions.axisFs,
    ),
    axisLabelActive: GoogleFonts.nunito(
      fontSize: AppDimensions.axisFs,
      fontWeight: FontWeight.w900,
      color: const Color(0xFFFF3CAB),
      letterSpacing: 0.025 * AppDimensions.axisFs,
    ),
    axisUppercase: false,
  );

  // ── 4. Futuristic — Grid Scan ───────────────────────────────────────────────
  static final BoardStyleConfig _future = BoardStyleConfig(
    id: BoardVisualStyle.gridScan,
    boardBackground: const Color(0xFF000000),
    scanlines: true,
    scanlineColor: const Color(0x0A00FF64), // rgba(0,255,100,.04)
    cellDefault: const CellVisual(
      background: Color(0xFF000000),
      borderColor: Color(0x3300FF88), // rgba(0,255,136,.20)
    ),
    cellPath: const CellVisual(
      background: Color(0xFF001400),
      borderColor: Color(0x8C00FF88), // rgba(0,255,136,.55)
    ),
    cellHover: const CellVisual(
      background: Color(0xFF001C00),
      borderColor: Color(0xFF00FF88),
      borderWidth: 1.5,
      shadows: [BoxShadow(color: Color(0x4700FF88), blurRadius: 16)],
    ),
    cellHit: const CellVisual(
      background: Color(0xFF0C0000),
      borderColor: Color(0xFFFF0066),
      borderWidth: 1.5,
      shadows: [BoxShadow(color: Color(0x73FF0050), blurRadius: 22)],
    ),
    cellSunk: const CellVisual(
      background: Color(0xFF1A0008),
      borderColor: Color(0xFFFF1480),
      borderWidth: 1.5,
      shadows: [BoxShadow(color: Color(0x99FF0066), blurRadius: 22, spreadRadius: 1)],
    ),
    cellMiss: const CellVisual(
      background: Color(0xFF000000),
      borderColor: Color(0x7A00FF88), // rgba(0,255,136,.48)
    ),
    cellBlocked: const CellVisual(
      background: Color(0xFF080808),
      borderColor: Color(0x1200FF88), // rgba(0,255,136,.07)
    ),
    hitIcon: CellIconKind.radarBlip,
    hitIconColor: const Color(0xFFFF0066),
    missIcon: CellIconKind.miniDiamond,
    missIconColor: const Color(0xB300FF88), // .7 alpha
    axisLabel: GoogleFonts.rajdhani(
      fontSize: AppDimensions.axisFs,
      fontWeight: FontWeight.w500,
      color: const Color(0x4700FF88), // rgba(0,255,136,.28)
      letterSpacing: 0.08 * AppDimensions.axisFs,
    ),
    axisLabelActive: GoogleFonts.rajdhani(
      fontSize: AppDimensions.axisFs,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF00FF88),
      letterSpacing: 0.08 * AppDimensions.axisFs,
    ),
    axisUppercase: true,
  );
}

