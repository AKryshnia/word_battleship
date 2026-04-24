import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_battleship/models/models.dart';
import 'package:word_battleship/providers/game_provider.dart';
import 'package:word_battleship/services/board_service.dart';

void main() {
  group('GameProvider word-driven feedback', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('creates move messages for misses and hits', () {
      final initial = container.read(gameProvider);
      final miss = _firstCell(initial, hasShip: false);
      final hit = _firstCell(initial, hasShip: true);

      container.read(gameProvider.notifier).handleCellClick(miss.row, miss.col);
      var state = container.read(gameProvider);
      expect(state.lastMoveMessage, 'Промах: ${miss.word}');
      expect(
        state.lastMoves.first,
        MoveLogEntry(phrase: miss.word, isHit: false),
      );

      container.read(gameProvider.notifier).handleCellClick(hit.row, hit.col);
      state = container.read(gameProvider);
      expect(state.lastMoveMessage, 'Попадание: ${hit.word}');
      expect(
        state.lastMoves.first,
        MoveLogEntry(phrase: hit.word, isHit: true),
      );
    });

    test('highlights unopened orthogonal neighbours after a hit', () {
      final initial = container.read(gameProvider);
      final hit = _shipCell(initial, minShipLength: 2);

      container.read(gameProvider.notifier).handleCellClick(hit.row, hit.col);

      final state = container.read(gameProvider);
      final expectedPositions = _orthogonalDefaultNeighbours(
        state.board,
        hit.row,
        hit.col,
      );
      expect(state.interestCells, expectedPositions);
      expect(
        state.interestCells.contains(BoardPosition(row: hit.row, col: hit.col)),
        isFalse,
      );
    });

    test('creates sunk message when a ship becomes sunk', () {
      final initial = container.read(gameProvider);
      final ship = initial.ships.firstWhere(
        (candidate) => candidate.cells.length == 1,
      );
      final shipCell = ship.cells.first;
      final phrase = initial.board[shipCell.row][shipCell.col].word;

      container
          .read(gameProvider.notifier)
          .handleCellClick(shipCell.row, shipCell.col);

      final state = container.read(gameProvider);
      expect(state.lastSunkMessage, 'Корабль потоплен:\n$phrase');
    });

    test('blocks empty neighbours after a one-cell ship is sunk', () {
      final initial = container.read(gameProvider);
      final ship = initial.ships.firstWhere(
        (candidate) => candidate.cells.length == 1,
      );
      final shipCell = ship.cells.first;
      final expectedBlocked = _adjacentDefaultEmptyNeighbours(
        initial.board,
        shipCell.row,
        shipCell.col,
      );

      container
          .read(gameProvider.notifier)
          .handleCellClick(shipCell.row, shipCell.col);

      final state = container.read(gameProvider);
      expect(expectedBlocked, isNotEmpty);
      for (final position in expectedBlocked) {
        expect(
          state.board[position.row][position.col].status,
          CellStatus.blocked,
        );
      }
    });

    test('clicking a blocked cell does not count as a move', () {
      final initial = container.read(gameProvider);
      final ship = initial.ships.firstWhere(
        (candidate) => candidate.cells.length == 1,
      );
      final shipCell = ship.cells.first;

      container
          .read(gameProvider.notifier)
          .handleCellClick(shipCell.row, shipCell.col);
      final afterSunk = container.read(gameProvider);
      final blockedCell = afterSunk.board
          .expand((row) => row)
          .firstWhere((cell) => cell.status == CellStatus.blocked);
      final movesCount = afterSunk.movesCount;
      final hitsCount = afterSunk.hitsCount;
      final lastMoves = List<MoveLogEntry>.of(afterSunk.lastMoves);
      final lastMoveMessage = afterSunk.lastMoveMessage;

      container
          .read(gameProvider.notifier)
          .handleCellClick(blockedCell.row, blockedCell.col);

      final state = container.read(gameProvider);
      expect(state.movesCount, movesCount);
      expect(state.hitsCount, hitsCount);
      expect(state.lastMoves, lastMoves);
      expect(state.lastMoveMessage, lastMoveMessage);
      expect(
        state.board[blockedCell.row][blockedCell.col].status,
        CellStatus.blocked,
      );
    });

    test('keeps only the latest move log entries', () {
      final initial = container.read(gameProvider);
      final cells = initial.board.expand((row) => row);

      for (final cell in cells) {
        container
            .read(gameProvider.notifier)
            .handleCellClick(cell.row, cell.col);
        if (container.read(gameProvider).movesCount >
            SoloGameState.moveLogLimit + 1) {
          break;
        }
      }

      final state = container.read(gameProvider);
      expect(state.lastMoves, hasLength(SoloGameState.moveLogLimit));
    });

    test('creates victory summary when all ships are sunk', () {
      final initial = container.read(gameProvider);
      final shipCells = initial.ships.expand((ship) => ship.cells).toList();

      for (final shipCell in shipCells) {
        container
            .read(gameProvider.notifier)
            .handleCellClick(shipCell.row, shipCell.col);
      }

      final state = container.read(gameProvider);
      expect(state.isFinished, isTrue);
      expect(state.victorySummary, contains('Победа!'));
      expect(state.victorySummary, contains('Ходы: ${shipCells.length}'));
      expect(state.victorySummary, contains('Попадания: ${shipCells.length}'));
      expect(state.victorySummary, contains('Последний потопленный корабль:'));
    });

    test('starts in classic word-pair mode', () {
      final state = container.read(gameProvider);

      expect(state.currentMode, WordPairMode.classic);
    });

    test('starts with word coordinate axes', () {
      final state = container.read(gameProvider);

      expect(state.columnNouns, hasLength(10));
      expect(state.rowAdjectives, hasLength(10));
      expect(
        state.columnNouns.map((entry) => entry.word).toSet(),
        hasLength(10),
      );
      expect(
        state.rowAdjectives.map((entry) => entry.base).toSet(),
        hasLength(10),
      );
    });

    test('cell words are built from row adjective and column noun', () {
      final state = container.read(gameProvider);

      for (var row = 0; row < state.board.length; row++) {
        for (var col = 0; col < state.board[row].length; col++) {
          final noun = state.columnNouns[col];
          final adjective = state.rowAdjectives[row];

          expect(
            state.board[row][col].word,
            '${adjective.formFor(noun.gender)} ${noun.word}',
          );
        }
      }
    });

    test('reset creates fresh word coordinate axes', () {
      final initial = container.read(gameProvider);
      final initialNouns = initial.columnNouns
          .map((entry) => entry.word)
          .toList();
      final initialAdjectives = initial.rowAdjectives
          .map((entry) => entry.base)
          .toList();

      container.read(gameProvider.notifier).resetGame();

      final reset = container.read(gameProvider);
      final resetNouns = reset.columnNouns.map((entry) => entry.word).toList();
      final resetAdjectives = reset.rowAdjectives
          .map((entry) => entry.base)
          .toList();

      expect(reset.columnNouns, hasLength(10));
      expect(reset.rowAdjectives, hasLength(10));
      expect(
        resetNouns,
        isNot(orderedEquals(initialNouns)),
        reason: 'Reset should generate a fresh noun axis.',
      );
      expect(resetAdjectives, isNot(orderedEquals(initialAdjectives)));
    });
  });

  group('BoardService word coordinates', () {
    test('creates board words from generated axes', () {
      final result = BoardService.createNewGameBoard();

      expect(result.columnNouns, hasLength(10));
      expect(result.rowAdjectives, hasLength(10));

      for (var row = 0; row < result.board.length; row++) {
        for (var col = 0; col < result.board[row].length; col++) {
          final noun = result.columnNouns[col];
          final adjective = result.rowAdjectives[row];

          expect(
            result.board[row][col].word,
            '${adjective.formFor(noun.gender)} ${noun.word}',
          );
        }
      }
    });
  });
}

