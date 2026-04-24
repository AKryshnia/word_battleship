import 'cell.dart';
import 'ship.dart';

class SoloGameState {
  final List<List<Cell>> board;
  final List<Ship> ships;
  final int movesCount;
  final int hitsCount;
  final bool isFinished;

  const SoloGameState({
    required this.board,
    required this.ships,
    required this.movesCount,
    required this.hitsCount,
    required this.isFinished,
  });

  SoloGameState copyWith({
    List<List<Cell>>? board,
    List<Ship>? ships,
    int? movesCount,
    int? hitsCount,
    bool? isFinished,
  }) {
    return SoloGameState(
      board: board ?? this.board,
      ships: ships ?? this.ships,
      movesCount: movesCount ?? this.movesCount,
      hitsCount: hitsCount ?? this.hitsCount,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SoloGameState &&
        other.board == board &&
        other.ships == ships &&
        other.movesCount == movesCount &&
        other.hitsCount == hitsCount &&
        other.isFinished == isFinished;
  }

  @override
  int get hashCode {
    return board.hashCode ^
        ships.hashCode ^
        movesCount.hashCode ^
        hitsCount.hashCode ^
        isFinished.hashCode;
  }

  @override
  String toString() {
    return 'SoloGameState(board: $board, ships: $ships, movesCount: $movesCount, hitsCount: $hitsCount, isFinished: $isFinished)';
  }
}
