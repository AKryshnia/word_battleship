import 'dart:io';

const sourceName = 'OpenRussian Russian Dictionary Data';
const sourceUrl = 'https://github.com/Badestrand/russian-dictionary';
const sourceLicense = 'CC-BY-SA-4.0';

const nounLimit = 600;
const adjectiveLimit = 600;

const _wordPattern = r'^[а-яё]+$';

const _blockedNouns = {
  'человек',
  'люди',
  'господин',
  'товарищ',
  'больной',
  'покойник',
  'раб',
  'дурак',
  'дура',
  'идиот',
  'стать',
  'тут',
  'пять',
  'тысяча',
  'россия',
  'москва',
  'бог',
  'жена',
  'мать',
  'отец',
  'женщина',
  'ребёнок',
  'народ',
  'война',
  'смерть',
  'власть',
  'партия',
  'церковь',
  'президент',
  'правительство',
  'милиция',
  'полиция',
  'армия',
  'труп',
  'убийство',
  'болезнь',
  'деньги',
  'рубль',
  'доллар',
};

const _blockedAdjectives = {
  'тот',
  'этот',
  'который',
  'такой',
  'какой',
  'мой',
  'твой',
  'свой',
  'наш',
  'ваш',
  'их',
  'его',
  'её',
  'весь',
  'самый',
  'каждый',
  'любой',
  'иной',
  'некоторый',
  'прочий',
  'один',
};

const _seaNouns = {
  'море',
  'океан',
  'берег',
  'остров',
  'волна',
  'порт',
  'маяк',
  'корабль',
  'лодка',
  'палуба',
  'парус',
  'ветер',
  'шторм',
  'туман',
  'рыба',
  'бухта',
  'залив',
  'компас',
  'карта',
};

const _natureNouns = {
  'лес',
  'поле',
  'река',
  'гора',
  'дождь',
  'снег',
  'солнце',
  'луна',
  'звезда',
  'трава',
  'цветок',
  'камень',
  'дерево',
  'птица',
  'зверь',
};

const _objectNouns = {
  'дом',
  'окно',
  'дверь',
  'стол',
  'книга',
  'ключ',
  'нож',
  'чашка',
  'чайник',
  'лампа',
  'зеркало',
  'сумка',
  'письмо',
  'телефон',
  'машина',
};

const _foodNouns = {
  'хлеб',
  'сыр',
  'чай',
  'суп',
  'каша',
  'яблоко',
  'огурец',
  'вареник',
  'пирог',
  'молоко',
  'мясо',
  'рыба',
};

const _seaAdjectives = {
  'морской',
  'солёный',
  'северный',
  'южный',
  'тихий',
  'бурный',
  'прибрежный',
  'дальний',
  'туманный',
  'ветреный',
};

const _natureAdjectives = {
  'зелёный',
  'лесной',
  'горный',
  'речной',
  'снежный',
  'солнечный',
  'лунный',
  'каменный',
  'тёплый',
  'холодный',
};

const _moodAdjectives = {
  'тихий',
  'спокойный',
  'весёлый',
  'сонный',
  'тревожный',
  'смелый',
  'подозрительный',
  'драматичный',
  'философский',
  'ленивый',
};

void main(List<String> args) {
  if (args.length != 3) {
    stderr.writeln(
      'Usage: dart tooling/build_word_dictionary.dart '
      '<nouns.csv> <adjectives.csv> <output.dart>',
    );
    exitCode = 64;
    return;
  }

  final nouns = _readNouns(File(args[0]));
  final adjectives = _readAdjectives(File(args[1]));

  if (nouns.length < 100 || adjectives.length < 100) {
    throw StateError(
      'Filtered dictionary is too small: '
      '${nouns.length} nouns, ${adjectives.length} adjectives.',
    );
  }

  final output = File(args[2]);
  output.writeAsStringSync(_renderDictionary(nouns, adjectives));

  stdout.writeln(
    'Wrote ${nouns.length} nouns and ${adjectives.length} adjectives '
    'to ${output.path}',
  );
}

List<_Noun> _readNouns(File file) {
  final rows = file.readAsLinesSync();
  final result = <_Noun>[];
  final seen = <String>{};

  for (final row in rows.skip(1)) {
    final cells = row.split('\t');
    if (cells.length < 10) continue;

    final rawBare = cells[0].trim();
    if (rawBare.isNotEmpty && rawBare[0] != rawBare[0].toLowerCase()) {
      continue;
    }

    final gender = switch (cells[4]) {
      'm' => 'WordGender.masculine',
      'f' => 'WordGender.feminine',
      'n' => 'WordGender.neuter',
      _ => null,
    };
    if (gender == null) continue;
    if (cells[6] == '1') continue; // Prefer inanimate nouns for neutral UX.
    if (cells[7] == '1' || cells[9] == '1') continue;

    final word = _cleanForm(cells[10].isEmpty ? cells[0] : cells[10]);
    if (!_isGoodWord(word)) continue;
    if (_blockedNouns.contains(word)) continue;
    if (!seen.add(word)) continue;

    result.add(_Noun(word, gender, _nounTags(word)));
    if (result.length == nounLimit) break;
  }

  return result;
}

