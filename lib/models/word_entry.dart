enum WordGender { masculine, feminine, neuter }

enum WordPairMode { classic, random }

class AdjectiveEntry {
  final String base;
  final String masculine;
  final String feminine;
  final String neuter;
  final Set<String> tags;

  const AdjectiveEntry({
    required this.base,
    required this.masculine,
    required this.feminine,
    required this.neuter,
    this.tags = const {},
  });

  String formFor(WordGender gender) {
    return switch (gender) {
      WordGender.masculine => masculine,
      WordGender.feminine => feminine,
      WordGender.neuter => neuter,
    };
  }
}

class NounEntry {
  final String word;
  final WordGender gender;
  final Set<String> tags;

  const NounEntry({
    required this.word,
    required this.gender,
    this.tags = const {},
  });
}
