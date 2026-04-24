import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../constants/constants.dart';

class StorageService {
  static Future<void> saveGameState(SoloGameState gameState) async {
    final prefs = await SharedPreferences.getInstance();
    final gameStateJson = _gameStateToJson(gameState);
    await prefs.setString(GameConstants.storageKey, gameStateJson);
  }

  static Future<SoloGameState?> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final gameStateJson = prefs.getString(GameConstants.storageKey);

    if (gameStateJson == null) return null;

    try {
      return _gameStateFromJson(gameStateJson);
    } catch (e) {
      // If there's an error loading, return null to start fresh
      return null;
    }
  }

  static Future<void> clearGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(GameConstants.storageKey);
  }

  static String _gameStateToJson(SoloGameState gameState) {
    return jsonEncode({
      'board': gameState.board
          .map((row) => row.map((cell) => _cellToJson(cell)).toList())
          .toList(),
      'ships': gameState.ships.map((ship) => _shipToJson(ship)).toList(),
      'movesCount': gameState.movesCount,
      'hitsCount': gameState.hitsCount,
      'isFinished': gameState.isFinished,
    });
  }

  static SoloGameState _gameStateFromJson(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;

    final board = (data['board'] as List)
        .map((row) => (row as List).map((cell) => _cellFromJson(cell)).toList())
        .toList();

    final ships = (data['ships'] as List)
        .map((ship) => _shipFromJson(ship))
        .toList();

    return SoloGameState(
      board: board,
      ships: ships,
      movesCount: data['movesCount'] as int,
      hitsCount: data['hitsCount'] as int,
      isFinished: data['isFinished'] as bool,
    );
  }

  static Map<String, dynamic> _cellToJson(Cell cell) {
    return {
      'id': cell.id,
      'row': cell.row,
      'col': cell.col,
      'word': cell.word,
      'hasShip': cell.hasShip,
      'status': cell.status.name,
    };
  }

  static Cell _cellFromJson(Map<String, dynamic> json) {
    return Cell(
      id: json['id'] as String,
      row: json['row'] as int,
      col: json['col'] as int,
      word: json['word'] as String,
      hasShip: json['hasShip'] as bool,
      status: CellStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => CellStatus.defaultValue,
      ),
    );
  }

  static Map<String, dynamic> _shipToJson(Ship ship) {
    return {
      'id': ship.id,
      'cells': ship.cells.map((cell) => _shipCellToJson(cell)).toList(),
      'sunk': ship.sunk,
    };
  }

  static Ship _shipFromJson(Map<String, dynamic> json) {
    return Ship(
      id: json['id'] as String,
      cells: (json['cells'] as List)
          .map((cell) => _shipCellFromJson(cell))
          .toList(),
      sunk: json['sunk'] as bool,
    );
  }

  static Map<String, dynamic> _shipCellToJson(ShipCell shipCell) {
    return {'row': shipCell.row, 'col': shipCell.col};
  }

  static ShipCell _shipCellFromJson(Map<String, dynamic> json) {
    return ShipCell(row: json['row'] as int, col: json['col'] as int);
  }
}
