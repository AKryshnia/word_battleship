import 'package:flutter_test/flutter_test.dart';
import 'package:word_battleship/constants/word_dictionary.dart';
import 'package:word_battleship/models/word_entry.dart';
import 'package:word_battleship/services/word_pair_service.dart';

void main() {
  group('WordPairService', () {
    const service = WordPairService();

    test('classic mode returns 100 unique non-empty pairs', () {
      final pairs = service.generatePairs(
        count: 100,
        mode: WordPairMode.classic,
        seed: 1,
      );

      expect(pairs, hasLength(100));
      expect(pairs.toSet(), hasLength(100));
      expect(pairs.every((pair) => pair.trim().isNotEmpty), isTrue);
    });

    test('random mode returns 100 unique non-empty pairs', () {
      final pairs = service.generatePairs(
        count: 100,
        mode: WordPairMode.random,
        seed: 2,
      );

      expect(pairs, hasLength(100));
      expect(pairs.toSet(), hasLength(100));
      expect(pairs.every((pair) => pair.trim().isNotEmpty), isTrue);
    });

    test('seed makes generation reproducible', () {
      final first = service.generatePairs(
        count: 100,
        mode: WordPairMode.classic,
        seed: 42,
      );
      final second = service.generatePairs(
        count: 100,
        mode: WordPairMode.classic,
        seed: 42,
      );

      expect(second, first);
    });

    test('generated adjectives agree with noun gender', () {
      final pairs = [
        ...service.generatePairs(
          count: 100,
          mode: WordPairMode.classic,
          seed: 3,
        ),
        ...service.generatePairs(
          count: 100,
          mode: WordPairMode.random,
          seed: 4,
        ),
      ];

      expect(pairs.every(_hasKnownAgreement), isTrue);
    });

    test('does not throw on repeated calls', () {
      for (var i = 0; i < 20; i++) {
        final pairs = service.generatePairs(
          count: 100,
          mode: i.isEven ? WordPairMode.classic : WordPairMode.random,
          seed: i,
        );

        expect(pairs, hasLength(100));
      }
    });

    test(
      'small dictionaries return available unique pairs without throwing',
      () {
        const smallService = WordPairService(
          nouns: [
            NounEntry(
              word: 'маяк',
              gender: WordGender.masculine,
              tags: {'sea'},
            ),
            NounEntry(
              word: 'бухта',
              gender: WordGender.feminine,
              tags: {'sea'},
            ),
          ],
          adjectives: [
            AdjectiveEntry(
              base: 'тихий',
              masculine: 'тихий',
              feminine: 'тихая',
              neuter: 'тихое',
              tags: {'sea'},
            ),
          ],
        );

        final pairs = smallService.generatePairs(
          count: 100,
          mode: WordPairMode.classic,
          seed: 5,
        );

        expect(pairs, hasLength(2));
        expect(pairs.toSet(), hasLength(2));
        expect(pairs, containsAll(['тихий маяк', 'тихая бухта']));
      },
    );
  });
}

bool _hasKnownAgreement(String pair) {
  final parts = pair.split(' ');
  if (parts.length != 2) return false;

  final adjective = parts[0];
  final noun = parts[1];

  final matchingNouns = localNouns.where((entry) => entry.word == noun);
  for (final nounEntry in matchingNouns) {
    final hasMatchingAdjective = localAdjectives.any(
      (entry) => entry.formFor(nounEntry.gender) == adjective,
    );
    if (hasMatchingAdjective) return true;
  }

  return false;
}
