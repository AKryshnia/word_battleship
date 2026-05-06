import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/board_style.dart';
import '../widgets/event_strip.dart';
import '../widgets/game_board.dart';
import '../widgets/game_hud_bar.dart';
import '../widgets/move_log_bar.dart';

/// The main card container that wraps all game UI.
/// Mirrors the HTML .shell element: white card, border, shadow, overflow: hidden.
///
/// Internal structure (top to bottom):
///   GameHudBar   — compact 54 px top bar
///   EventStrip   — fixed 56 px event zone (always in layout, board never jumps)
///   Expanded     — board area; fills all remaining space, themed via BoardStyleConfig
///   MoveLogBar   — expandable chips zone; fixed ~88 px when collapsed
class GameShell extends StatelessWidget {
  final SoloGameState gameState;
  final VoidCallback onReset;
  final void Function(int row, int col) onCellClick;
  final BoardVisualStyle boardStyle;
  final ValueChanged<BoardVisualStyle> onStyleChange;

  const GameShell({
    super.key,
    required this.gameState,
    required this.onReset,
    required this.onCellClick,
    required this.boardStyle,
    required this.onStyleChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final styleConfig = isDark
        ? BoardStylePresets.graphiteInk
        : BoardStylePresets.of(boardStyle);
    final tokens = context.wbTokens;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusShell),
        border: Border.all(color: tokens.border),
        boxShadow: isDark
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x0F142864), // rgba(20,40,100,.06)
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
                BoxShadow(
                  color: Color(0x14142864), // rgba(20,40,100,.08)
                  blurRadius: 32,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 480;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar
              GameHudBar(
                gameState: gameState,
                onReset: onReset,
                currentStyle: boardStyle,
                onStyleChange: onStyleChange,
              ),

              // Fixed-height event zone — no layout jumps
              EventStrip(gameState: gameState),

              if (isMobile)
                Expanded(child: _buildMobileGameBlock(styleConfig: styleConfig))
              else ...[
                // Board — takes all remaining height.
                // The board area is given the style's mat color so dark themes
                // render a fully themed surface inside the white shell card.
                Expanded(child: _buildBoardArea(styleConfig: styleConfig)),

                // Collapsed-fixed bottom zone — board never jumps during play
                MoveLogBar(moves: gameState.lastMoves),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileGameBlock({required BoardStyleConfig styleConfig}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const pad = 14.0;
        const targetGap = 14.0;
        final gap = (constraints.maxHeight - AppDimensions.moveLogBarH).clamp(
          0.0,
          targetGap,
        );
        final boardTargetH =
            _estimateBoardContentHeight(
              contentWidth: constraints.maxWidth - pad * 2,
              styleConfig: styleConfig,
            ) +
            pad * 2;
        final maxBoardH =
            constraints.maxHeight - AppDimensions.moveLogBarH - gap;
        final boardH = maxBoardH <= 0
            ? 0.0
            : boardTargetH.clamp(0.0, maxBoardH);

        // Subtract a small buffer so that sub-pixel accumulation from border
        // widths, padding rounding, and platform font metrics never lets
        // MoveLogBar's actual height exceed the remaining column space,
        // which would cause a RenderFlex overflow.
        const layoutSafety = 2.0;
        final availableForLog =
            (constraints.maxHeight - boardH - gap - layoutSafety).clamp(
              AppDimensions.moveLogBarH,
              constraints.maxHeight,
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: boardH,
              child: _buildBoardArea(styleConfig: styleConfig, pad: pad),
            ),
            Container(height: gap, color: styleConfig.boardBackground),
            MoveLogBar(moves: gameState.lastMoves, maxHeight: availableForLog),
            Expanded(child: Container(color: context.wbTokens.surface)),
          ],
        );
      },
    );
  }

  Widget _buildBoardArea({required BoardStyleConfig styleConfig, double? pad}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedPad =
            pad ??
            (constraints.maxWidth < 460 ? 14.0 : AppDimensions.shellPadH);

        return Stack(
          children: [
            Positioned.fill(
              child: Container(color: styleConfig.boardBackground),
            ),
            if (styleConfig.scanlines)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: ScanlineOverlayPainter(
                      color: styleConfig.scanlineColor,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(resolvedPad),
              child: GameBoard(
                board: gameState.board,
                columnNouns: gameState.columnNouns,
                rowAdjectives: gameState.rowAdjectives,
                interestCells: gameState.interestCells,
                onCellClick: (row, col, _) => onCellClick(row, col),
                style: styleConfig,
              ),
            ),
          ],
        );
      },
    );
  }

  double _estimateBoardContentHeight({
    required double contentWidth,
    required BoardStyleConfig styleConfig,
  }) {
    final boardSize = gameState.board.length;
    final maxNounLen = gameState.columnNouns.isEmpty
        ? 5
        : gameState.columnNouns
              .map((noun) => noun.word.length)
              .reduce((a, b) => a > b ? a : b);
    final maxAdjLen = gameState.rowAdjectives.isEmpty
        ? 8
        : gameState.rowAdjectives
              .map((adjective) => adjective.base.length)
              .reduce((a, b) => a > b ? a : b);

    const axisGap = 4.0;
    const cellGap = AppDimensions.cellGap;
    final axisFs = AppDimensions.axisFsMd * styleConfig.axisFontScale;
    final charW = axisFs * 0.65;
    final columnHeaderH = (maxNounLen * charW + 20).clamp(40.0, 160.0);
    final rowHeaderW = (maxAdjLen * charW + 24).clamp(64.0, 180.0);
    final maxGridW = contentWidth - rowHeaderW - axisGap;
    final gridSize = maxGridW.clamp(0.0, double.infinity);
    final cellSize = (gridSize - cellGap * (boardSize - 1)) / boardSize;
    final safeGridSize = cellSize.isFinite && cellSize > 0 ? gridSize : 0.0;

    return columnHeaderH + axisGap + safeGridSize;
  }
}
