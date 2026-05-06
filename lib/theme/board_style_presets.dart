import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'board_style.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Presets
//
// Three active presets, one per app theme variant:
//   modernInk   — Paper (light, Ink on Paper)
//   graphiteInk — Graphite (dark)
//   fluffy      — Fluffy (candy pink)
// Geometry is intentionally inherited from AppDimensions so layout tests and
// responsive math stay valid.
// ═════════════════════════════════════════════════════════════════════════════

class BoardStylePresets {
  const BoardStylePresets._();

  static final BoardStyleConfig modernInk = _modern;
  static final BoardStyleConfig fluffy = _fluffy;

  static final BoardStyleConfig graphiteInk = BoardStyleConfig(
    boardBackground: const Color(0xFF1C1B19),
    scanlines: false,
    scanlineColor: const Color(0x00000000),
    cellDefault: const CellVisual(
      background: Color(0xFF26261F),
      borderColor: Color(0xFF3A3A37),
    ),
    cellPath: const CellVisual(
      background: Color(0xFF2E2E26),
      borderColor: Color(0xFF454540),
    ),
    cellHover: const CellVisual(
      background: Color(0xFF3A3528),
      borderColor: Color(0xFFE2A340),
      borderWidth: 1.5,
      shadows: [BoxShadow(color: Color(0x47E2A340), blurRadius: 14)],
    ),
    cellInterest: const CellVisual(
      background: Color(0x1C3FB6B0),
      borderColor: Color(0x4D3FB6B0),
      shadows: [BoxShadow(color: Color(0x333FB6B0), blurRadius: 8)],
    ),
    cellHit: const CellVisual(
      background: Color(0xFF0E0E0C),
      borderColor: Color(0xFF000000),
    ),
    cellSunk: const CellVisual(
      background: Color(0xFF0E0E0C),
      borderColor: Color(0xFF000000),
      shadows: [BoxShadow(color: Color(0x52DC5A32), spreadRadius: 2)],
    ),
    cellMiss: const CellVisual(
      background: Color(0xFF26261F),
      borderColor: Color(0xFF464640),
    ),
    cellBlocked: const CellVisual(
      background: Color(0xFF1E1E1C),
      borderColor: Color(0xFF2E2E2C),
      hatchColor: Color(0xFF34342F),
    ),
    hitIcon: CellIconKind.inkX,
    hitIconColor: const Color(0xFFFFF8E6),
    missIcon: CellIconKind.ring,
    missIconColor: const Color(0xFF8A8375),
    axisLabel: GoogleFonts.manrope(
      fontSize: AppDimensions.axisFs,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFA0998A),
      letterSpacing: 0.025 * AppDimensions.axisFs,
    ),
    axisLabelActive: GoogleFonts.manrope(
      fontSize: AppDimensions.axisFs,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFE2A340),
      letterSpacing: 0.025 * AppDimensions.axisFs,
    ),
    axisFontScale: 1.1,
    axisUppercase: false,
  );

  // ── 1. Modern — Ink on Paper ────────────────────────────────────────────────
  // Faithful port of the HTML reference T_MODERN preset. Self-contained color
  // values (intentionally NOT wired through AppColors.cellHit/cellMiss/etc) —
  // the legacy AppColors palette is terracotta-tinted, while the reference
  // calls for crisp black-on-white ink. AppColors stays untouched so the rest
  // of the UI (HUD, event strip) keeps its warm tone.
  static final BoardStyleConfig _modern = BoardStyleConfig(
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
      shadows: [
        BoxShadow(
          color: Color(0x2EA06400),
          blurRadius: 14,
          offset: Offset(0, 2),
        ),
      ],
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
      color: const Color(0xFF8F7E69),
      letterSpacing: 0.025 * AppDimensions.axisFs,
    ),
    axisLabelActive: GoogleFonts.manrope(
      fontSize: AppDimensions.axisFs,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFC06A14),
      letterSpacing: 0.025 * AppDimensions.axisFs,
    ),
    axisFontScale: 1.1,
    axisUppercase: false,
  );

  // ── 2. Fluffy — Candy Tiles ─────────────────────────────────────────────────
  static final BoardStyleConfig _fluffy = BoardStyleConfig(
    boardBackground: const Color(0xFFFFF3F8),
    scanlines: false,
    scanlineColor: const Color(0x00000000),
    cellDefault: const CellVisual(
      background: Color(0xFFFFFFFF),
      borderColor: Color(0xFFFFD0E8),
      borderWidth: 1.5,
      shadows: [
        BoxShadow(
          color: Color(0x12FF508C),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    ),
    cellPath: const CellVisual(
      background: Color(0xFFFFE8F4),
      borderColor: Color(0xFFFFAAD4),
      borderWidth: 1.5,
      shadows: [
        BoxShadow(
          color: Color(0x1AFF5096),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    cellHover: const CellVisual(
      background: Color(0xFFFFC8E8),
      borderColor: Color(0xFFFF60BE),
      borderWidth: 1.5,
      shadows: [
        BoxShadow(
          color: Color(0x52FF28A0),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    ),
    cellHit: const CellVisual(
      background: Color(0xFFFF3CAB),
      borderColor: Color(0xFFE800A0),
      borderWidth: 1.5,
      shadows: [
        BoxShadow(
          color: Color(0x66FF3CAA),
          blurRadius: 14,
          offset: Offset(0, 3),
        ),
      ],
    ),
    cellSunk: const CellVisual(
      background: Color(0xFFE0008C),
      borderColor: Color(0xFFB00060),
      borderWidth: 1.5,
      shadows: [
        BoxShadow(
          color: Color(0x80E0008C),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    ),
    cellMiss: const CellVisual(
      background: Color(0xFFB8E4FF),
      borderColor: Color(0xFF80C4F8),
      borderWidth: 1.5,
      shadows: [
        BoxShadow(
          color: Color(0x263C96FF),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
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
}
