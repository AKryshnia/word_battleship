import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/plural_ru.dart';

class HudStatsRow extends StatelessWidget {
  final int moves, hits, shipsLeft, totalShips;

  const HudStatsRow({
    super.key,
    required this.moves,
    required this.hits,
    required this.shipsLeft,
    required this.totalShips,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HudStatItem(
          value: '$moves',
          label: pluralRu(moves, 'ход', 'хода', 'ходов'),
          hasDivider: true,
        ),
        HudStatItem(
          value: '$hits',
          label: pluralRu(hits, 'попадание', 'попадания', 'попаданий'),
          hasDivider: true,
        ),
        HudStatItem(
          value: '$shipsLeft/$totalShips',
          label: pluralRu(shipsLeft, 'корабль', 'корабля', 'кораблей'),
          hasDivider: false,
        ),
      ],
    );
  }
}

class HudStatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool hasDivider;

  const HudStatItem({
    super.key,
    required this.value,
    required this.label,
    required this.hasDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: hasDivider
          ? BoxDecoration(
              border: Border(
                right: BorderSide(color: context.wbTokens.borderSubtle),
              ),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            value,
            style: AppTextStyles.hudStatNum.copyWith(
              color: context.wbTokens.text1,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.hudStatLabel.copyWith(
              color: context.wbTokens.text3,
            ),
          ),
        ],
      ),
    );
  }
}
