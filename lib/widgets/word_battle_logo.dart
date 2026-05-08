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
    final tokens = context.wbTokens;
    final fontSize = markSize * 0.56;
    final mark = WordBattleMark(size: markSize);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        isDark
            ? Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: tokens.borderSubtle),
                ),
                child: mark,
              )
            : mark,
        SizedBox(width: markSize * 0.33),
        Flexible(
          child: Text.rich(
            TextSpan(
              style: AppTextStyles.hudBrand.copyWith(
                fontSize: fontSize,
                letterSpacing: -0.02 * fontSize,
                color: tokens.text1,
              ),
              children: [
                const TextSpan(text: 'Word'),
                TextSpan(
                  text: 'Battle',
                  style: TextStyle(color: tokens.accent),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

// ── Painter ──────────────────────────────────────────────────────────────────

// Mark geometry shared by static and animated painters.
const _markTopColor = Color(0xFF2A2A28);
const _markRightColor = Color(0xFF2A2A28);
const _markBottomColor = Color(0xFFE5DCC8);
const _markLeftColor = Color(0xFFA6A09A);
const _markSailColor = Color(0xFF3FB6B0);

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

    tri([p(0, 0), p(100, 0), p(50, 50)], _markTopColor);
    tri([p(100, 0), p(100, 100), p(50, 50)], _markRightColor);
    tri([p(100, 100), p(0, 100), p(50, 50)], _markBottomColor);
    tri([p(0, 100), p(0, 0), p(50, 50)], _markLeftColor);
    tri([p(50, 50), p(50, 18), p(72, 46)], _markSailColor);
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) => false;
}

// ── Animated mark ────────────────────────────────────────────────────────────

/// Same square mark as [WordBattleMark], but the four triangles and the sail
/// are assembled sequentially driven by a 0..1 [progress] animation.
class AnimatedWordBattleMark extends StatelessWidget {
  final double size;
  final Animation<double> progress;

  const AnimatedWordBattleMark({
    super.key,
    required this.size,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.12),
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: progress,
          builder: (_, _) =>
              CustomPaint(painter: _AnimatedMarkPainter(progress.value)),
        ),
      ),
    );
  }
}

class _AnimatedMarkPainter extends CustomPainter {
  final double progress;

  _AnimatedMarkPainter(this.progress);

  static double _interval(double t, double start, double end) {
    if (t <= start) return 0.0;
    if (t >= end) return 1.0;
    return (t - start) / (end - start);
  }

  static double _easeOutCubic(double t) {
    final inv = 1 - t;
    return 1 - inv * inv * inv;
  }

  static double _easeOutBack(double t) {
    const c = 1.70158;
    final t1 = t - 1;
    return 1 + (c + 1) * t1 * t1 * t1 + c * t1 * t1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100;
    final sy = size.height / 100;
    final slide = size.width * 0.34;

    Offset p(double x, double y) => Offset(x * sx, y * sy);

    void drawTriangle(
      double t,
      double dx,
      double dy,
      List<Offset> pts,
      Color color,
    ) {
      if (t <= 0) return;
      final eased = _easeOutCubic(t);
      canvas.save();
      canvas.translate(dx * (1 - eased), dy * (1 - eased));
      canvas.drawPath(
        Path()
          ..moveTo(pts[0].dx, pts[0].dy)
          ..lineTo(pts[1].dx, pts[1].dy)
          ..lineTo(pts[2].dx, pts[2].dy)
          ..close(),
        Paint()..color = color.withValues(alpha: eased),
      );
      canvas.restore();
    }

    final topT = _interval(progress, 0.05, 0.38);
    final rightT = _interval(progress, 0.22, 0.55);
    final bottomT = _interval(progress, 0.39, 0.72);
    final leftT = _interval(progress, 0.56, 0.88);
    final sailT = _interval(progress, 0.72, 1.00);

    drawTriangle(topT, 0, -slide, [
      p(0, 0),
      p(100, 0),
      p(50, 50),
    ], _markTopColor);
    drawTriangle(rightT, slide, 0, [
      p(100, 0),
      p(100, 100),
      p(50, 50),
    ], _markRightColor);
    drawTriangle(bottomT, 0, slide, [
      p(100, 100),
      p(0, 100),
      p(50, 50),
    ], _markBottomColor);
    drawTriangle(leftT, -slide, 0, [
      p(0, 100),
      p(0, 0),
      p(50, 50),
    ], _markLeftColor);

    if (sailT > 0) {
      final scale = _easeOutBack(sailT).clamp(0.0, 1.2);
      canvas.save();
      canvas.translate(50 * sx, 50 * sy);
      canvas.scale(scale);
      canvas.translate(-50 * sx, -50 * sy);
      canvas.drawPath(
        Path()
          ..moveTo(50 * sx, 50 * sy)
          ..lineTo(50 * sx, 18 * sy)
          ..lineTo(72 * sx, 46 * sy)
          ..close(),
        Paint()..color = _markSailColor.withValues(alpha: sailT),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedMarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
