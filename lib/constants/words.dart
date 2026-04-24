class Words {
  static const int boardSize = 10; // десктоп
  static const int mobileBoardSize = 6; // мобила

  static int computeBoardSize() {
    // TODO: Implement responsive logic based on screen size
    // For now, return desktop size
    return boardSize;
  }
}
