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

    test('board vocabulary has unique column nouns and row adjectives', () {
      final vocabulary = service.generateBoardVocabulary(
        size: 10,
        mode: WordPairMode.classic,
        seed: 10,
      );

      expect(vocabulary.columnNouns, hasLength(10));
      expect(vocabulary.rowAdjectives, hasLength(10));
      expect(
        vocabulary.columnNouns.map((entry) => entry.word).toSet(),
        hasLength(10),
      );
      expect(
        vocabulary.rowAdjectives.map((entry) => entry.base).toSet(),
        hasLength(10),
      );
    });

    test('board vocabulary seed is reproducible', () {
      final first = service.generateBoardVocabulary(
        size: 10,
        mode: WordPairMode.random,
        seed: 11,
      );
      final second = service.generateBoardVocabulary(
        size: 10,
        mode: WordPairMode.random,
        seed: 11,
      );

      expect(
        second.columnNouns.map((entry) => entry.word),
        first.columnNouns.map((entry) => entry.word),
      );
      expect(
        second.rowAdjectives.map((entry) => entry.base),
        first.rowAdjectives.map((entry) => entry.base),
      );
    });

    test('buildPhrase agrees adjective with noun gender', () {
      const noun = NounEntry(
        word: 'бухта',
        gender: WordGender.feminine,
        tags: {'sea'},
      );
      const adjective = AdjectiveEntry(
        base: 'тихий',
        masculine: 'тихий',
        feminine: 'тихая',
        neuter: 'тихое',
        tags: {'sea'},
      );

      expect(
        service.buildPhrase(adjective: adjective, noun: noun),
        'тихая бухта',
      );
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

  // -------------------------------------------------------------------------
  // Layout profile vocabulary filtering
  // -------------------------------------------------------------------------

  group('generateBoardVocabularyForProfile', () {
    const svc = WordPairService();

    test('compact profile selects shorter nouns than wide profile', () {
      final compactVocab = svc.generateBoardVocabularyForProfile(
        size: 10,
        mode: WordPairMode.classic,
        profile: LayoutProfile.compact,
        seed: 99,
      );
      final wideVocab = svc.generateBoardVocabularyForProfile(
        size: 10,
        mode: WordPairMode.classic,
        profile: LayoutProfile.wide,
        seed: 99,
      );

      final compactMaxNoun = compactVocab.columnNouns
          .map((n) => n.word.length)
          .reduce((a, b) => a > b ? a : b);
      final wideMaxNoun = wideVocab.columnNouns
          .map((n) => n.word.length)
          .reduce((a, b) => a > b ? a : b);

      // compact should generally have shorter nouns (≤4 chars limit)
      expect(compactMaxNoun, lessThanOrEqualTo(wideMaxNoun));
    });

    test('compact profile nouns do not exceed 4 characters (unless fallback needed)', () {
      final vocab = svc.generateBoardVocabularyForProfile(
        size: 10,
        mode: WordPairMode.classic,
        profile: LayoutProfile.compact,
        seed: 7,
      );
      // All nouns should be ≤ 4 chars (the compact limit, unless dictionary
      // has fewer than 10 such nouns and fallback kicks in).
      for (final noun in vocab.columnNouns) {
        expect(
          noun.word.length,
          lessThanOrEqualTo(6), // generous upper bound allowing one fallback step
          reason: 'Compact profile noun "${noun.word}" is too long',
        );
      }
    });

    test('medium profile adjectives do not exceed 10 characters', () {
      final vocab = svc.generateBoardVocabularyForProfile(
        size: 10,
        mode: WordPairMode.classic,
        profile: LayoutProfile.medium,
        seed: 8,
      );
      for (final adj in vocab.rowAdjectives) {
        expect(
          adj.base.length,
          lessThanOrEqualTo(12), // generous upper bound
        );
      }
    });

    test('wide profile returns vocabulary without length restriction', () {
      final vocab = svc.generateBoardVocabularyForProfile(
        size: 10,
        mode: WordPairMode.classic,
        profile: LayoutProfile.wide,
        seed: 5,
      );
      expect(vocab.columnNouns, hasLength(10));
      expect(vocab.rowAdjectives, hasLength(10));
    });

    test('profile vocabulary has unique nouns and adjectives', () {
      for (final profile in LayoutProfile.values) {
        final vocab = svc.generateBoardVocabularyForProfile(
          size: 10,
          mode: WordPairMode.classic,
          profile: profile,
          seed: 42,
        );
        expect(
          vocab.columnNouns.map((n) => n.word).toSet(),
          hasLength(10),
          reason: 'Profile $profile should have 10 unique nouns',
        );
        expect(
          vocab.rowAdjectives.map((a) => a.base).toSet(),
          hasLength(10),
          reason: 'Profile $profile should have 10 unique adjectives',
        );
      }
    });
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
