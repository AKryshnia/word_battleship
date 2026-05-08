import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_battleship/constants/constants.dart';
import 'package:word_battleship/models/models.dart';
import 'package:word_battleship/services/board_service.dart';
import 'package:word_battleship/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load with empty store returns null', () async {
    final loaded = await StorageService.loadGameState();
    expect(loaded, isNull);
  });

  test('save then load round-trips full game state', () async {
    final original = _buildGameStateWithProgress(LayoutProfile.wide);

    await StorageService.saveGameState(original);
    final loaded = await StorageService.loadGameState();

    expect(loaded, isNotNull);
    final restored = loaded!;
    expect(restored.board.length, original.board.length);
    expect(restored.board[0].length, original.board[0].length);
    for (var r = 0; r < original.board.length; r++) {
      for (var c = 0; c < original.board[r].length; c++) {
        final a = original.board[r][c];
        final b = restored.board[r][c];
        expect(b.id, a.id);
        expect(b.row, a.row);
        expect(b.col, a.col);
        expect(b.word, a.word);
        expect(b.hasShip, a.hasShip);
        expect(b.status, a.status);
      }
    }
    expect(restored.ships.length, original.ships.length);
    for (var i = 0; i < original.ships.length; i++) {
      expect(restored.ships[i].id, original.ships[i].id);
      expect(restored.ships[i].sunk, original.ships[i].sunk);
      expect(
        restored.ships[i].cells.map((c) => '${c.row},${c.col}').toList(),
        original.ships[i].cells.map((c) => '${c.row},${c.col}').toList(),
      );
    }
    expect(restored.movesCount, original.movesCount);
    expect(restored.hitsCount, original.hitsCount);
    expect(restored.isFinished, original.isFinished);
    expect(restored.lastMoveMessage, original.lastMoveMessage);
    expect(restored.lastSunkMessage, original.lastSunkMessage);
    expect(restored.victorySummary, original.victorySummary);
    expect(restored.lastMoves, original.lastMoves);
    expect(
      restored.columnNouns.map((e) => e.word).toList(),
      original.columnNouns.map((e) => e.word).toList(),
    );
    expect(
      restored.rowAdjectives.map((e) => e.base).toList(),
      original.rowAdjectives.map((e) => e.base).toList(),
    );
    expect(restored.interestCells, original.interestCells);
    expect(restored.currentMode, original.currentMode);
    expect(restored.layoutProfile, original.layoutProfile);
  });

  test('layoutProfile survives save/load for every variant', () async {
    for (final profile in LayoutProfile.values) {
      SharedPreferences.setMockInitialValues({});
      final original = _buildGameStateWithProgress(profile);
      await StorageService.saveGameState(original);
      final loaded = await StorageService.loadGameState();
      expect(
        loaded?.layoutProfile,
        profile,
        reason: 'profile $profile must round-trip',
      );
    }
  });

  test('clear removes the saved game', () async {
    final state = _buildGameStateWithProgress(LayoutProfile.medium);
    await StorageService.saveGameState(state);
    expect(await StorageService.loadGameState(), isNotNull);

    await StorageService.clearGameState();

    expect(await StorageService.loadGameState(), isNull);
  });

  test('corrupted payload returns null instead of throwing', () async {
    SharedPreferences.setMockInitialValues({
      GameConstants.storageKey: 'not a json',
    });

    final loaded = await StorageService.loadGameState();
    expect(loaded, isNull);
  });
}

SoloGameState _buildGameStateWithProgress(LayoutProfile profile) {
  final result = BoardService.createNewGameBoard(
    null,
    WordPairMode.classic,
    profile,
  );
  // Open one cell to populate move log + counters + interest set.
  final firstShip = result.ships.first;
  final shipCell = firstShip.cells.first;
  final updatedBoard = result.board
      .map(
        (row) => row
            .map(
              (cell) => (cell.row == shipCell.row && cell.col == shipCell.col)
                  ? cell.copyWith(status: CellStatus.hit)
                  : cell,
            )
            .toList(),
      )
      .toList();

  return SoloGameState(
    board: updatedBoard,
    ships: result.ships,
    movesCount: 1,
    hitsCount: 1,
    isFinished: false,
    currentMode: WordPairMode.classic,
    layoutProfile: profile,
    columnNouns: result.columnNouns,
    rowAdjectives: result.rowAdjectives,
    lastMoveMessage:
        'Попадание: ${updatedBoard[shipCell.row][shipCell.col].word}',
    lastSunkMessage: null,
    victorySummary: null,
    lastMoves: [
      MoveLogEntry(
        phrase: updatedBoard[shipCell.row][shipCell.col].word,
        isHit: true,
      ),
    ],
    interestCells: {BoardPosition(row: shipCell.row, col: shipCell.col + 1)},
  );
}
