import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_battleship/models/models.dart';
import 'package:word_battleship/widgets/game_board.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<List<Cell>> _makeBoard(int size) => List.generate(
      size,
      (r) => List.generate(
        size,
        (c) => Cell(
          id: '$r-$c',
          row: r,
          col: c,
          word: 'слово',
          hasShip: false,
          status: CellStatus.defaultValue,
        ),
      ),
    );

const _testNouns = [
  NounEntry(word: 'кот', gender: WordGender.masculine),
  NounEntry(word: 'дом', gender: WordGender.masculine),
  NounEntry(word: 'лес', gender: WordGender.masculine),
  NounEntry(word: 'небо', gender: WordGender.neuter),
  NounEntry(word: 'вода', gender: WordGender.feminine),
  NounEntry(word: 'море', gender: WordGender.neuter),
  NounEntry(word: 'путь', gender: WordGender.masculine),
  NounEntry(word: 'день', gender: WordGender.masculine),
  NounEntry(word: 'рука', gender: WordGender.feminine),
  NounEntry(word: 'ночь', gender: WordGender.feminine),
];

const _testAdj = [
  AdjectiveEntry(base: 'тихий', masculine: 'тихий', feminine: 'тихая', neuter: 'тихое'),
  AdjectiveEntry(base: 'злой', masculine: 'злой', feminine: 'злая', neuter: 'злое'),
  AdjectiveEntry(base: 'сонный', masculine: 'сонный', feminine: 'сонная', neuter: 'сонное'),
  AdjectiveEntry(base: 'смелый', masculine: 'смелый', feminine: 'смелая', neuter: 'смелое'),
  AdjectiveEntry(base: 'быстрый', masculine: 'быстрый', feminine: 'быстрая', neuter: 'быстрое'),
  AdjectiveEntry(base: 'мокрый', masculine: 'мокрый', feminine: 'мокрая', neuter: 'мокрое'),
  AdjectiveEntry(base: 'хитрый', masculine: 'хитрый', feminine: 'хитрая', neuter: 'хитрое'),
  AdjectiveEntry(base: 'ленивый', masculine: 'ленивый', feminine: 'ленивая', neuter: 'ленивое'),
  AdjectiveEntry(base: 'солёный', masculine: 'солёный', feminine: 'солёная', neuter: 'солёное'),
  AdjectiveEntry(base: 'северный', masculine: 'северный', feminine: 'северная', neuter: 'северное'),
];

Widget _gameBoardWidget({List<List<Cell>>? board, void Function(int, int, String)? onCellClick}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 800,
        height: 800,
        child: GameBoard(
          board: board ?? _makeBoard(10),
          columnNouns: _testNouns,
          rowAdjectives: _testAdj,
          interestCells: const {},
          onCellClick: onCellClick ?? (a, b, c) {},
        ),
      ),
    ),
  );
}

void main() {
  // -------------------------------------------------------------------------
  // splitRuLabelParts utility
  // -------------------------------------------------------------------------

  test('splitRuLabelParts keeps short words intact', () {
    expect(splitRuLabelParts('маяк'), ['маяк']);
  });

  test('splitRuLabelParts splits long words into two non-empty parts', () {
    final parts = splitRuLabelParts('подозрительный');
    expect(parts, hasLength(2));
    expect(parts.first, isNotEmpty);
    expect(parts.last, isNotEmpty);
  });

  // -------------------------------------------------------------------------
  // Column headers: RotatedBox
  // -------------------------------------------------------------------------

  testWidgets('column headers render nouns inside RotatedBox with quarterTurns 3', (
    tester,
  ) async {
    await tester.pumpWidget(_gameBoardWidget());

    final boxes = tester.widgetList<RotatedBox>(find.byType(RotatedBox));
    expect(boxes, isNotEmpty);
    for (final box in boxes) {
      expect(box.quarterTurns, 3);
    }
  });

  testWidgets('column header noun texts have no newlines', (tester) async {
    await tester.pumpWidget(_gameBoardWidget());

    final nounWords = _testNouns.map((n) => n.word).toSet();
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      final data = t.data ?? '';
      if (nounWords.contains(data)) {
        expect(
          data.contains('\n'),
          isFalse,
          reason: 'Noun "$data" must not be split with a newline',
        );
      }
    }
  });

  // -------------------------------------------------------------------------
  // Row headers: single-line horizontal text
  // -------------------------------------------------------------------------

  testWidgets('row header adjective texts are single-line', (tester) async {
    await tester.pumpWidget(_gameBoardWidget());

    final adjWords = _testAdj.map((a) => a.base).toSet();
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      final data = t.data ?? '';
      if (adjWords.contains(data)) {
        expect(
          t.maxLines,
          1,
          reason: 'Adjective "$data" must be rendered as single line',
        );
      }
    }
  });

  // -------------------------------------------------------------------------
  // Desktop: first tap fires immediately
  // -------------------------------------------------------------------------

  testWidgets('desktop first tap on default cell fires immediately', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      var fired = false;
      await tester.pumpWidget(_gameBoardWidget(onCellClick: (_, col, word) => fired = true));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      expect(fired, isTrue);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  // -------------------------------------------------------------------------
  // Mobile: two-tap scenario
  // -------------------------------------------------------------------------

  testWidgets('mobile first tap selects, second tap fires', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      var fireCount = 0;
      await tester.pumpWidget(_gameBoardWidget(onCellClick: (_, col, word) => fireCount++));

      final cell = find.byType(GestureDetector).first;
      await tester.tap(cell);
      await tester.pump();
      expect(fireCount, 0, reason: 'First tap must not fire on mobile');

      await tester.tap(cell);
      await tester.pump();
      expect(fireCount, 1, reason: 'Second tap on same cell must fire');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('mobile tap on different cell moves selection without firing', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      var fireCount = 0;
      await tester.pumpWidget(_gameBoardWidget(onCellClick: (_, col, word) => fireCount++));

      final cells = find.byType(GestureDetector);
      await tester.tap(cells.at(0));
      await tester.pump();
      expect(fireCount, 0);

      await tester.tap(cells.at(1));
      await tester.pump();
      expect(fireCount, 0, reason: 'Tapping a different cell must not fire');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  // -------------------------------------------------------------------------
  // Post-click highlight clears after timer
  // -------------------------------------------------------------------------

  testWidgets('post-click highlight timer completes without error', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      await tester.pumpWidget(_gameBoardWidget());
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump(); // fire + set _lastFired
      // Advance past 700 ms — timer fires and clears _lastFired via setState.
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(); // process the rebuild
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  // -------------------------------------------------------------------------
  // Revealed cells do not fire
  // -------------------------------------------------------------------------

  testWidgets('tapping a hit cell does not fire', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      final board = _makeBoard(10);
      board[0][0] = board[0][0].copyWith(status: CellStatus.hit);

      var fired = false;
      await tester.pumpWidget(
        _gameBoardWidget(board: board, onCellClick: (_, col, word) => fired = true),
      );
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      expect(fired, isFalse, reason: 'Tapping a hit cell must not fire');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('tapping a blocked cell does not fire', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      final board = _makeBoard(10);
      board[0][0] = board[0][0].copyWith(status: CellStatus.blocked);

      var fired = false;
      await tester.pumpWidget(
        _gameBoardWidget(board: board, onCellClick: (_, col, word) => fired = true),
      );
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      expect(fired, isFalse);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
