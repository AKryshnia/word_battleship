import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/game_header.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameProviderNotifier = ref.read(gameProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Word Battleship',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Game Header
              GameHeader(
                gameState: gameState,
                onReset: () => gameProviderNotifier.resetGame(),
              ),

              const SizedBox(height: 20),

              // Game Board
              Expanded(
                child: GameBoard(
                  board: gameState.board,
                  columnNouns: gameState.columnNouns,
                  rowAdjectives: gameState.rowAdjectives,
                  interestCells: gameState.interestCells,
                  onCellClick: (row, col, _) {
                    gameProviderNotifier.handleCellClick(row, col);
                  },
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Prototype · Word Battleship · MVP',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
