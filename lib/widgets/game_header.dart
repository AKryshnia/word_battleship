import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';

class GameHeader extends StatelessWidget {
  final SoloGameState gameState;
  final VoidCallback onReset;

  const GameHeader({super.key, required this.gameState, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Game Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                gameState.isFinished ? 'Game Finished!' : 'Game in Progress',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: gameState.isFinished ? Colors.green : Colors.blue[800],
                ),
              ),
              ElevatedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          if (gameState.victorySummary != null) ...[
            const SizedBox(height: 12),
            _buildMessagePanel(gameState.victorySummary!, Colors.green[700]!),
          ] else if (gameState.lastSunkMessage != null) ...[
            const SizedBox(height: 12),
            _buildSunkBanner(gameState.lastSunkMessage!),
          ] else if (gameState.lastMoveMessage != null) ...[
            const SizedBox(height: 12),
            _buildMessagePanel(gameState.lastMoveMessage!, Colors.blue[700]!),
          ],

          const SizedBox(height: 12),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Ships',
                  '${gameState.ships.length}',
                  Icons.directions_boat,
                  Colors.blue[600]!,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Ships Left',
                  '${gameState.ships.where((ship) => !ship.sunk).length}',
                  Icons.sailing,
                  Colors.orange[600]!,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Sunk',
                  '${gameState.ships.where((ship) => ship.sunk).length}',
                  Icons.waves,
                  Colors.red[600]!,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Moves and Hits
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Moves',
                  '${gameState.movesCount}',
                  Icons.touch_app,
                  Colors.grey[600]!,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Hits',
                  '${gameState.hitsCount}',
                  Icons.gps_fixed,
                  Colors.green[600]!,
                ),
              ),
            ],
          ),

          if (gameState.lastMoves.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMoveLog(gameState.lastMoves),
          ],
        ],
      ),
    );
  }

  Widget _buildMessagePanel(String message, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSunkBanner(String message) {
    final color = Colors.deepOrange[700]!;
    final lines = message.split('\n');
    final title = lines.first;
    final phrases = lines.skip(1).join('\n');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Container(
        key: ValueKey(message),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.55), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.14),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.directions_boat, color: color, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  if (phrases.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      phrases,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[900],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveLog(List<MoveLogEntry> moves) {
    final visibleMoves = moves.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Последние ходы',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: visibleMoves.map((move) {
            final color = move.isHit ? Colors.red[600]! : Colors.grey[600]!;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Text(
                '${move.isHit ? 'Hit' : 'Miss'} · ${move.phrase}',
                style: GoogleFonts.poppins(fontSize: 10, color: color),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
