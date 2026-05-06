import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/board_style.dart';

// Renders a single board cell using the active [BoardStyleConfig].
// Interest cells get an accent overlay so the UX hint works consistently
// across all 4 visual themes.
class BoardCellWidget extends StatelessWidget {
  final Cell cell;
  final bool isInterestCell;
  final bool isActiveCell;
  final bool isRowPath;
  final bool isColPath;
  final BoardStyleConfig style;

  const BoardCellWidget({
    super.key,
    required this.cell,
    required this.isInterestCell,
    required this.isActiveCell,
    required this.isRowPath,
    required this.isColPath,
    required this.style,
  });

  bool get _isPath =>
      (isRowPath || isColPath) && cell.status == CellStatus.defaultValue;

  CellVisual _resolveVisual() {
    if (isActiveCell) return style.cellHover;
    return switch (cell.status) {
      CellStatus.defaultValue => _isPath ? style.cellPath : style.cellDefault,
      CellStatus.hit => style.cellHit,
      CellStatus.sunk => style.cellSunk,
      CellStatus.miss => style.cellMiss,
      CellStatus.blocked => style.cellBlocked,
    };
  }

  @override
  Widget build(BuildContext context) {
    final visual = _resolveVisual();
    final isInterestOverlay =
        isInterestCell &&
        cell.status == CellStatus.defaultValue &&
        !isActiveCell;

    final radius = BorderRadius.circular(AppDimensions.radiusCell);

    return Container(
      decoration: BoxDecoration(
        color: isInterestOverlay
            ? style.cellInterest.background
            : visual.background,
        borderRadius: radius,
        border: Border.all(
          color: isInterestOverlay
              ? style.cellInterest.borderColor
              : visual.borderColor,
          width: visual.borderWidth,
        ),
        boxShadow: isInterestOverlay
            ? style.cellInterest.shadows
            : visual.shadows,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!isInterestOverlay && visual.hatchColor != null)
            ClipRRect(
              borderRadius: radius,
              child: CustomPaint(
                painter: DiagonalHatchPainter(color: visual.hatchColor!),
              ),
            ),
          Center(child: _content()),
        ],
      ),
    );
  }

  Widget? _content() {
    switch (cell.status) {
      case CellStatus.defaultValue:
      case CellStatus.blocked:
        return null;
      case CellStatus.hit:
      case CellStatus.sunk:
        return FractionallySizedBox(
          widthFactor: iconFractionFor(style.hitIcon),
          heightFactor: iconFractionFor(style.hitIcon),
          child: CustomPaint(
            painter: CellIconPainter(
              kind: style.hitIcon,
              color: style.hitIconColor,
            ),
          ),
        );
      case CellStatus.miss:
        return FractionallySizedBox(
          widthFactor: iconFractionFor(style.missIcon),
          heightFactor: iconFractionFor(style.missIcon),
          child: CustomPaint(
            painter: CellIconPainter(
              kind: style.missIcon,
              color: style.missIconColor,
            ),
          ),
        );
    }
  }
}
