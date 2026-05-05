import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Square mark — 4 triangles + teal sail (variant A).
/// Size is the side length of the square in logical pixels.
class WordBattleMark extends StatelessWidget {
  final double size;

  const WordBattleMark({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.12),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _MarkPainter()),
      ),
    );
  }
}

/// Mark + "WordBattle" text in a single row.
/// [markSize] controls the side of the square mark; text scales proportionally.
class WordBattleLogo extends StatelessWidget {
  final double markSize;

  const WordBattleLogo({super.key, required this.markSize});

  @override
  Widget build(BuildContext context) {
    final fontSize = markSize * 0.56;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        WordBattleMark(size: markSize),
        SizedBox(width: markSize * 0.33),
        Text.rich(
          TextSpan(
            style: AppTextStyles.hudBrand.copyWith(
              fontSize: fontSize,
              letterSpacing: -0.02 * fontSize,
            ),
            children: const [
              TextSpan(text: 'Word'),
              TextSpan(
                text: 'Battle',
                style: TextStyle(color: AppColors.accent),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.clip,
          softWrap: false,
        ),
      ],
    );
  }
}

// ── Painter ──────────────────────────────────────────────────────────────────

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100;
    final sy = size.height / 100;

    Offset p(double x, double y) => Offset(x * sx, y * sy);

    void tri(List<Offset> pts, Color color) {
      canvas.drawPath(
        Path()
          ..moveTo(pts[0].dx, pts[0].dy)
          ..lineTo(pts[1].dx, pts[1].dy)
          ..lineTo(pts[2].dx, pts[2].dy)
          ..close(),
        Paint()..color = color,
      );
    }

    tri([p(0, 0), p(100, 0), p(50, 50)], const Color(0xFF2A2A28)); // top
    tri([p(100, 0), p(100, 100), p(50, 50)], const Color(0xFF2A2A28)); // right
    tri([p(100, 100), p(0, 100), p(50, 50)], const Color(0xFFE5DCC8)); // bottom
    tri([p(0, 100), p(0, 0), p(50, 50)], const Color(0xFFA6A09A)); // left
    tri([p(50, 50), p(50, 18), p(72, 46)], const Color(0xFF3FB6B0)); // sail A
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) => false;
}
