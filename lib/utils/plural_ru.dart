/// Returns the correct Russian plural form for [n].
///
/// [one]  — форма для 1, 21, 31, … (именительный ед.ч.)   "ход", "корабль"
/// [few]  — форма для 2–4, 22–24, … (родительный ед.ч.)   "хода", "корабля"
/// [many] — форма для 5–20, 25–30, … (родительный мн.ч.)  "ходов", "кораблей"
///
/// Examples:
///   pluralRu(1,  'ход', 'хода', 'ходов') → 'ход'
///   pluralRu(2,  'ход', 'хода', 'ходов') → 'хода'
///   pluralRu(11, 'ход', 'хода', 'ходов') → 'ходов'
///   pluralRu(21, 'ход', 'хода', 'ходов') → 'ход'
///   pluralRu(64, 'ход', 'хода', 'ходов') → 'хода'
String pluralRu(int n, String one, String few, String many) {
  final mod10 = n.abs() % 10;
  final mod100 = n.abs() % 100;
  if (mod100 >= 11 && mod100 <= 19) return many;
  if (mod10 == 1) return one;
  if (mod10 >= 2 && mod10 <= 4) return few;
  return many;
}
