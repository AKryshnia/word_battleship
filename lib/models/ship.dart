class Ship {
  final String id;
  final List<ShipCell> cells;
  final bool sunk;

  const Ship({
    required this.id,
    required this.cells,
    required this.sunk,
  });

  Ship copyWith({
    String? id,
    List<ShipCell>? cells,
    bool? sunk,
  }) {
    return Ship(
      id: id ?? this.id,
      cells: cells ?? this.cells,
      sunk: sunk ?? this.sunk,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ship &&
        other.id == id &&
        other.sunk == sunk;
  }

  @override
  int get hashCode => id.hashCode ^ sunk.hashCode;

  @override
  String toString() {
    return 'Ship(id: $id, cells: $cells, sunk: $sunk)';
  }
}

class ShipCell {
  final int row;
  final int col;

  const ShipCell({
    required this.row,
    required this.col,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShipCell &&
        other.row == row &&
        other.col == col;
  }

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() {
    return 'ShipCell(row: $row, col: $col)';
  }
}
