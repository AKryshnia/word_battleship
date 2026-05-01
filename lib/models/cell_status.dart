enum CellStatus {
  defaultValue,
  hit,
  miss,
  blocked,
  sunk;

  String get displayName {
    switch (this) {
      case CellStatus.defaultValue:
        return 'default';
      case CellStatus.hit:
        return 'hit';
      case CellStatus.miss:
        return 'miss';
      case CellStatus.blocked:
        return 'blocked';
      case CellStatus.sunk:
        return 'sunk';
    }
  }
}
