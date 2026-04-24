import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/board_service.dart';

class GameProvider extends Notifier<SoloGameState> {
  @override
  SoloGameState build() {
    return _createInitialState();
  }

  static SoloGameState _createInitialState() {
    final result = BoardService.createNewGameBoard();
    return SoloGameState(
      board: result.board,
      ships: result.ships,
      movesCount: 0,
      hitsCount: 0,
      isFinished: false,
      columnNouns: result.columnNouns,
      rowAdjectives: result.rowAdjectives,
      // TODO: Wire classic/random mode to a future UI switch.
      currentMode: WordPairMode.classic,
    );
  }

  void handleCellClick(int row, int col) {
    if (state.isFinished) return;

    final cell = state.board[row][col];
    if (cell.status != CellStatus.defaultValue) return;

    final newBoard = _updateBoardCell(row, col);
    final newStatus = cell.hasShip ? CellStatus.hit : CellStatus.miss;
    final updatedBoard = _setCellStatus(newBoard, row, col, newStatus);

    final updatedShips = _markSunkShips(state.ships, updatedBoard);
    final newlySunkShip = _findNewlySunkShip(state.ships, updatedShips);
    final finalBoard = newlySunkShip == null
        ? updatedBoard
        : _blockSunkShipNeighbours(updatedBoard, newlySunkShip);
    final newMovesCount = state.movesCount + 1;
    final hitsCount = state.hitsCount + (cell.hasShip ? 1 : 0);
    final lastMoveMessage = _buildMoveMessage(cell);
    final lastMoves = _appendMoveLog(cell);
    final interestCells = newlySunkShip != null
        ? const <BoardPosition>{}
        : cell.hasShip
        ? _buildInterestCells(finalBoard, row, col)
        : _removeInterestCell(row, col);
    final lastSunkMessage = newlySunkShip == null
        ? null
        : _buildSunkMessage(newlySunkShip, finalBoard);
    final isFinished = updatedShips.every((ship) => ship.sunk);
    final victorySummary = isFinished
        ? _buildVictorySummary(
            movesCount: newMovesCount,
            hitsCount: hitsCount,
            lastSunkMessage: lastSunkMessage,
          )
        : null;

    state = state.copyWith(
      board: finalBoard,
      ships: updatedShips,
      movesCount: newMovesCount,
      hitsCount: hitsCount,
      isFinished: isFinished,
      lastMoveMessage: lastMoveMessage,
      lastSunkMessage: lastSunkMessage,
      victorySummary: victorySummary,
      lastMoves: lastMoves,
      interestCells: interestCells,
      clearLastSunkMessage: lastSunkMessage == null,
    );
  }

  void resetGame() {
    state = _createInitialState();
  }

  List<List<Cell>> _updateBoardCell(int row, int col) {
    final newBoard = <List<Cell>>[];
    for (int r = 0; r < state.board.length; r++) {
      final newRow = <Cell>[];
      for (int c = 0; c < state.board[r].length; c++) {
        newRow.add(state.board[r][c]);
      }
      newBoard.add(newRow);
    }
    return newBoard;
  }

  List<List<Cell>> _setCellStatus(
    List<List<Cell>> board,
    int row,
    int col,
    CellStatus status,
  ) {
    final cell = board[row][col];
    board[row][col] = cell.copyWith(status: status);
    return board;
  }

  List<Ship> _markSunkShips(List<Ship> ships, List<List<Cell>> board) {
    return ships.map((ship) {
      final allHit = ship.cells.every(
        (shipCell) =>
            board[shipCell.row][shipCell.col].status == CellStatus.hit,
      );
      return ship.copyWith(sunk: allHit);
    }).toList();
  }

  Ship? _findNewlySunkShip(List<Ship> previousShips, List<Ship> updatedShips) {
    for (final ship in updatedShips) {
      final previousShip = previousShips.firstWhere(
        (candidate) => candidate.id == ship.id,
      );
      if (!previousShip.sunk && ship.sunk) {
        return ship;
      }
    }
    return null;
  }

