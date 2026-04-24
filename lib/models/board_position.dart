class BoardPosition {
  final int row;
  final int col;

  const BoardPosition({required this.row, required this.col});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoardPosition && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() {
    return 'BoardPosition(row: $row, col: $col)';
  }
}
