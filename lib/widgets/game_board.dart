import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

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
    // The shell (GameShell) provides the card decoration and padding.
    // GameBoard is raw layout content: no outer card, no extra padding.
    return LayoutBuilder(builder: _buildGrid);
  }

  Widget _buildGrid(BuildContext context, BoxConstraints constraints) {
    final boardSize = widget.board.length;

    // --- layout constants derived from available space + actual vocabulary ---
    final isNarrow = constraints.maxWidth < 460;
    final axisFs = isNarrow ? AppDimensions.axisFsMd : AppDimensions.axisFs;

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
                    child: _ColumnHeaderRow(
                      nouns: widget.columnNouns,
                      cellSize: cellSize,
                      gap: cellGap,
                      axisFs: axisFs,
                      activeIndex: activeCol,
                      headerHeight: columnHeaderHeight,
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
                  child: _RowHeaderColumn(
                    adjectives: widget.rowAdjectives,
                    cellSize: cellSize,
                    gap: cellGap,
                    axisFs: axisFs,
                    activeIndex: activeRow,
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
                          child: _CellWidget(
                            cell: cell,
                            isInterestCell: widget.interestCells.contains(
                              BoardPosition(row: row, col: col),
                            ),
                            isActiveCell: _isActiveCell(row, col),
                            isRowPath: _isRowPath(row, col),
                            isColPath: _isColPath(row, col),
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
  final double axisFs;
  final int? activeIndex;
  final double headerHeight;

  const _ColumnHeaderRow({
    required this.nouns,
    required this.cellSize,
    required this.gap,
    required this.axisFs,
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
              axisFs: axisFs,
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
  final double axisFs;

  const _NounLabel({
    required this.word,
    required this.isActive,
    required this.axisFs,
  });

  @override
  Widget build(BuildContext context) {
    final style = (isActive
            ? AppTextStyles.axisLabelActive
            : AppTextStyles.axisLabel)
        .copyWith(fontSize: axisFs, letterSpacing: 0.025 * axisFs);

    return Center(
      child: RotatedBox(
        // quarterTurns: 3 → 90° CCW → text reads bottom-to-top (tilt head left)
        quarterTurns: 3,
        child: AnimatedDefaultTextStyle(
          style: style,
          duration: const Duration(milliseconds: 100),
          child: Text(
            word,
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
  final double axisFs;
  final int? activeIndex;

  const _RowHeaderColumn({
    required this.adjectives,
    required this.cellSize,
    required this.gap,
    required this.axisFs,
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
              axisFs: axisFs,
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
  final double axisFs;

  const _AdjectiveLabel({
    required this.word,
    required this.isActive,
    required this.axisFs,
  });

  @override
  Widget build(BuildContext context) {
    final style = (isActive
            ? AppTextStyles.axisLabelActive
            : AppTextStyles.axisLabel)
        .copyWith(fontSize: axisFs, letterSpacing: 0.025 * axisFs);

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: AnimatedDefaultTextStyle(
          style: style,
          duration: const Duration(milliseconds: 100),
          child: Text(
            word,
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

  const _CellWidget({
    required this.cell,
    required this.isInterestCell,
    required this.isActiveCell,
    required this.isRowPath,
    required this.isColPath,
  });

  bool get _isPath =>
      (isRowPath || isColPath) && cell.status == CellStatus.defaultValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cellColor(),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCell),
        border: Border.all(
          color: _borderColor(),
          width: isActiveCell ? 1.5 : 1.0,
        ),
        boxShadow: _shadows(),
      ),
      child: Center(child: _content()),
    );
  }

  Color _cellColor() {
    if (isActiveCell) return AppColors.cellHoverBg;
    if (isInterestCell) return AppColors.accentFaint;
    return switch (cell.status) {
      CellStatus.defaultValue =>
        _isPath ? AppColors.cellPathBg : AppColors.cellDefaultBg,
      CellStatus.hit     => AppColors.cellHitBg,
      CellStatus.miss    => AppColors.cellMissBg,
      CellStatus.blocked => AppColors.cellBlockedBg,
      CellStatus.sunk    => AppColors.cellSunkBg,
    };
  }

  Color _borderColor() {
    if (isActiveCell) return AppColors.cellHoverBorder;
    if (isInterestCell) return AppColors.accentMid;
    return switch (cell.status) {
      CellStatus.defaultValue =>
        _isPath ? AppColors.cellPathBorder : AppColors.cellDefaultBorder,
      CellStatus.hit     => AppColors.cellHitBorder,
      CellStatus.miss    => AppColors.cellMissBorder,
      CellStatus.blocked => AppColors.cellBlockedBorder,
      CellStatus.sunk    => AppColors.cellSunkBorder,
    };
  }

  List<BoxShadow> _shadows() {
    if (isActiveCell) {
      return const [BoxShadow(color: AppColors.cellHoverGlow, blurRadius: 8)];
    }
    if (isInterestCell) {
      return const [BoxShadow(color: AppColors.accentFaint, blurRadius: 8)];
    }
    if (cell.status == CellStatus.sunk) {
      // Matches HTML: box-shadow: 0 0 0 2.5px rgba(160,30,20,.22)
      return const [BoxShadow(color: Color(0x37A01E14), spreadRadius: 2.5)];
    }
    return const [];
  }

  Widget? _content() {
    return switch (cell.status) {
      CellStatus.defaultValue => null,
      CellStatus.hit || CellStatus.sunk => const FractionallySizedBox(
        widthFactor: 0.52,
        heightFactor: 0.52,
        child: CustomPaint(painter: _CrosshairPainter()),
      ),
      CellStatus.miss => const FractionallySizedBox(
        widthFactor: 0.50,
        heightFactor: 0.50,
        child: CustomPaint(painter: _MissPainter()),
      ),
      CellStatus.blocked => null,
    };
  }
}

// ---------------------------------------------------------------------------
// × icon — miss cell indicator; symbol-first, not color-first.
// ---------------------------------------------------------------------------

class _MissPainter extends CustomPainter {
  const _MissPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cellMissX
      ..strokeWidth = size.width * 0.13
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final p = size.width * 0.18;
    canvas.drawLine(Offset(p, p), Offset(size.width - p, size.height - p), paint);
    canvas.drawLine(Offset(size.width - p, p), Offset(p, size.height - p), paint);
  }

  @override
  bool shouldRepaint(_MissPainter old) => false;
}

// ---------------------------------------------------------------------------
// Crosshair icon — used for hit and sunk cells.
// Mirrors the SVG symbol in Word Battleship v2.html:
//   4 line segments + circle, 20×20 viewBox, white stroke.
// ---------------------------------------------------------------------------

class _CrosshairPainter extends CustomPainter {
  const _CrosshairPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xD9FFFFFF) // rgba(255,255,255,.85)
      ..strokeWidth = size.width * 0.0825 // proportional to 1.65/20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final f = size.width / 20; // scale factor from 20×20 viewBox
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Vertical segments
    canvas.drawLine(Offset(cx, 2.5 * f), Offset(cx, 7.0 * f), paint);
    canvas.drawLine(Offset(cx, 13.0 * f), Offset(cx, 17.5 * f), paint);
    // Horizontal segments
    canvas.drawLine(Offset(2.5 * f, cy), Offset(7.0 * f, cy), paint);
    canvas.drawLine(Offset(13.0 * f, cy), Offset(17.5 * f, cy), paint);
    // Center circle
    canvas.drawCircle(Offset(cx, cy), 3.2 * f, paint);
  }

  @override
  bool shouldRepaint(_CrosshairPainter oldDelegate) => false;
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