Cell _firstCell(SoloGameState state, {required bool hasShip}) {
  return state.board
      .expand((row) => row)
      .firstWhere((cell) => cell.hasShip == hasShip);
}

Cell _shipCell(SoloGameState state, {required int minShipLength}) {
  final ship = state.ships.firstWhere(
    (candidate) => candidate.cells.length >= minShipLength,
  );
  final shipCell = ship.cells.first;
  return state.board[shipCell.row][shipCell.col];
}

Set<BoardPosition> _orthogonalDefaultNeighbours(
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
    return board[position.row][position.col].status == CellStatus.defaultValue;
  }).toSet();
}

Set<BoardPosition> _adjacentDefaultEmptyNeighbours(
  List<List<Cell>> board,
  int row,
  int col,
) {
  final positions = <BoardPosition>{};

  for (var nextRow = row - 1; nextRow <= row + 1; nextRow++) {
    if (nextRow < 0 || nextRow >= board.length) continue;

    for (var nextCol = col - 1; nextCol <= col + 1; nextCol++) {
      if (nextCol < 0 || nextCol >= board[nextRow].length) continue;
      if (nextRow == row && nextCol == col) continue;

      final cell = board[nextRow][nextCol];
      if (!cell.hasShip && cell.status == CellStatus.defaultValue) {
        positions.add(BoardPosition(row: nextRow, col: nextCol));
      }
    }
  }

  return positions;
}
