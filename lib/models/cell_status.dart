enum CellStatus {
  defaultValue,
  hit,
  miss,
  blocked;

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
    }
  }
}
