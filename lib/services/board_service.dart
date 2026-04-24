import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../constants/constants.dart';
import 'word_pair_service.dart';

class BoardService {
  static const _uuid = Uuid();
  static const _wordPairService = WordPairService();

  static List<List<Cell>> createEmptyBoard([int? boardSize]) {
    final size = boardSize ?? Words.computeBoardSize();
    // TODO: Wire WordPairMode.classic / WordPairMode.random to a future UI
    // setting when the product is ready to expose "Режим Рандом".
    final words = _wordPairService.generatePairs(
      count: size * size,
      mode: WordPairMode.classic,
    );
    final board = <List<Cell>>[];

    for (int row = 0; row < size; row++) {
      final rowCells = <Cell>[];
      for (int col = 0; col < size; col++) {
        rowCells.add(
          Cell(
            id: _generateId(),
            row: row,
            col: col,
            word: words[(row * size) + col],
            hasShip: false,
            status: CellStatus.defaultValue,
          ),
        );
      }
      board.add(rowCells);
    }

    return board;
  }

  static bool _hasShipsAround(List<List<Cell>> board, int row, int col) {
    for (int r = row - 1; r <= row + 1; r++) {
      if (r < 0 || r >= board.length) continue;

      for (int c = col - 1; c <= col + 1; c++) {
        if (c < 0 || c >= board[r].length) continue;
        if (board[r][c].hasShip) {
          return true;
        }
      }
    }
    return false;
  }

  static bool _canPlaceShip(
    List<List<Cell>> board,
    int size,
    int row,
    int col,
    bool horizontal,
  ) {
    final maxRows = board.length;
    final maxCols = board[0].length;

    if (horizontal) {
      if (col + size > maxCols) return false;
      for (int i = 0; i < size; i++) {
        final targetCol = col + i;
        final cell = board[row][targetCol];
        if (cell.hasShip) return false;
        if (_hasShipsAround(board, row, targetCol)) return false;
      }
    } else {
      if (row + size > maxRows) return false;
      for (int i = 0; i < size; i++) {
        final cell = board[row + i][col];
        if (cell.hasShip) return false;
        if (_hasShipsAround(board, row + i, col)) return false;
      }
    }
    return true;
  }

  static Ship _placeShip(List<List<Cell>> board, int size) {
    final random = Random();
    late List<ShipCell> cells;

    while (true) {
      final horizontal = random.nextDouble() < 0.5;
      final row = random.nextInt(board.length);
      final col = random.nextInt(board[0].length);

      if (!_canPlaceShip(board, size, row, col, horizontal)) continue;

      cells = [];
      if (horizontal) {
        for (int i = 0; i < size; i++) {
          final targetCol = col + i;
          board[row][targetCol] = board[row][targetCol].copyWith(hasShip: true);
          cells.add(ShipCell(row: row, col: targetCol));
        }
      } else {
        for (int i = 0; i < size; i++) {
          final targetRow = row + i;
          board[targetRow][col] = board[targetRow][col].copyWith(hasShip: true);
          cells.add(ShipCell(row: targetRow, col: col));
        }
      }

      break;
    }

    return Ship(id: _generateId(), cells: cells, sunk: false);
  }

  static GameBoardResult createNewGameBoard([int? boardSize]) {
    final board = createEmptyBoard(boardSize);
    final ships = <Ship>[];

    for (final size in GameConstants.shipSizes) {
      final ship = _placeShip(board, size);
      ships.add(ship);
    }

    return GameBoardResult(board: board, ships: ships);
  }

  static String _generateId() {
    return _uuid.v4();
  }
}

class GameBoardResult {
  final List<List<Cell>> board;
  final List<Ship> ships;

  const GameBoardResult({required this.board, required this.ships});
}
