import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_battleship/models/models.dart';
import 'package:word_battleship/widgets/game_board.dart';

void main() {
  testWidgets('adds visible break opportunities to long axis labels', (
    tester,
  ) async {
    final board = List.generate(
      10,
      (row) => List.generate(
        10,
        (col) => Cell(
          id: '$row-$col',
          row: row,
          col: col,
          word: 'подозрительный эксперимент',
          hasShip: false,
          status: CellStatus.defaultValue,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 800,
            child: GameBoard(
              board: board,
              columnNouns: const [
                NounEntry(word: 'эксперимент', gender: WordGender.masculine),
                NounEntry(word: 'кабинет', gender: WordGender.masculine),
                NounEntry(word: 'маяк', gender: WordGender.masculine),
                NounEntry(word: 'бухта', gender: WordGender.feminine),
                NounEntry(word: 'море', gender: WordGender.neuter),
                NounEntry(word: 'чайник', gender: WordGender.masculine),
                NounEntry(word: 'торпеда', gender: WordGender.feminine),
                NounEntry(word: 'книга', gender: WordGender.feminine),
                NounEntry(word: 'ветер', gender: WordGender.masculine),
                NounEntry(word: 'остров', gender: WordGender.masculine),
              ],
              rowAdjectives: const [
                AdjectiveEntry(
                  base: 'подозрительный',
                  masculine: 'подозрительный',
                  feminine: 'подозрительная',
                  neuter: 'подозрительное',
                ),
                AdjectiveEntry(
                  base: 'драматичный',
                  masculine: 'драматичный',
                  feminine: 'драматичная',
                  neuter: 'драматичное',
                ),
                AdjectiveEntry(
                  base: 'тихий',
                  masculine: 'тихий',
                  feminine: 'тихая',
                  neuter: 'тихое',
                ),
                AdjectiveEntry(
                  base: 'сонный',
                  masculine: 'сонный',
                  feminine: 'сонная',
                  neuter: 'сонное',
                ),
                AdjectiveEntry(
                  base: 'солёный',
                  masculine: 'солёный',
                  feminine: 'солёная',
                  neuter: 'солёное',
                ),
                AdjectiveEntry(
                  base: 'смелый',
                  masculine: 'смелый',
                  feminine: 'смелая',
                  neuter: 'смелое',
                ),
                AdjectiveEntry(
                  base: 'быстрый',
                  masculine: 'быстрый',
                  feminine: 'быстрая',
                  neuter: 'быстрое',
                ),
                AdjectiveEntry(
                  base: 'морской',
                  masculine: 'морской',
                  feminine: 'морская',
                  neuter: 'морское',
                ),
                AdjectiveEntry(
                  base: 'ленивый',
                  masculine: 'ленивый',
                  feminine: 'ленивая',
                  neuter: 'ленивое',
                ),
                AdjectiveEntry(
                  base: 'северный',
                  masculine: 'северный',
                  feminine: 'северная',
                  neuter: 'северное',
                ),
              ],
              interestCells: const {},
              onCellClick: (_, _, _) {},
            ),
          ),
        ),
      ),
    );

    final longNounText = tester.widget<Text>(
      find.textContaining('экспе\u200B').first,
    );
    final longAdjectiveText = tester.widget<Text>(
      find.textContaining('подо\u200B').first,
    );

    expect(longNounText.data, contains('\u200B'));
    expect(longAdjectiveText.data, contains('\u200B'));
    expect(longNounText.overflow, TextOverflow.visible);
    expect(longAdjectiveText.overflow, TextOverflow.visible);
  });
}
