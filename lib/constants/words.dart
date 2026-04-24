class Words {
  static const List<String> nouns = [
    'лис', 'кот', 'хомяк', 'ёж', 'конь',
    'заяц', 'дельфин', 'тигр', 'совёнок', 'енот',
  ];

  static const List<String> adjectives = [
    'весёлый', 'ленивый', 'хитрый', 'мокрый',
    'злой', 'сонный', 'шумный', 'тихий', 'быстрый', 'смелый',
  ];

  static const int boardSize = 10;         // десктоп
  static const int mobileBoardSize = 6;   // мобила

  static String getWordForCell(int row, int col) {
    final adj = adjectives[row % adjectives.length];
    final noun = nouns[col % nouns.length];
    return '$adj $noun';
  }

  static int computeBoardSize() {
    // TODO: Implement responsive logic based on screen size
    // For now, return desktop size
    return boardSize;
  }
}
