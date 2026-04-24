import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';

class GameBoard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final boardSize = board.length;
    final isMobileBoard = boardSize <= 6;
    const gap = 4.0;
    final rowHeaderWidth = isMobileBoard ? 60.0 : 92.0;
    final columnHeaderHeight = isMobileBoard ? 44.0 : 58.0;

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellGap = isMobileBoard ? 2.0 : 4.0;
          final maxGridWidth = constraints.maxWidth - rowHeaderWidth - gap;
          final maxGridHeight =
              constraints.maxHeight - columnHeaderHeight - gap;
          final maxGridSize = maxGridWidth < maxGridHeight
              ? maxGridWidth
              : maxGridHeight;
          final gridSize = maxGridSize.clamp(0.0, double.infinity);
          final cellSize = (gridSize - (cellGap * (boardSize - 1))) / boardSize;

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: rowHeaderWidth + gap + gridSize,
              height: columnHeaderHeight + gap + gridSize,
              child: Column(
                children: [
                  SizedBox(
                    height: columnHeaderHeight,
                    child: Row(
                      children: [
                        SizedBox(width: rowHeaderWidth + gap),
                        SizedBox(
                          width: gridSize,
                          child: _ColumnHeaderRow(
                            nouns: columnNouns,
                            cellSize: cellSize,
                            gap: cellGap,
                            isMobileBoard: isMobileBoard,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: gap),
                  Row(
                    children: [
                      SizedBox(
                        width: rowHeaderWidth,
                        height: gridSize,
                        child: _RowHeaderColumn(
                          adjectives: rowAdjectives,
                          cellSize: cellSize,
                          gap: cellGap,
                          isMobileBoard: isMobileBoard,
                        ),
                      ),
                      const SizedBox(width: gap),
                      SizedBox(
                        width: gridSize,
                        height: gridSize,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: boardSize,
                                crossAxisSpacing: cellGap,
                                mainAxisSpacing: cellGap,
                              ),
                          itemCount: boardSize * boardSize,
                          itemBuilder: (context, index) {
                            final row = index ~/ boardSize;
                            final col = index % boardSize;
                            final cell = board[row][col];

                            return _CellWidget(
                              cell: cell,
                              isInterestCell: interestCells.contains(
                                BoardPosition(row: row, col: col),
                              ),
                              onTap: () => onCellClick(row, col, cell.word),
                              isMobileBoard: isMobileBoard,
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
        },
      ),
    );
  }
}

class _ColumnHeaderRow extends StatelessWidget {
  final List<NounEntry> nouns;
  final double cellSize;
  final double gap;
  final bool isMobileBoard;

  const _ColumnHeaderRow({
    required this.nouns,
    required this.cellSize,
    required this.gap,
    required this.isMobileBoard,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < nouns.length; index++) ...[
          SizedBox(
            width: cellSize,
            child: Text(
              _wrapRuWord(nouns[index].word),
              style: GoogleFonts.poppins(
                fontSize: isMobileBoard ? 10 : 12,
                height: 1.05,
                fontWeight: FontWeight.w600,
                color: Colors.blue[900],
              ),
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
          if (index != nouns.length - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}

class _RowHeaderColumn extends StatelessWidget {
  final List<AdjectiveEntry> adjectives;
  final double cellSize;
  final double gap;
  final bool isMobileBoard;

  const _RowHeaderColumn({
    required this.adjectives,
    required this.cellSize,
    required this.gap,
    required this.isMobileBoard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < adjectives.length; index++) ...[
          SizedBox(
            height: cellSize,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: isMobileBoard ? 4 : 8),
                child: Text(
                  _wrapRuWord(adjectives[index].base),
                  style: GoogleFonts.poppins(
                    fontSize: isMobileBoard ? 10 : 12,
                    height: 1.05,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey[700],
                  ),
                  textAlign: TextAlign.right,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ),
          if (index != adjectives.length - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}

String _wrapRuWord(String word) {
  if (word.length < 7) return word;

  final buffer = StringBuffer();
  const breakOpportunity = '\u200B';
  const vowels = 'аеёиоуыэюя';

  for (var index = 0; index < word.length; index++) {
    buffer.write(word[index]);

    final canBreak =
        index >= 2 &&
        index <= word.length - 4 &&
        vowels.contains(word[index].toLowerCase()) &&
        !vowels.contains(word[index + 1].toLowerCase());

    if (canBreak) {
      buffer.write(breakOpportunity);
    }
  }

  return buffer.toString();
}

class _CellWidget extends StatelessWidget {
  final Cell cell;
  final bool isInterestCell;
  final VoidCallback onTap;
  final bool isMobileBoard;

  const _CellWidget({
    required this.cell,
    required this.isInterestCell,
    required this.onTap,
    required this.isMobileBoard,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: cell.status == CellStatus.defaultValue ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: _getCellColor(),
          borderRadius: BorderRadius.circular(isMobileBoard ? 4 : 8),
          border: Border.all(
            color: _getBorderColor(),
            width: isInterestCell ? 2 : 1,
          ),
          boxShadow: [
            if (isInterestCell)
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.35),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            if (cell.status == CellStatus.defaultValue)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Center(child: _getCellContent()),
      ),
    );
  }

  Color _getCellColor() {
    if (isInterestCell) {
      return Colors.amber[50]!;
    }

    switch (cell.status) {
      case CellStatus.defaultValue:
        return Colors.blue[50]!;
      case CellStatus.hit:
        return Colors.red[400]!;
      case CellStatus.miss:
        return Colors.grey[300]!;
      case CellStatus.blocked:
        return Colors.grey[400]!;
    }
  }

  Color _getBorderColor() {
    if (isInterestCell) {
      return Colors.amber[700]!;
    }

    switch (cell.status) {
      case CellStatus.defaultValue:
        return Colors.blue[200]!;
      case CellStatus.hit:
        return Colors.red[600]!;
      case CellStatus.miss:
        return Colors.grey[400]!;
      case CellStatus.blocked:
        return Colors.grey[500]!;
    }
  }

  Widget? _getCellContent() {
    switch (cell.status) {
      case CellStatus.defaultValue:
        return null;
      case CellStatus.hit:
        return Icon(
          Icons.gps_fixed,
          size: isMobileBoard ? 16 : 20,
          color: Colors.white,
        );
      case CellStatus.miss:
        return Icon(
          Icons.close,
          size: isMobileBoard ? 16 : 20,
          color: Colors.grey[600],
        );
      case CellStatus.blocked:
        return Icon(
          Icons.block,
          size: isMobileBoard ? 16 : 20,
          color: Colors.grey[700],
        );
    }
  }
}
