import 'cell_status.dart';

class Cell {
  final String id;
  final int row;
  final int col;
  final String word;
  final bool hasShip;
  final CellStatus status;

  const Cell({
    required this.id,
    required this.row,
    required this.col,
    required this.word,
    required this.hasShip,
    required this.status,
  });

  Cell copyWith({
    String? id,
    int? row,
    int? col,
    String? word,
    bool? hasShip,
    CellStatus? status,
  }) {
    return Cell(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      word: word ?? this.word,
      hasShip: hasShip ?? this.hasShip,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cell &&
        other.id == id &&
        other.row == row &&
        other.col == col &&
        other.word == word &&
        other.hasShip == hasShip &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        row.hashCode ^
        col.hashCode ^
        word.hashCode ^
        hasShip.hashCode ^
        status.hashCode;
  }

  @override
  String toString() {
    return 'Cell(id: $id, row: $row, col: $col, word: $word, hasShip: $hasShip, status: $status)';
  }
}
