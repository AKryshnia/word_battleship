import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'cell_painters.dart';
export 'cell_painters.dart';
export 'board_style_presets.dart';

// ═════════════════════════════════════════════════════════════════════════════
// BoardVisualStyle
//
// Internal identifier stored on BoardStyleConfig. The game logic is completely
// independent from the visual style — this value only names the preset so
// painters and configs can be identified if needed.
// ═════════════════════════════════════════════════════════════════════════════

enum BoardVisualStyle {
  modernInk,
  candyFluffy;

  String get label => switch (this) {
    BoardVisualStyle.modernInk => 'Modern — Ink on Paper',
    BoardVisualStyle.candyFluffy => 'Fluffy — Candy Tiles',
  };

  String get shortLabel => switch (this) {
    BoardVisualStyle.modernInk => 'Modern',
    BoardVisualStyle.candyFluffy => 'Fluffy',
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
  final CellVisual cellInterest;
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
  final double axisFontScale;

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
    this.cellInterest = const CellVisual(
      background: AppColors.accentFaint,
      borderColor: AppColors.accentMid,
      shadows: [BoxShadow(color: AppColors.accentFaint, blurRadius: 8)],
    ),
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
    this.axisFontScale = 1.0,
    required this.axisUppercase,
  });
}
