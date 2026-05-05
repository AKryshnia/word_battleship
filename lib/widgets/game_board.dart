import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/board_style.dart';
import 'board_axis_headers.dart';
import 'board_cell_widget.dart';

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

class GameBoard extends StatefulWidget {
  final List<List<Cell>> board;
  final List<NounEntry> columnNouns;
  final List<AdjectiveEntry> rowAdjectives;
  final Set<BoardPosition> interestCells;
  final Function(int row, int col, String word) onCellClick;
  final BoardStyleConfig style;

  const GameBoard({
    super.key,
    required this.board,
    required this.columnNouns,
    required this.rowAdjectives,
    required this.interestCells,
    required this.onCellClick,
    required this.style,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _GameBoardState extends State<GameBoard> {
  /// Desktop: position under the cursor.
  BoardPosition? _hover;

  /// Post-fire highlight — stays for [_postClickMs] after any shot.
  BoardPosition? _lastFired;

  Timer? _postClickTimer;

  static const _postClickMs = 700;

  // ------ platform ------

  bool get _isDesktop =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  // ------ active coord (drives all highlights) ------

  BoardPosition? get _activeCoord => _hover ?? _lastFired;

  // ------ lifecycle ------

  @override
  void didUpdateWidget(GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear transient UI state when the board is replaced (reset/new game).
    if (!identical(oldWidget.board, widget.board)) {
      _postClickTimer?.cancel();
      _hover = null;
      _lastFired = null;
    }
  }

  @override
  void dispose() {
    _postClickTimer?.cancel();
    super.dispose();
  }

  // ------ event handlers ------

  void _onCellHoverEnter(int row, int col) {
    if (!_isDesktop) return;
    setState(() => _hover = BoardPosition(row: row, col: col));
  }

  void _onCellHoverExit() {
    if (!_isDesktop) return;
    setState(() => _hover = null);
  }

  void _onCellTap(int row, int col, CellStatus status, String word) {
    if (status != CellStatus.defaultValue) return;
    _fire(row, col, word);
  }

  void _fire(int row, int col, String word) {
    widget.onCellClick(row, col, word);
    _postClickTimer?.cancel();
    setState(() {
      _lastFired = BoardPosition(row: row, col: col);
    });
    _postClickTimer = Timer(const Duration(milliseconds: _postClickMs), () {
      if (mounted) setState(() => _lastFired = null);
    });
  }

  // ------ highlight helpers ------

  bool _isActiveCell(int row, int col) {
    final a = _activeCoord;
    return a != null && a.row == row && a.col == col;
  }

  /// Cells to the left of the active cell in the same row.
  bool _isRowPath(int row, int col) {
    final a = _activeCoord;
    return a != null && row == a.row && col < a.col;
  }

  /// Cells above the active cell in the same column.
  bool _isColPath(int row, int col) {
    final a = _activeCoord;
    return a != null && col == a.col && row < a.row;
  }

  // ------ build ------

  @override
  Widget build(BuildContext context) {
    // The shell (GameShell) provides the card decoration and padding.
    // GameBoard is raw layout content: no outer card, no extra padding.
    return LayoutBuilder(builder: _buildGrid);
  }

  Widget _buildGrid(BuildContext context, BoxConstraints constraints) {
    final boardSize = widget.board.length;
    final style = widget.style;

    // --- layout constants derived from available space + actual vocabulary ---
    final isNarrow = constraints.maxWidth < 460;
    final axisFs =
        (isNarrow ? AppDimensions.axisFsMd : AppDimensions.axisFs) *
        style.axisFontScale;

    // Manrope geometric sans at this size: ~0.65 px per character width.
    final charW = axisFs * 0.65;

    final maxNounLen = widget.columnNouns.isEmpty
        ? 5
        : widget.columnNouns.map((n) => n.word.length).reduce(max);
    final maxAdjLen = widget.rowAdjectives.isEmpty
        ? 8
        : widget.rowAdjectives.map((a) => a.base.length).reduce(max);

    // Column header height = space needed for the rotated noun text.
    final columnHeaderHeight = (maxNounLen * charW + 20).clamp(40.0, 160.0);
    // Row header width = space for horizontal adjective text.
    final rowHeaderWidth = (maxAdjLen * charW + 24).clamp(64.0, 180.0);

    const cellGap = AppDimensions.cellGap;
    const axisGap = 4.0; // gap between axis header and grid

    final maxGridW = constraints.maxWidth - rowHeaderWidth - axisGap;
    final maxGridH = constraints.maxHeight.isFinite
        ? constraints.maxHeight - columnHeaderHeight - axisGap
        : maxGridW;
    final gridSize = min(maxGridW, maxGridH).clamp(0.0, double.infinity);
    final cellSize = (gridSize - cellGap * (boardSize - 1)) / boardSize;

    final activeCol = _activeCoord?.col;
    final activeRow = _activeCoord?.row;

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: rowHeaderWidth + axisGap + gridSize,
        height: columnHeaderHeight + axisGap + gridSize,
        child: Column(
          children: [
            // --- top axis: rotated nouns ---
            SizedBox(
              height: columnHeaderHeight,
              child: Row(
                children: [
                  SizedBox(width: rowHeaderWidth + axisGap),
                  SizedBox(
                    width: gridSize,
                    child: BoardColumnHeaderRow(
                      nouns: widget.columnNouns,
                      cellSize: cellSize,
                      gap: cellGap,
                      axisFs: axisFs,
                      activeIndex: activeCol,
                      headerHeight: columnHeaderHeight,
                      style: style,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: axisGap),
            // --- left axis + grid ---
            Row(
              children: [
                SizedBox(
                  width: rowHeaderWidth,
                  height: gridSize,
                  child: BoardRowHeaderColumn(
                    adjectives: widget.rowAdjectives,
                    cellSize: cellSize,
                    gap: cellGap,
                    axisFs: axisFs,
                    activeIndex: activeRow,
                    style: style,
                  ),
                ),
                const SizedBox(width: axisGap),
                SizedBox(
                  width: gridSize,
                  height: gridSize,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: boardSize,
                      crossAxisSpacing: cellGap,
                      mainAxisSpacing: cellGap,
                    ),
                    itemCount: boardSize * boardSize,
                    itemBuilder: (_, index) {
                      final row = index ~/ boardSize;
                      final col = index % boardSize;
                      final cell = widget.board[row][col];
                      return MouseRegion(
                        onEnter: (_) => _onCellHoverEnter(row, col),
                        onExit: (_) => _onCellHoverExit(),
                        cursor: cell.status == CellStatus.defaultValue
                            ? SystemMouseCursors.click
                            : MouseCursor.defer,
                        child: GestureDetector(
                          onTap: () =>
                              _onCellTap(row, col, cell.status, cell.word),
                          child: BoardCellWidget(
                            cell: cell,
                            isInterestCell: widget.interestCells.contains(
                              BoardPosition(row: row, col: col),
                            ),
                            isActiveCell: _isActiveCell(row, col),
                            isRowPath: _isRowPath(row, col),
                            isColPath: _isColPath(row, col),
                            style: style,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