  List<List<Cell>> _blockSunkShipNeighbours(List<List<Cell>> board, Ship ship) {
    final shipPositions = ship.cells
        .map((cell) => BoardPosition(row: cell.row, col: cell.col))
        .toSet();

    for (final shipCell in ship.cells) {
      for (var row = shipCell.row - 1; row <= shipCell.row + 1; row++) {
        if (row < 0 || row >= board.length) continue;

        for (var col = shipCell.col - 1; col <= shipCell.col + 1; col++) {
          if (col < 0 || col >= board[row].length) continue;
          if (shipPositions.contains(BoardPosition(row: row, col: col))) {
            continue;
          }

          final cell = board[row][col];
          if (!cell.hasShip && cell.status == CellStatus.defaultValue) {
            board[row][col] = cell.copyWith(status: CellStatus.blocked);
          }
        }
      }
    }

    return board;
  }

  String _buildMoveMessage(Cell cell) {
    // Message wording can be varied by state.currentMode later when "Режим
    // Рандом" gets a UI switch.
    final result = cell.hasShip ? 'Попадание' : 'Промах';
    return '$result: ${cell.word}';
  }

  List<MoveLogEntry> _appendMoveLog(Cell cell) {
    final nextMoves = [
      MoveLogEntry(phrase: cell.word, isHit: cell.hasShip),
      ...state.lastMoves,
    ];
    return nextMoves.take(SoloGameState.moveLogLimit).toList();
  }

  Set<BoardPosition> _buildInterestCells(
    List<List<Cell>> board,
    int row,
    int col,
  ) {
    final candidates = [
      BoardPosition(row: row - 1, col: col),
      BoardPosition(row: row + 1, col: col),
      BoardPosition(row: row, col: col - 1),
      BoardPosition(row: row, col: col + 1),
    ];

    return candidates.where((position) {
      if (position.row < 0 || position.row >= board.length) return false;
      if (position.col < 0 || position.col >= board[position.row].length) {
        return false;
      }
      return board[position.row][position.col].status ==
          CellStatus.defaultValue;
    }).toSet();
  }

  Set<BoardPosition> _removeInterestCell(int row, int col) {
    return state.interestCells
        .where((position) => position.row != row || position.col != col)
        .toSet();
  }

  String _buildSunkMessage(Ship ship, List<List<Cell>> board) {
    return 'Корабль потоплен:\n${_shipPhrases(ship, board).join(' — ')}';
  }

  String _buildVictorySummary({
    required int movesCount,
    required int hitsCount,
    required String? lastSunkMessage,
  }) {
    final buffer = StringBuffer()
      ..writeln('Победа!')
      ..writeln('Ходы: $movesCount')
      ..writeln('Попадания: $hitsCount');

    if (lastSunkMessage != null) {
      final sunkPhrases = lastSunkMessage.split('\n').skip(1).join('\n');
      buffer
        ..writeln()
        ..writeln('Последний потопленный корабль:')
        ..write(sunkPhrases);
    }

    return buffer.toString();
  }

  List<String> _shipPhrases(Ship ship, List<List<Cell>> board) {
    return ship.cells
        .map((shipCell) => board[shipCell.row][shipCell.col].word)
        .toList();
  }
}

// Providers
final gameProvider = NotifierProvider<GameProvider, SoloGameState>(
  GameProvider.new,
);

final totalShipsProvider = Provider<int>((ref) {
  final game = ref.watch(gameProvider);
  return game.ships.length;
});

final shipsLeftProvider = Provider<int>((ref) {
  final game = ref.watch(gameProvider);
  return game.ships.where((ship) => !ship.sunk).length;
});

final sunkShipsCountProvider = Provider<int>((ref) {
  final game = ref.watch(gameProvider);
  return game.ships.where((ship) => ship.sunk).length;
});
