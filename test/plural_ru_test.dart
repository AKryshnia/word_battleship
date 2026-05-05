import 'package:flutter_test/flutter_test.dart';
import 'package:word_battleship/utils/plural_ru.dart';

void main() {
  group('pluralRu', () {
    // Helpers — ASCII identifiers, Russian strings as data.
    String movesForm(int n) => pluralRu(n, 'ход', 'хода', 'ходов');
    String hitsForm(int n) => pluralRu(n, 'попадание', 'попадания', 'попаданий');
    String shipsForm(int n) => pluralRu(n, 'корабль', 'корабля', 'кораблей');

    // ── one form: ends in 1, but not 11 ───────────────────────────────────────
    test('1  → one',  () => expect(movesForm(1),   'ход'));
    test('21 → one',  () => expect(movesForm(21),  'ход'));
    test('101 → one', () => expect(movesForm(101), 'ход'));

    // ── few form: ends in 2–4, but not 12–14 ──────────────────────────────────
    test('2  → few', () => expect(movesForm(2),  'хода'));
    test('3  → few', () => expect(movesForm(3),  'хода'));
    test('4  → few', () => expect(movesForm(4),  'хода'));
    test('22 → few', () => expect(movesForm(22), 'хода'));
    test('64 → few', () => expect(movesForm(64), 'хода'));

    // ── many form: 5–20, teens (11–19), multiples of 10 ──────────────────────
    test('5   → many',        () => expect(movesForm(5),   'ходов'));
    test('10  → many',        () => expect(movesForm(10),  'ходов'));
    test('11  → many (teen)', () => expect(movesForm(11),  'ходов'));
    test('12  → many (teen)', () => expect(movesForm(12),  'ходов'));
    test('14  → many (teen)', () => expect(movesForm(14),  'ходов'));
    test('19  → many (teen)', () => expect(movesForm(19),  'ходов'));
    test('20  → many',        () => expect(movesForm(20),  'ходов'));
    test('25  → many',        () => expect(movesForm(25),  'ходов'));
    test('100 → many',        () => expect(movesForm(100), 'ходов'));
    test('111 → many (teen)', () => expect(movesForm(111), 'ходов'));
    test('112 → many (teen)', () => expect(movesForm(112), 'ходов'));

    // ── game nouns ─────────────────────────────────────────────────────────────
    test('hits: 1 попадание, 2 попадания, 5 попаданий', () {
      expect(hitsForm(1),  'попадание');
      expect(hitsForm(2),  'попадания');
      expect(hitsForm(5),  'попаданий');
      expect(hitsForm(11), 'попаданий');
      expect(hitsForm(21), 'попадание');
    });

    test('ships: 1 корабль, 2 корабля, 5 кораблей', () {
      expect(shipsForm(1),  'корабль');
      expect(shipsForm(2),  'корабля');
      expect(shipsForm(5),  'кораблей');
      expect(shipsForm(11), 'кораблей');
      expect(shipsForm(21), 'корабль');
    });
  });
}
