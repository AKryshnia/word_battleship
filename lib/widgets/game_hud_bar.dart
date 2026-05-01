import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

/// Compact top bar inside the shell.
///
/// Desktop (≥ 480 px): single 54 px row — brand · pipe · status | stats · button.
/// Mobile  (< 480 px): two-row layout —
///   row 1 (42 px): brand · pipe · status · button
///   row 2 (26 px): stats strip on surface2 bg
///
/// Overflow strategy:
///   - brand and status are Flexible(loose) so they shrink under tight budgets.
///   - stats use FittedBox(scaleDown) so they scale rather than overflow.
///   - tests run without Google Fonts (fallback fonts are wider than Manrope);
///     the desktop layout is overflow-proof under any font metrics.
class GameHudBar extends StatelessWidget {
  final SoloGameState gameState;
  final VoidCallback onReset;

  const GameHudBar({
    super.key,
    required this.gameState,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isFinished = gameState.isFinished;
    final shipsLeft = gameState.ships.where((s) => !s.sunk).length;
    final totalShips = gameState.ships.length;
    final moves = gameState.movesCount;
    final hits = gameState.hitsCount;

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 480) {
        return _buildMobileHud(isFinished, moves, hits, shipsLeft, totalShips);
      }
      return _buildDesktopHud(isFinished, moves, hits, shipsLeft, totalShips);
    });
  }

  // ── Desktop: single 54 px row ─────────────────────────────────────────────

  Widget _buildDesktopHud(
    bool isFinished,
    int moves,
    int hits,
    int shipsLeft,
    int totalShips,
  ) {
    return Container(
      height: AppDimensions.hudHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.shellPadH,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: _brandText(),
                ),
                _Pipe(horizontalMargin: 16),
                Flexible(
                  fit: FlexFit.loose,
                  child: _StatusRow(isFinished: isFinished),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: _HudStatsRow(
                  moves: moves,
                  hits: hits,
                  shipsLeft: shipsLeft,
                  totalShips: totalShips,
                ),
              ),
              const SizedBox(width: 10),
              _NewGameButton(onPressed: onReset),
            ],
          ),
        ],
      ),
    );
  }

  // ── Mobile: two rows ──────────────────────────────────────────────────────

  Widget _buildMobileHud(
    bool isFinished,
    int moves,
    int hits,
    int shipsLeft,
    int totalShips,
  ) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: brand · pipe · status · button
          SizedBox(
            height: 42,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.shellPadH,
              ),
              child: Row(
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: _brandText(),
                        ),
                        _Pipe(horizontalMargin: 12),
                        Flexible(
                          fit: FlexFit.loose,
                          child: _StatusRow(isFinished: isFinished),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _NewGameButton(onPressed: onReset),
                ],
              ),
            ),
          ),
          // Row 2: stats on surface2 background
          Container(
            height: 26,
            color: AppColors.surface2,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.shellPadH,
            ),
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: _HudStatsRow(
                moves: moves,
                hits: hits,
                shipsLeft: shipsLeft,
                totalShips: totalShips,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandText() {
    return Text.rich(
      TextSpan(
        style: AppTextStyles.hudBrand.copyWith(color: AppColors.text1),
        children: const [
          TextSpan(text: 'Word'),
          TextSpan(
            text: 'Battle',
            style: TextStyle(color: AppColors.accent),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.clip,
      softWrap: false,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vertical separator
// ─────────────────────────────────────────────────────────────────────────────

class _Pipe extends StatelessWidget {
  final double horizontalMargin;
  const _Pipe({required this.horizontalMargin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 14,
      color: AppColors.border,
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status pip + label
// ─────────────────────────────────────────────────────────────────────────────

class _StatusRow extends StatelessWidget {
  final bool isFinished;
  const _StatusRow({required this.isFinished});

  @override
  Widget build(BuildContext context) {
    final dotColor = isFinished ? AppColors.statusWon : AppColors.accent;
    final haloColor = isFinished
        ? const Color(0x1F1A9E60)
        : AppColors.accentFaint;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: haloColor, spreadRadius: 3)],
          ),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            isFinished ? 'Игра завершена' : 'Игра идёт',
            style: AppTextStyles.hudStatus,
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats row — rendered at natural size; FittedBox above handles scaling.
// ─────────────────────────────────────────────────────────────────────────────

class _HudStatsRow extends StatelessWidget {
  final int moves, hits, shipsLeft, totalShips;

  const _HudStatsRow({
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
        _HudStatItem(value: '$moves', label: 'ходов', hasDivider: true),
        _HudStatItem(value: '$hits', label: 'попаданий', hasDivider: true),
        _HudStatItem(
          value: '$shipsLeft/$totalShips',
          label: 'кораблей',
          hasDivider: false,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single stat: bold number + small label, optionally with right border.
// ─────────────────────────────────────────────────────────────────────────────

class _HudStatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool hasDivider;

  const _HudStatItem({
    required this.value,
    required this.label,
    required this.hasDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: hasDivider
          ? const BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColors.borderSubtle),
              ),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(value, style: AppTextStyles.hudStatNum),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.hudStatLabel),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "Новая игра" button
// ─────────────────────────────────────────────────────────────────────────────

class _NewGameButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _NewGameButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text('Новая игра', style: AppTextStyles.newGameButton),
    );
  }
}
