import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/plural_ru.dart';

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
        message:
            'Все корабли потоплены — ${gameState.movesCount} '
            '${pluralRu(gameState.movesCount, 'ход', 'хода', 'ходов')}',
      );
    }

    if (gameState.lastSunkMessage != null) {
      final parts = gameState.lastSunkMessage!.split('\n');
      final phrases = parts.length > 1
          ? parts.skip(1).join(' — ')
          : parts.first;
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final hPad = constraints.maxWidth < 460
            ? 14.0
            : AppDimensions.shellPadH;

        return Container(
          height: AppDimensions.eventStripH,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
          ),
          // Empty before first move: space is reserved, nothing shown.
          child: event == null ? null : _StripRow(event: event),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Strip content — Neutral Editorial: accent bar and coloured label.
// ---------------------------------------------------------------------------

class _StripRow extends StatelessWidget {
  final _EventData event;
  const _StripRow({required this.event});

  // Left accent bar — Neutral Editorial palette.
  Color get _barColor => switch (event.type) {
    _EventType.miss => const Color(0xFFC8C0AE),
    _EventType.hit => const Color(0xFF3FB6B0),
    _EventType.sunk => const Color(0xFFB85020),
    _EventType.won => const Color(0xFF1A8A50),
  };

  // Uppercase label color — matches bar tone, slightly darker.
  Color get _labelColor => switch (event.type) {
    _EventType.miss => const Color(0xFF9A8E70),
    _EventType.hit => const Color(0xFF1A4F4C),
    _EventType.sunk => const Color(0xFF8A3818),
    _EventType.won => const Color(0xFF0E5A33),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left accent bar
        Container(
          width: 3,
          height: 32,
          decoration: BoxDecoration(
            color: _barColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 11),

        // Tag on line 1, message on line 2
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.tag.toUpperCase(),
                style: AppTextStyles.eventTag.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _labelColor,
                  letterSpacing: 0.13 * 9.5,
                  height: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                event.message,
                style: AppTextStyles.eventMessage.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2A2A28),
                  height: 1.08,
                ),
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
