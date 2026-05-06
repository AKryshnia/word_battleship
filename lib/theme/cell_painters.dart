import 'package:flutter/material.dart';

// Kinds of icon drawn inside a revealed cell. Each style preset picks two:
// one for hit/sunk and one for miss.
enum CellIconKind {
  // Two thick rounded diagonals — Modern/Graphite hit.
  // Mirrors basics/Board Variants.html `InkX` (viewBox 20×20, strokeWidth 3.6).
  inkX,
  // Thin circle — Modern/Graphite miss.
  ring,
  // 4-point sparkle — Fluffy hit.
  sparkle,
  // Teardrop — Fluffy miss.
  teardrop,
}

// Returns a sensible fractional size for a cell-state icon.
// Hit icons are slightly larger than miss icons across all themes — this
// matches the reference HTML and keeps the visual hierarchy intact.
double iconFractionFor(CellIconKind kind) {
  switch (kind) {
    case CellIconKind.inkX:
      return 0.50;
    case CellIconKind.ring:
      return 0.50;
    case CellIconKind.sparkle:
      return 0.62;
    case CellIconKind.teardrop:
      return 0.46;
  }
}

// Dispatches painting to the correct per-kind method. Stateless and cheap to
// rebuild — takes icon color through the constructor so a single dispatcher
// widget can reuse it across cells.
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
      case CellIconKind.ring:
        _paintRing(canvas, size);
        break;
      case CellIconKind.sparkle:
        _paintSparkle(canvas, size);
        break;
      case CellIconKind.teardrop:
        _paintTeardrop(canvas, size);
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
    canvas.drawLine(
      Offset(3.5 * f, 3.5 * f),
      Offset(16.5 * f, 16.5 * f),
      paint,
    );
    canvas.drawLine(
      Offset(16.5 * f, 3.5 * f),
      Offset(3.5 * f, 16.5 * f),
      paint,
    );
  }

  // Modern/Graphite: thin ring — viewBox 16×16, r=5.5, strokeWidth 1.5.
  void _paintRing(Canvas canvas, Size size) {
    final f = size.width / 16;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5 * f
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 5.5 * f, paint);
  }

  // Fluffy: 4-point sparkle.
  void _paintSparkle(Canvas canvas, Size size) {
    final f = size.width / 20;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
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
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(6.5 * fx, 1 * fy)
      ..quadraticBezierTo(11 * fx, 7 * fy, 11 * fx, 11 * fy)
      ..arcToPoint(
        Offset(2 * fx, 11 * fy),
        radius: Radius.elliptical(4.5 * fx, 4.5 * fy),
        clockwise: false,
      )
      ..quadraticBezierTo(2 * fx, 7 * fy, 6.5 * fx, 1 * fy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CellIconPainter old) =>
      old.kind != kind || old.color != color;
}

// Subtle scanline overlay used by the Futuristic style. Stateless painter so
// it can be reused across rebuilds without allocation.
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

// Diagonal hatch overlay — used by Modern's blocked cells. Reproduces
// `repeating-linear-gradient(45deg, base 0, base 4px, stripe 4px, stripe 8px)`
// from the HTML reference: a 4-px stripe of [color] every 8 px at 45°,
// painted on top of the cell's solid background.
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
