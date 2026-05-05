/// Splits [word] into two display parts at the best syllable boundary.
/// Returns a single-element list when the word is short enough to fit in one line.
List<String> splitRuLabelParts(String word) {
  final s = word.trim();
  if (s.length <= 6) return [s];

  const vowels = 'аеёиоуыэюя';
  final minPart = s.length >= 10 ? 4 : 3;
  final target = s.length ~/ 2;
  var best = -1;
  var bestScore = 1 << 30;

  for (var i = minPart; i <= s.length - minPart; i++) {
    final l = s[i - 1].toLowerCase();
    final r = s[i].toLowerCase();
    var score = (target - i).abs() * 10;
    if (vowels.contains(l) && !vowels.contains(r)) {
      score -= 6;
    } else if (!vowels.contains(l) && vowels.contains(r)) {
      score -= 2;
    }
    score += (i - (s.length - i)).abs();
    if (score < bestScore) {
      bestScore = score;
      best = i;
    }
  }

  return best == -1 ? [s] : [s.substring(0, best), s.substring(best)];
}

/// Convenience wrapper — joins [splitRuLabelParts] result with a newline.
String splitRuLabel(String word) => splitRuLabelParts(word).join('\n');