List<_Adjective> _readAdjectives(File file) {
  final rows = file.readAsLinesSync();
  final result = <_Adjective>[];
  final seen = <String>{};

  for (final row in rows.skip(1)) {
    final cells = row.split('\t');
    if (cells.length < 29) continue;

    final base = _cleanForm(cells[0]);
    final masculine = _cleanForm(cells[10]);
    final feminine = _cleanForm(cells[16]);
    final neuter = _cleanForm(cells[22]);

    if (!_isGoodWord(base)) continue;
    if (!_isGoodWord(masculine)) continue;
    if (!_isGoodWord(feminine)) continue;
    if (!_isGoodWord(neuter)) continue;
    if (_blockedAdjectives.contains(base)) continue;
    if (!masculine.endsWith('ый') &&
        !masculine.endsWith('ий') &&
        !masculine.endsWith('ой')) {
      continue;
    }
    if (!seen.add(base)) continue;

    result.add(
      _Adjective(base, masculine, feminine, neuter, _adjectiveTags(base)),
    );
    if (result.length == adjectiveLimit) break;
  }

  return result;
}

String _cleanForm(String value) {
  return value
      .split(',')
      .first
      .replaceAll("'", '')
      .replaceAll('*', '')
      .replaceAll('ё', 'ё')
      .trim()
      .toLowerCase();
}

bool _isGoodWord(String word) {
  if (word.length < 3 || word.length > 14) return false;
  return RegExp(_wordPattern).hasMatch(word);
}

Set<String> _nounTags(String word) {
  return {
    if (_seaNouns.contains(word)) 'sea',
    if (_natureNouns.contains(word)) 'nature',
    if (_objectNouns.contains(word)) 'object',
    if (_foodNouns.contains(word)) 'food',
    if (!_seaNouns.contains(word) &&
        !_natureNouns.contains(word) &&
        !_objectNouns.contains(word) &&
        !_foodNouns.contains(word))
      'general',
  };
}

Set<String> _adjectiveTags(String word) {
  return {
    if (_seaAdjectives.contains(word)) 'sea',
    if (_natureAdjectives.contains(word)) 'nature',
    if (_moodAdjectives.contains(word)) 'mood',
    if (!_seaAdjectives.contains(word) &&
        !_natureAdjectives.contains(word) &&
        !_moodAdjectives.contains(word))
      'general',
  };
}

String _renderDictionary(List<_Noun> nouns, List<_Adjective> adjectives) {
  final buffer = StringBuffer()
    ..writeln('// Generated by tooling/build_word_dictionary.dart.')
    ..writeln('// Source: $sourceName ($sourceUrl), $sourceLicense.')
    ..writeln(
      '// Do not edit entries manually; update the build script instead.',
    )
    ..writeln()
    ..writeln("import '../models/word_entry.dart';")
    ..writeln()
    ..writeln('const localNouns = <NounEntry>[');

  for (final noun in nouns) {
    buffer.writeln(
      "  NounEntry(word: '${_escape(noun.word)}', "
      'gender: ${noun.gender}, tags: ${_renderTags(noun.tags)}),',
    );
  }

  buffer
    ..writeln('];')
    ..writeln()
    ..writeln('const localAdjectives = <AdjectiveEntry>[');

  for (final adjective in adjectives) {
    buffer.writeln(
      "  AdjectiveEntry(base: '${_escape(adjective.base)}', "
      "masculine: '${_escape(adjective.masculine)}', "
      "feminine: '${_escape(adjective.feminine)}', "
      "neuter: '${_escape(adjective.neuter)}', "
      'tags: ${_renderTags(adjective.tags)}),',
    );
  }

  buffer.writeln('];');
  return buffer.toString();
}

String _renderTags(Set<String> tags) {
  return "{${tags.map((tag) => "'$tag'").join(', ')}}";
}

String _escape(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

class _Noun {
  final String word;
  final String gender;
  final Set<String> tags;

  const _Noun(this.word, this.gender, this.tags);
}

class _Adjective {
  final String base;
  final String masculine;
  final String feminine;
  final String neuter;
  final Set<String> tags;

  const _Adjective(
    this.base,
    this.masculine,
    this.feminine,
    this.neuter,
    this.tags,
  );
}
