import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Event types and data
// ---------------------------------------------------------------------------

enum _EventType { miss, hit, sunk, won }

class _EventData {
  final _EventType type;
  final String tag;
  final String message;
  const _EventData({
    required this.type,
    required this.tag,
    required this.message,
  });
}

// ---------------------------------------------------------------------------
// Miss flavor phrases — short, light, no cringe
// ---------------------------------------------------------------------------

const _missPhrases = [
  'Ой-ёй',
  'Три тысячи хвощей!',
  'Рука дёрнулась...',
  'Мимо!',
  'Ну почти',
  'Эх',
  'В молоко',
  'Пушка подвела',
  'Вот это да...',
  'Опять мимо',
];

// ---------------------------------------------------------------------------
// EventStrip — fixed 56 px height (2-line zone), always in layout.
// Shows: miss · hit · sunk · victory. Tag on line 1, message on line 2.
// Empty before first move — height stays reserved, board never jumps.
// ---------------------------------------------------------------------------

class EventStrip extends StatelessWidget {
  final SoloGameState gameState;

  const EventStrip({super.key, required this.gameState});

  _EventData? _resolveEvent() {
    // Priority: victory > sunk > hit > miss
    if (gameState.victorySummary != null) {
      return _EventData(
        type: _EventType.won,
        tag: 'Победа',
        message: 'Все корабли потоплены — ${gameState.movesCount} ходов',
      );
    }

    if (gameState.lastSunkMessage != null) {
      final parts = gameState.lastSunkMessage!.split('\n');
      final phrases =
          parts.length > 1 ? parts.skip(1).join(' — ') : parts.first;
      return _EventData(
        type: _EventType.sunk,
        tag: 'Потоплен',
        message: phrases,
      );
    }

    final raw = gameState.lastMoveMessage;
    if (raw != null) {
      if (raw.startsWith('Попадание')) {
        return _EventData(
          type: _EventType.hit,
          tag: 'Попадание',
          message: raw.replaceFirst('Попадание: ', ''),
        );
      }
      if (raw.startsWith('Промах')) {
        final word = raw.replaceFirst('Промах: ', '');
        final phrase = _missPhrases[gameState.movesCount % _missPhrases.length];
        return _EventData(
          type: _EventType.miss,
          tag: 'Промах',
          message: '$word · $phrase',
        );
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final event = _resolveEvent();

    return LayoutBuilder(builder: (context, constraints) {
      final hPad = constraints.maxWidth < 460 ? 14.0 : AppDimensions.shellPadH;

      return Container(
        height: AppDimensions.eventStripH,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.surface2,
          border: Border(
            bottom: BorderSide(color: AppColors.borderSubtle),
          ),
        ),
        // Empty before first move: space is reserved, nothing shown.
        child: event == null ? null : _StripRow(event: event),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Strip content — coloured bar left, tag on line 1, message on line 2.
// ---------------------------------------------------------------------------

class _StripRow extends StatelessWidget {
  final _EventData event;
  const _StripRow({required this.event});

  Color get _barColor => switch (event.type) {
    _EventType.miss => AppColors.text3,
    _EventType.hit  => AppColors.cellHitBg,
    _EventType.sunk => AppColors.cellHitBg,
    _EventType.won  => AppColors.statusWon,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left bar — spans both text lines
        Container(
          width: 2.5,
          height: 34,
          decoration: BoxDecoration(
            color: _barColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),

        // Two-line text block
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.tag.toUpperCase(),
                style: AppTextStyles.eventTag,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                event.message,
                style: AppTextStyles.eventMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
