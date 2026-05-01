import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
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
///   Expanded     — board area; fills all remaining space
///   MoveLogBar   — expandable chips zone; fixed ~88 px when collapsed
class GameShell extends StatelessWidget {
  final SoloGameState gameState;
  final VoidCallback onReset;
  final void Function(int row, int col) onCellClick;

  const GameShell({
    super.key,
    required this.gameState,
    required this.onReset,
    required this.onCellClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusShell),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top bar
          GameHudBar(gameState: gameState, onReset: onReset),

          // Fixed-height event zone — no layout jumps
          EventStrip(gameState: gameState),

          // Board — takes all remaining height; padding shrinks on narrow shells.
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final pad = constraints.maxWidth < 460
                    ? 14.0
                    : AppDimensions.shellPadH;
                return Padding(
                  padding: EdgeInsets.all(pad),
                  child: GameBoard(
                    board: gameState.board,
                    columnNouns: gameState.columnNouns,
                    rowAdjectives: gameState.rowAdjectives,
                    interestCells: gameState.interestCells,
                    onCellClick: (row, col, _) => onCellClick(row, col),
                  ),
                );
              },
            ),
          ),

          // Collapsed-fixed bottom zone — board never jumps during normal play
          MoveLogBar(moves: gameState.lastMoves),
        ],
      ),
    );
  }
}
