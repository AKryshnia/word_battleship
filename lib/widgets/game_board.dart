import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';

class GameBoard extends StatelessWidget {
  final List<List<Cell>> board;
  final Function(int row, int col, String word) onCellClick;

  const GameBoard({super.key, required this.board, required this.onCellClick});

  @override
  Widget build(BuildContext context) {
    final boardSize = board.length;
    final isMobileBoard = boardSize <= 6;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: boardSize,
            crossAxisSpacing: isMobileBoard ? 2 : 4,
            mainAxisSpacing: isMobileBoard ? 2 : 4,
          ),
          itemCount: boardSize * boardSize,
          itemBuilder: (context, index) {
            final row = index ~/ boardSize;
            final col = index % boardSize;
            final cell = board[row][col];

            return _CellWidget(
              cell: cell,
              onTap: () => onCellClick(row, col, cell.word),
              isMobileBoard: isMobileBoard,
            );
          },
        ),
      ),
    );
  }
}

class _CellWidget extends StatelessWidget {
  final Cell cell;
  final VoidCallback onTap;
  final bool isMobileBoard;

  const _CellWidget({
    required this.cell,
    required this.onTap,
    required this.isMobileBoard,
  });

  @override
  Widget build(BuildContext context) {
    final cellSize = isMobileBoard ? 40.0 : 50.0;

    return GestureDetector(
      onTap: cell.status == CellStatus.defaultValue ? onTap : null,
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: _getCellColor(),
          borderRadius: BorderRadius.circular(isMobileBoard ? 4 : 8),
          border: Border.all(color: _getBorderColor(), width: 1),
          boxShadow: [
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
        if (isMobileBoard) {
          return null; // No text on mobile for cleaner look
        }
        return Text(
          cell.word.split(' ')[1], // Show only noun on desktop
          style: GoogleFonts.poppins(
            fontSize: isMobileBoard ? 8 : 10,
            fontWeight: FontWeight.w500,
            color: Colors.blue[800],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
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
