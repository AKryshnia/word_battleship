import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

class GameBoard extends StatefulWidget {
  final List<List<Cell>> board;
  final List<NounEntry> columnNouns;
  final List<AdjectiveEntry> rowAdjectives;
  final Set<BoardPosition> interestCells;
  final Function(int row, int col, String word) onCellClick;

  const GameBoard({
    super.key,
    required this.board,
    required this.columnNouns,
    required this.rowAdjectives,
    required this.interestCells,
    required this.onCellClick,
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

  /// Mobile: first-tap selection (second tap fires).
  BoardPosition? _pending;

  /// Post-click highlight — stays for [_postClickMs] after firing.
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

  BoardPosition? get _activeCoord => _hover ?? _pending ?? _lastFired;

  // ------ lifecycle ------

  @override
  void didUpdateWidget(GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear transient UI state when the board is replaced (reset/new game).
    if (!identical(oldWidget.board, widget.board)) {
      _postClickTimer?.cancel();
      _hover = null;
      _pending = null;
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
    if (status != CellStatus.defaultValue) {
      // Tapping a revealed cell clears mobile selection.
      if (!_isDesktop) setState(() => _pending = null);
      return;
    }

    if (_isDesktop) {
      _fire(row, col, word);
    } else {
      final pos = BoardPosition(row: row, col: col);
      if (_pending == pos) {
        _fire(row, col, word); // second tap on same cell
      } else {
        setState(() => _pending = pos); // first tap: select
      }
    }
  }

  void _fire(int row, int col, String word) {
    widget.onCellClick(row, col, word);
    _postClickTimer?.cancel();
    setState(() {
      _pending = null;
      _lastFired = BoardPosition(row: row, col: col);
    });
    _postClickTimer = Timer(
      const Duration(milliseconds: _postClickMs),
      () {
        if (mounted) setState(() => _lastFired = null);
      },
    );
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(builder: _buildGrid),
    );
  }

  Widget _buildGrid(BuildContext context, BoxConstraints constraints) {
    final boardSize = widget.board.length;

    // --- layout constants derived from available space + actual vocabulary ---
    final isNarrow = constraints.maxWidth < 460;
    final fontSize = isNarrow ? 10.0 : 12.0;
    // Poppins geometric sans at this size: ~0.65 px per character width.
    final charW = fontSize * 0.65;

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

    const gap = 4.0;
    final cellGap = isNarrow ? 2.0 : gap;

    final maxGridW = constraints.maxWidth - rowHeaderWidth - gap;
    final maxGridH = constraints.maxHeight.isFinite
        ? constraints.maxHeight - columnHeaderHeight - gap
        : maxGridW;
    final gridSize = min(maxGridW, maxGridH).clamp(0.0, double.infinity);
    final cellSize =
        (gridSize - cellGap * (boardSize - 1)) / boardSize;

    final activeCol = _activeCoord?.col;
    final activeRow = _activeCoord?.row;

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: rowHeaderWidth + gap + gridSize,
        height: columnHeaderHeight + gap + gridSize,
        child: Column(
          children: [
            // --- top axis: rotated nouns ---
            SizedBox(
              height: columnHeaderHeight,
              child: Row(
                children: [
                  SizedBox(width: rowHeaderWidth + gap),
                  SizedBox(
                    width: gridSize,
                    child: _ColumnHeaderRow(
                      nouns: widget.columnNouns,
                      cellSize: cellSize,
                      gap: cellGap,
                      fontSize: fontSize,
                      activeIndex: activeCol,
                      headerHeight: columnHeaderHeight,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: gap),
            // --- left axis + grid ---
            Row(
              children: [
                SizedBox(
                  width: rowHeaderWidth,
                  height: gridSize,
                  child: _RowHeaderColumn(
                    adjectives: widget.rowAdjectives,
                    cellSize: cellSize,
                    gap: cellGap,
                    fontSize: fontSize,
                    activeIndex: activeRow,
                  ),
                ),
                SizedBox(width: gap),
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
                          child: _CellWidget(
                            cell: cell,
                            isInterestCell: widget.interestCells.contains(
                              BoardPosition(row: row, col: col),
                            ),
                            isActiveCell: _isActiveCell(row, col),
                            isRowPath: _isRowPath(row, col),
                            isColPath: _isColPath(row, col),
                            fontSize: fontSize,
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

// ---------------------------------------------------------------------------
// Column header — rotated nouns (bottom-to-top, tilt head left to read)
// ---------------------------------------------------------------------------

class _ColumnHeaderRow extends StatelessWidget {
  final List<NounEntry> nouns;
  final double cellSize;
  final double gap;
  final double fontSize;
  final int? activeIndex;
  final double headerHeight;

  const _ColumnHeaderRow({
    required this.nouns,
    required this.cellSize,
    required this.gap,
    required this.fontSize,
    required this.activeIndex,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < nouns.length; i++) ...[
          SizedBox(
            width: cellSize,
            height: headerHeight,
            child: _NounLabel(
              word: nouns[i].word,
              isActive: i == activeIndex,
              fontSize: fontSize,
              cellWidth: cellSize,
              headerHeight: headerHeight,
            ),
          ),
          if (i < nouns.length - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}

class _NounLabel extends StatelessWidget {
  final String word;
  final bool isActive;
  final double fontSize;
  final double cellWidth;
  final double headerHeight;

  const _NounLabel({
    required this.word,
    required this.isActive,
    required this.fontSize,
    required this.cellWidth,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: isActive
            ? Border.all(color: Colors.blue[400]!, width: 1)
            : null,
      ),
      child: Center(
        child: RotatedBox(
          // quarterTurns: 3 → 90° CCW → text reads bottom-to-top (tilt head left)
          quarterTurns: 3,
          child: Text(
            word,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.blue[900] : Colors.blue[900],
            ),
            overflow: TextOverflow.visible,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Row header — horizontal adjectives
// ---------------------------------------------------------------------------

class _RowHeaderColumn extends StatelessWidget {
  final List<AdjectiveEntry> adjectives;
  final double cellSize;
  final double gap;
  final double fontSize;
  final int? activeIndex;

  const _RowHeaderColumn({
    required this.adjectives,
    required this.cellSize,
    required this.gap,
    required this.fontSize,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < adjectives.length; i++) ...[
          SizedBox(
            height: cellSize,
            child: _AdjectiveLabel(
              word: adjectives[i].base,
              isActive: i == activeIndex,
              fontSize: fontSize,
            ),
          ),
          if (i < adjectives.length - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}

class _AdjectiveLabel extends StatelessWidget {
  final String word;
  final bool isActive;
  final double fontSize;

  const _AdjectiveLabel({
    required this.word,
    required this.isActive,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.blueGrey.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: isActive
            ? Border.all(color: Colors.blueGrey[400]!, width: 1)
            : null,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            word,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.blueGrey[900] : Colors.blueGrey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cell widget
// ---------------------------------------------------------------------------

class _CellWidget extends StatelessWidget {
  final Cell cell;
  final bool isInterestCell;
  final bool isActiveCell;
  final bool isRowPath;
  final bool isColPath;
  final double fontSize;

  const _CellWidget({
    required this.cell,
    required this.isInterestCell,
    required this.isActiveCell,
    required this.isRowPath,
    required this.isColPath,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cellColor(),
        borderRadius: BorderRadius.circular(fontSize < 11 ? 4 : 8),
        border: Border.all(color: _borderColor(), width: isActiveCell ? 2 : 1),
        boxShadow: [
          if (isActiveCell)
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.28),
              blurRadius: 8,
              spreadRadius: 1,
            )
          else if (isInterestCell)
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.35),
              blurRadius: 8,
              spreadRadius: 1,
            )
          else if (cell.status == CellStatus.defaultValue)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Center(child: _content()),
    );
  }

  Color _cellColor() {
    // Priority: active > interest > path (only on default) > status
    if (isActiveCell) return Colors.blue[200]!;
    if (isInterestCell) return Colors.amber[50]!;
    return switch (cell.status) {
      CellStatus.defaultValue =>
        (isRowPath || isColPath) ? Colors.blue[100]! : Colors.blue[50]!,
      CellStatus.hit => Colors.red[400]!,
      CellStatus.miss => Colors.grey[300]!,
      CellStatus.blocked => Colors.grey[400]!,
    };
  }

  Color _borderColor() {
    if (isActiveCell) return Colors.blue[500]!;
    if (isInterestCell) return Colors.amber[700]!;
    return switch (cell.status) {
      CellStatus.defaultValue =>
        (isRowPath || isColPath) ? Colors.blue[300]! : Colors.blue[200]!,
      CellStatus.hit => Colors.red[600]!,
      CellStatus.miss => Colors.grey[400]!,
      CellStatus.blocked => Colors.grey[500]!,
    };
  }

  Widget? _content() {
    final iconSize = fontSize < 11 ? 16.0 : 20.0;
    return switch (cell.status) {
      CellStatus.defaultValue => null,
      CellStatus.hit =>
        Icon(Icons.gps_fixed, size: iconSize, color: Colors.white),
      CellStatus.miss =>
        Icon(Icons.close, size: iconSize, color: Colors.grey[600]),
      CellStatus.blocked =>
        Icon(Icons.block, size: iconSize, color: Colors.grey[700]),
    };
  }
}

// ---------------------------------------------------------------------------
// Kept as a public utility (used by legacy tests; not used in rendering).
// ---------------------------------------------------------------------------

String splitRuLabel(String word) => splitRuLabelParts(word).join('\n');

List<String> splitRuLabelParts(String word) {
  final s = word.trim();
  if (s.length <= 6) return [s];

  const vowels = 'аеёиоуыэюя';
  final minPart = s.length >= 10 ? 4 : 3;
  final target = s.length ~/ 2;
  var best = -1;
  var bestScore = 1 << 30;

  for (var i = minPart; i <= s.length - minPart; i++) {
    final l = s[i - 1].toLowerCase();
    final r = s[i].toLowerCase();
    var score = (target - i).abs() * 10;
    if (vowels.contains(l) && !vowels.contains(r)) {
      score -= 6;
    } else if (!vowels.contains(l) && vowels.contains(r)) {
      score -= 2;
    }
    score += (i - (s.length - i)).abs();
    if (score < bestScore) {
      bestScore = score;
      best = i;
    }
  }

  return best == -1 ? [s] : [s.substring(0, best), s.substring(best)];
}
