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
    final hitsCount = state.hitsCount + (cell.hasShip ? 1 : 0);
    final isFinished = updatedShips.every((ship) => ship.sunk);

    state = state.copyWith(
      board: updatedBoard,
      ships: updatedShips,
      movesCount: state.movesCount + 1,
      hitsCount: hitsCount,
      isFinished: isFinished,
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
