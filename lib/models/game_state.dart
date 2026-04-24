import 'cell.dart';
import 'board_position.dart';
import 'move_log_entry.dart';
import 'ship.dart';
import 'word_entry.dart';

class SoloGameState {
  static const int moveLogLimit = 10;

  final List<List<Cell>> board;
  final List<Ship> ships;
  final int movesCount;
  final int hitsCount;
  final bool isFinished;
  final String? lastMoveMessage;
  final String? lastSunkMessage;
  final String? victorySummary;
  final List<NounEntry>? _columnNouns;
  final List<AdjectiveEntry>? _rowAdjectives;
  final List<MoveLogEntry>? _lastMoves;
  final Set<BoardPosition>? _interestCells;
  final WordPairMode? _currentMode;

  const SoloGameState({
    required this.board,
    required this.ships,
    required this.movesCount,
    required this.hitsCount,
    required this.isFinished,
    required WordPairMode currentMode,
    this.lastMoveMessage,
    this.lastSunkMessage,
    this.victorySummary,
    List<NounEntry> columnNouns = const [],
    List<AdjectiveEntry> rowAdjectives = const [],
    List<MoveLogEntry> lastMoves = const [],
    Set<BoardPosition> interestCells = const {},
  }) : _columnNouns = columnNouns,
       _rowAdjectives = rowAdjectives,
       _lastMoves = lastMoves,
       _interestCells = interestCells,
       _currentMode = currentMode;

  List<NounEntry> get columnNouns => _columnNouns ?? const [];

  List<AdjectiveEntry> get rowAdjectives => _rowAdjectives ?? const [];

  List<MoveLogEntry> get lastMoves => _lastMoves ?? const [];

  Set<BoardPosition> get interestCells => _interestCells ?? const {};

  WordPairMode get currentMode => _currentMode ?? WordPairMode.classic;

  SoloGameState copyWith({
    List<List<Cell>>? board,
    List<Ship>? ships,
    int? movesCount,
    int? hitsCount,
    bool? isFinished,
    String? lastMoveMessage,
    String? lastSunkMessage,
    String? victorySummary,
    List<NounEntry>? columnNouns,
    List<AdjectiveEntry>? rowAdjectives,
    List<MoveLogEntry>? lastMoves,
    Set<BoardPosition>? interestCells,
    WordPairMode? currentMode,
    bool clearLastSunkMessage = false,
    bool clearVictorySummary = false,
  }) {
    return SoloGameState(
      board: board ?? this.board,
      ships: ships ?? this.ships,
      movesCount: movesCount ?? this.movesCount,
      hitsCount: hitsCount ?? this.hitsCount,
      isFinished: isFinished ?? this.isFinished,
      lastMoveMessage: lastMoveMessage ?? this.lastMoveMessage,
      lastSunkMessage: clearLastSunkMessage
          ? null
          : lastSunkMessage ?? this.lastSunkMessage,
      victorySummary: clearVictorySummary
          ? null
          : victorySummary ?? this.victorySummary,
      columnNouns: columnNouns ?? this.columnNouns,
      rowAdjectives: rowAdjectives ?? this.rowAdjectives,
      lastMoves: lastMoves ?? this.lastMoves,
      interestCells: interestCells ?? this.interestCells,
      currentMode: currentMode ?? this.currentMode,
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
        other.isFinished == isFinished &&
        other.lastMoveMessage == lastMoveMessage &&
        other.lastSunkMessage == lastSunkMessage &&
        other.victorySummary == victorySummary &&
        other.columnNouns == columnNouns &&
        other.rowAdjectives == rowAdjectives &&
        other.lastMoves == lastMoves &&
        other.interestCells == interestCells &&
        other.currentMode == currentMode;
  }

  @override
  int get hashCode {
    return Object.hash(
      board,
      ships,
      movesCount,
      hitsCount,
      isFinished,
      lastMoveMessage,
      lastSunkMessage,
      victorySummary,
      Object.hashAll(columnNouns),
      Object.hashAll(rowAdjectives),
      Object.hashAll(lastMoves),
      Object.hashAllUnordered(interestCells),
      currentMode,
    );
  }

  @override
  String toString() {
    return 'SoloGameState(board: $board, ships: $ships, movesCount: $movesCount, hitsCount: $hitsCount, isFinished: $isFinished, lastMoveMessage: $lastMoveMessage, lastSunkMessage: $lastSunkMessage, victorySummary: $victorySummary, columnNouns: $columnNouns, rowAdjectives: $rowAdjectives, lastMoves: $lastMoves, interestCells: $interestCells, currentMode: $currentMode)';
  }
}
