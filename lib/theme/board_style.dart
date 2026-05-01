import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';

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

enum CellIconKind {
  // Two thick rounded diagonals — Modern hit. Mirrors basics/Board Variants.html
  // `InkX` (viewBox 20×20, strokeWidth 3.6, strokeLinecap round).
  inkX,
  // Crosshair (4 segments + center circle) — kept as a separate kind in case a
  // future style wants the "scope" look. Not used by Modern anymore.
  inkCross,
  ring,
  burst8,
  wave,
  sparkle,
  teardrop,
  radarBlip,
  miniDiamond,
}

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

// ═════════════════════════════════════════════════════════════════════════════
// Cell icon painters
//
// Each painter is fed a normalized (size, color) and renders the SVG-equivalent
// shape from basics/Board Variants.html. Painters are stateless and cheap to
// rebuild — they take the icon color through the constructor so a single
// dispatcher widget can reuse them across cells.
// ═════════════════════════════════════════════════════════════════════════════

class CellIconPainter extends CustomPainter {
  final CellIconKind kind;
  final Color color;

  const CellIconPainter({required this.kind, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case CellIconKind.inkX:
        _paintInkX(canvas, size);
        break;
      case CellIconKind.inkCross:
        _paintInkCross(canvas, size);
        break;
      case CellIconKind.ring:
        _paintRing(canvas, size);
        break;
      case CellIconKind.burst8:
        _paintBurst8(canvas, size);
        break;
      case CellIconKind.wave:
        _paintWave(canvas, size);
        break;
      case CellIconKind.sparkle:
        _paintSparkle(canvas, size);
        break;
      case CellIconKind.teardrop:
        _paintTeardrop(canvas, size);
        break;
      case CellIconKind.radarBlip:
        _paintRadarBlip(canvas, size);
        break;
      case CellIconKind.miniDiamond:
        _paintMiniDiamond(canvas, size);
        break;
    }
  }

  // Modern: simple ink-stamp X — two thick rounded diagonals, no center pip.
  // Mirrors HTML `InkX` (viewBox 20×20, strokeWidth 3.6, strokeLinecap round).
  void _paintInkX(Canvas canvas, Size size) {
    final f = size.width / 20;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.6 * f
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(3.5 * f, 3.5 * f), Offset(16.5 * f, 16.5 * f), paint);
    canvas.drawLine(Offset(16.5 * f, 3.5 * f), Offset(3.5 * f, 16.5 * f), paint);
  }

  // Crosshair: 4 segments + center circle. Kept available for any future
  // theme that wants a "scope" mark — Modern no longer uses it.
  void _paintInkCross(Canvas canvas, Size size) {
    final f = size.width / 20;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.65 * f
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Crosshair: 4 segments + center circle (matches old _CrosshairPainter).
    canvas.drawLine(Offset(cx, 2.5 * f), Offset(cx, 7.0 * f), paint);
    canvas.drawLine(Offset(cx, 13.0 * f), Offset(cx, 17.5 * f), paint);
    canvas.drawLine(Offset(2.5 * f, cy), Offset(7.0 * f, cy), paint);
    canvas.drawLine(Offset(13.0 * f, cy), Offset(17.5 * f, cy), paint);
    canvas.drawCircle(Offset(cx, cy), 3.2 * f, paint);
  }

  // Modern: thin ring — viewBox 16×16, r=5.5, strokeWidth 1.5.
  void _paintRing(Canvas canvas, Size size) {
    final f = size.width / 16;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5 * f
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 5.5 * f, paint);
  }

  // Retro: 8-point burst — polygon, filled.
  void _paintBurst8(Canvas canvas, Size size) {
    final f = size.width / 20;
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    const pts = <Offset>[
      Offset(10, 1.5),
      Offset(11.6, 7),
      Offset(17.2, 4.8),
      Offset(13.5, 9.5),
      Offset(18.8, 10.8),
      Offset(13.5, 12),
      Offset(17.2, 16.5),
      Offset(11.6, 14),
      Offset(10, 19.5),
      Offset(8.4, 14),
      Offset(2.8, 16.5),
      Offset(6.5, 12),
      Offset(1.2, 10.8),
      Offset(6.5, 9.5),
      Offset(2.8, 4.8),
      Offset(8.4, 7),
    ];
    final path = Path()..moveTo(pts.first.dx * f, pts.first.dy * f);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx * f, pts[i].dy * f);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // Retro: wave — 18×14 viewBox; quadratic curves up/down.
  void _paintWave(Canvas canvas, Size size) {
    final fx = size.width / 18;
    final fy = size.height / 14;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4 * fx
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(1 * fx, 7 * fy)
      ..quadraticBezierTo(3.5 * fx, 2 * fy, 7 * fx, 7 * fy)
      ..quadraticBezierTo(10.5 * fx, 12 * fy, 14 * fx, 7 * fy)
      ..quadraticBezierTo(16 * fx, 4 * fy, 17 * fx, 7 * fy);
    canvas.drawPath(path, paint);
  }

  // Fluffy: 4-point sparkle.
  void _paintSparkle(Canvas canvas, Size size) {
    final f = size.width / 20;
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(10 * f, 1 * f)
      ..lineTo(11.4 * f, 8.6 * f)
      ..lineTo(19 * f, 10 * f)
      ..lineTo(11.4 * f, 11.4 * f)
      ..lineTo(10 * f, 19 * f)
      ..lineTo(8.6 * f, 11.4 * f)
      ..lineTo(1 * f, 10 * f)
      ..lineTo(8.6 * f, 8.6 * f)
      ..close();
    canvas.drawPath(path, paint);
  }

  // Fluffy: teardrop — 13×16 viewBox.
  void _paintTeardrop(Canvas canvas, Size size) {
    final fx = size.width / 13;
    final fy = size.height / 16;
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(6.5 * fx, 1 * fy)
      ..quadraticBezierTo(11 * fx, 7 * fy, 11 * fx, 11 * fy)
      ..arcToPoint(Offset(2 * fx, 11 * fy),
          radius: Radius.elliptical(4.5 * fx, 4.5 * fy), clockwise: false)
      ..quadraticBezierTo(2 * fx, 7 * fy, 6.5 * fx, 1 * fy)
      ..close();
    canvas.drawPath(path, paint);
  }

  // Futuristic: radar blip — solid center + 2 fading rings.
  void _paintRadarBlip(Canvas canvas, Size size) {
    final f = size.width / 20;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final fill = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 2.5 * f, fill);
    final ring1 = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 1 * f
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), 5.5 * f, ring1);
    final ring2 = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..strokeWidth = 0.8 * f
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), 8.5 * f, ring2);
  }

  // Futuristic: small diamond marker.
  void _paintMiniDiamond(Canvas canvas, Size size) {
    final f = size.width / 10;
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(5 * f, 0.5 * f)
      ..lineTo(9.5 * f, 5 * f)
      ..lineTo(5 * f, 9.5 * f)
      ..lineTo(0.5 * f, 5 * f)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CellIconPainter old) =>
      old.kind != kind || old.color != color;
}

