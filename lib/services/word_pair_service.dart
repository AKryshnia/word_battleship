import 'dart:math';

import '../constants/word_dictionary.dart';
import '../models/word_entry.dart';

class WordPairService {
  const WordPairService({
    this.nouns = localNouns,
    this.adjectives = localAdjectives,
  });

  final List<NounEntry> nouns;
  final List<AdjectiveEntry> adjectives;

  List<String> generatePairs({
    required int count,
    required WordPairMode mode,
    int? seed,
  }) {
    if (count <= 0 || nouns.isEmpty || adjectives.isEmpty) {
      return const [];
    }

    final random = Random(seed);
    final pairs = <String>{};
    final maxPairs = nouns.length * adjectives.length;
    final targetCount = min(count, maxPairs);
    var attempts = 0;
    final maxAttempts = targetCount * 30;

    while (pairs.length < targetCount && attempts < maxAttempts) {
      attempts++;
      final noun = nouns[random.nextInt(nouns.length)];
      final adjective = _selectAdjective(noun, mode, random);
      pairs.add(_buildPair(adjective, noun));
    }

    if (pairs.length < targetCount) {
      _fillDeterministically(pairs, targetCount, mode);
    }

    return pairs.toList();
  }

  WordBoardVocabulary generateBoardVocabulary({
    required int size,
    required WordPairMode mode,
    int? seed,
  }) {
    if (size <= 0) {
      return const WordBoardVocabulary(columnNouns: [], rowAdjectives: []);
    }

    final random = Random(seed);
    final columnNouns = _uniqueNouns(random).take(size).toList();
    final rowAdjectives = _selectAxisAdjectives(
      columnNouns: columnNouns,
      size: size,
      mode: mode,
      random: random,
    );

    return WordBoardVocabulary(
      columnNouns: columnNouns,
      rowAdjectives: rowAdjectives,
    );
  }

  String buildPhrase({
    required AdjectiveEntry adjective,
    required NounEntry noun,
  }) {
    return _buildPair(adjective, noun);
  }

  AdjectiveEntry _selectAdjective(
    NounEntry noun,
    WordPairMode mode,
    Random random,
  ) {
    final candidates = switch (mode) {
      WordPairMode.classic => _classicCandidates(noun),
      WordPairMode.random => _randomCandidates(noun),
    };

    final pool = candidates.isEmpty ? adjectives : candidates;
    return pool[random.nextInt(pool.length)];
  }

  List<AdjectiveEntry> _classicCandidates(NounEntry noun) {
    final themed = adjectives.where(
      (adjective) => adjective.tags.any(noun.tags.contains),
    );
    return themed.isEmpty ? adjectives : themed.toList();
  }

  List<AdjectiveEntry> _randomCandidates(NounEntry noun) {
    final mismatched = adjectives.where(
      (adjective) => adjective.tags.every((tag) => !noun.tags.contains(tag)),
    );
    return mismatched.isEmpty ? adjectives : mismatched.toList();
  }

  List<NounEntry> _uniqueNouns(Random random) {
    final seen = <String>{};
    final unique = <NounEntry>[];

    for (final noun in List<NounEntry>.of(nouns)..shuffle(random)) {
      if (seen.add(noun.word)) {
        unique.add(noun);
      }
    }

    return unique;
  }

  List<AdjectiveEntry> _selectAxisAdjectives({
    required List<NounEntry> columnNouns,
    required int size,
    required WordPairMode mode,
    required Random random,
  }) {
    final selected = <AdjectiveEntry>[];
    final seen = <String>{};
    final nounTags = columnNouns.expand((noun) => noun.tags).toSet();
    final shuffledAdjectives = List<AdjectiveEntry>.of(adjectives)
      ..shuffle(random);

    final preferred = switch (mode) {
      WordPairMode.classic => shuffledAdjectives.where(
        (adjective) => adjective.tags.any(nounTags.contains),
      ),
      WordPairMode.random => shuffledAdjectives.where(
        (adjective) => adjective.tags.every((tag) => !nounTags.contains(tag)),
      ),
    };

    for (final adjective in preferred.followedBy(shuffledAdjectives)) {
      if (seen.add(adjective.base)) {
        selected.add(adjective);
      }
      if (selected.length == size) break;
    }

    return selected;
  }

  void _fillDeterministically(
    Set<String> pairs,
    int targetCount,
    WordPairMode mode,
  ) {
    final orderedNouns = List<NounEntry>.of(nouns);
    final orderedAdjectives = List<AdjectiveEntry>.of(adjectives);

    for (final noun in orderedNouns) {
      final adjectivePool = switch (mode) {
        WordPairMode.classic => _classicCandidates(noun),
        WordPairMode.random => _randomCandidates(noun),
      };
      final candidates = adjectivePool.isEmpty
          ? orderedAdjectives
          : adjectivePool;

      for (final adjective in candidates) {
        pairs.add(_buildPair(adjective, noun));
        if (pairs.length == targetCount) return;
      }
    }
  }

  String _buildPair(AdjectiveEntry adjective, NounEntry noun) {
    return '${adjective.formFor(noun.gender)} ${noun.word}';
  }
}
