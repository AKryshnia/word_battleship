import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/board_service.dart';
import '../services/storage_service.dart';

class GameProvider extends Notifier<SoloGameState> {
  GameProvider({this.initial});

  final SoloGameState? initial;

  @override
  SoloGameState build() {
    return initial ?? _createInitialState();
  }

  void _persist() {
    unawaited(StorageService.saveGameState(state).catchError((_) {}));
  }

  static SoloGameState _createInitialState([
    LayoutProfile profile = LayoutProfile.medium,
  ]) {
    final result = BoardService.createNewGameBoard(
      null,
      WordPairMode.classic,
      profile,
    );
    return SoloGameState(
      board: result.board,
      ships: result.ships,
      movesCount: 0,
      hitsCount: 0,
      isFinished: false,
      columnNouns: result.columnNouns,
      rowAdjectives: result.rowAdjectives,
      currentMode: WordPairMode.classic,
      layoutProfile: profile,
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
        : _markSunkCells(
            _blockSunkShipNeighbours(updatedBoard, newlySunkShip),
            newlySunkShip,
          );
    final newMovesCount = state.movesCount + 1;
    final hitsCount = state.hitsCount + (cell.hasShip ? 1 : 0);
    final lastMoveMessage = _buildMoveMessage(cell);
    final lastMoves = _appendMoveLog(cell);
    final interestCells = cell.hasShip
        ? _buildInterestCells(finalBoard, updatedShips)
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
    _persist();
  }

  void resetGame([LayoutProfile profile = LayoutProfile.medium]) {
    state = _createInitialState(profile);
    _persist();
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
      if (ship.sunk) return ship; // Already sunk — preserve state.
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

  List<List<Cell>> _markSunkCells(List<List<Cell>> board, Ship ship) {
    for (final shipCell in ship.cells) {
      final cell = board[shipCell.row][shipCell.col];
      board[shipCell.row][shipCell.col] = cell.copyWith(
        status: CellStatus.sunk,
      );
    }
    return board;
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
    return [
      MoveLogEntry(phrase: cell.word, isHit: cell.hasShip),
      ...state.lastMoves,
    ];
  }

  /// Computes interest cells from ALL ships that have hit-but-not-sunk cells.
  ///
  /// For each non-sunk ship with ≥1 hit cell:
  ///   - 1 hit  → orthogonal default neighbours.
  ///   - 2+ hits, same row → extend left/right along that row (+ fill gaps).
  ///   - 2+ hits, same col → extend up/down along that col (+ fill gaps).
  ///   - fallback          → orthogonal neighbours of every hit cell.
  Set<BoardPosition> _buildInterestCells(
    List<List<Cell>> board,
    List<Ship> ships,
  ) {
    final result = <BoardPosition>{};
    final rows = board.length;
    final cols = rows > 0 ? board[0].length : 0;

    bool isDefault(int r, int c) {
      if (r < 0 || r >= rows || c < 0 || c >= cols) return false;
      return board[r][c].status == CellStatus.defaultValue;
    }

    void add(int r, int c) {
      if (isDefault(r, c)) result.add(BoardPosition(row: r, col: c));
    }

    for (final ship in ships) {
      if (ship.sunk) continue;
      final hitCells = ship.cells
          .where((sc) => board[sc.row][sc.col].status == CellStatus.hit)
          .toList();
      if (hitCells.isEmpty) continue;

      if (hitCells.length == 1) {
        final r = hitCells[0].row;
        final c = hitCells[0].col;
        add(r - 1, c);
        add(r + 1, c);
        add(r, c - 1);
        add(r, c + 1);
      } else {
        final hitRowSet = hitCells.map((sc) => sc.row).toSet();
        final hitColSet = hitCells.map((sc) => sc.col).toSet();

        if (hitRowSet.length == 1) {
          // Horizontal span
          final r = hitRowSet.first;
          final minC = hitCells
              .map((sc) => sc.col)
              .reduce((a, b) => a < b ? a : b);
          final maxC = hitCells
              .map((sc) => sc.col)
              .reduce((a, b) => a > b ? a : b);
          for (var c = minC; c <= maxC; c++) {
            add(r, c); // gaps in span
          }
          add(r, minC - 1); // left extension
          add(r, maxC + 1); // right extension
        } else if (hitColSet.length == 1) {
          // Vertical span
          final c = hitColSet.first;
          final minR = hitCells
              .map((sc) => sc.row)
              .reduce((a, b) => a < b ? a : b);
          final maxR = hitCells
              .map((sc) => sc.row)
              .reduce((a, b) => a > b ? a : b);
          for (var r = minR; r <= maxR; r++) {
            add(r, c); // gaps in span
          }
          add(minR - 1, c); // top extension
          add(maxR + 1, c); // bottom extension
        } else {
          // Defensive fallback: non-linear pattern (should not occur in valid game)
          for (final sc in hitCells) {
            add(sc.row - 1, sc.col);
            add(sc.row + 1, sc.col);
            add(sc.row, sc.col - 1);
            add(sc.row, sc.col + 1);
          }
        }
      }
    }

    return result;
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