// ═════════════════════════════════════════════════════════════════════════════
// Returns a sensible fractional size for a cell-state icon.
// Hit icons are slightly larger than miss icons across all themes — this
// matches the reference HTML and keeps the visual hierarchy intact.
// ═════════════════════════════════════════════════════════════════════════════

double iconFractionFor(CellIconKind kind) {
  switch (kind) {
    case CellIconKind.inkX:
      return 0.50;
    case CellIconKind.inkCross:
      return 0.52;
    case CellIconKind.ring:
      return 0.50;
    case CellIconKind.burst8:
    case CellIconKind.sparkle:
      return 0.62;
    case CellIconKind.wave:
      return 0.58;
    case CellIconKind.teardrop:
      return 0.46;
    case CellIconKind.radarBlip:
      return 0.78;
    case CellIconKind.miniDiamond:
      return 0.32;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Subtle scanline overlay used by the Futuristic style. Stateless painter so
// it can be reused across rebuilds without allocation.
// ═════════════════════════════════════════════════════════════════════════════

class ScanlineOverlayPainter extends CustomPainter {
  final Color color;
  const ScanlineOverlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // 1-px line every 4 px — matches the CSS gradient stop pattern.
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y + 3, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(ScanlineOverlayPainter old) => old.color != color;
}

// ═════════════════════════════════════════════════════════════════════════════
// Diagonal hatch overlay — used by Modern's blocked cells. Reproduces
// `repeating-linear-gradient(45deg, base 0, base 4px, stripe 4px, stripe 8px)`
// from the HTML reference: a 4-px stripe of [color] every 8 px at 45°,
// painted on top of the cell's solid background.
// ═════════════════════════════════════════════════════════════════════════════

class DiagonalHatchPainter extends CustomPainter {
  final Color color;
  const DiagonalHatchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    // Lines run from (offset, 0) → (offset + size.height, size.height): a
    // 45° slope. Step 8 px so 4-px-thick stripes leave 4-px gaps in between.
    for (double offset = -size.height; offset <= size.width; offset += 8) {
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DiagonalHatchPainter old) => old.color != color;
}
