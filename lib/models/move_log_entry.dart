class MoveLogEntry {
  final String phrase;
  final bool isHit;

  const MoveLogEntry({required this.phrase, required this.isHit});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoveLogEntry &&
        other.phrase == phrase &&
        other.isHit == isHit;
  }

  @override
  int get hashCode => Object.hash(phrase, isHit);

  @override
  String toString() {
    return 'MoveLogEntry(phrase: $phrase, isHit: $isHit)';
  }
}
