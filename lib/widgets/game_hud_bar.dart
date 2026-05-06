import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/theme_variant.dart';
import 'hud_stats.dart';
import 'theme_preference_picker.dart';
import 'new_game_button.dart';
import 'word_battle_logo.dart';

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
  final WordBattleThemePreference currentThemePreference;
  final ValueChanged<WordBattleThemePreference> onThemePreferenceChanged;

  const GameHudBar({
    super.key,
    required this.gameState,
    required this.onReset,
    required this.currentThemePreference,
    required this.onThemePreferenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isFinished = gameState.isFinished;
    final shipsLeft = gameState.ships.where((s) => !s.sunk).length;
    final totalShips = gameState.ships.length;
    final moves = gameState.movesCount;
    final hits = gameState.hitsCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return _buildMobileHud(
            context,
            isFinished,
            moves,
            hits,
            shipsLeft,
            totalShips,
          );
        }
        return _buildDesktopHud(
          context,
          isFinished,
          moves,
          hits,
          shipsLeft,
          totalShips,
        );
      },
    );
  }

  // ── Desktop: single 54 px row ─────────────────────────────────────────────

  Widget _buildDesktopHud(
    BuildContext context,
    bool isFinished,
    int moves,
    int hits,
    int shipsLeft,
    int totalShips,
  ) {
    final tokens = context.wbTokens;

    return Container(
      height: AppDimensions.hudHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.shellPadH),
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(bottom: BorderSide(color: tokens.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: WordBattleLogo(markSize: 24),
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
                child: HudStatsRow(
                  moves: moves,
                  hits: hits,
                  shipsLeft: shipsLeft,
                  totalShips: totalShips,
                ),
              ),
              const SizedBox(width: 6),
              ThemePreferencePicker(
                current: currentThemePreference,
                onSelected: onThemePreferenceChanged,
              ),
              const SizedBox(width: 6),
              SizedBox(height: 32, child: NewGameButton(onPressed: onReset)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Mobile: two rows ──────────────────────────────────────────────────────

  Widget _buildMobileHud(
    BuildContext context,
    bool isFinished,
    int moves,
    int hits,
    int shipsLeft,
    int totalShips,
  ) {
    final tokens = context.wbTokens;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1: brand · pipe · status · button
        // Tighter padding + a FittedBox on the brand so the full "WordBattle"
        // word always fits next to the picker / new-game cluster on narrow
        // shells, instead of clipping at the last few characters.
        SizedBox(
          height: 42,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: WordBattleLogo(markSize: 20),
                        ),
                      ),
                      _Pipe(horizontalMargin: 8),
                      Flexible(
                        fit: FlexFit.loose,
                        child: _StatusRow(
                          isFinished: isFinished,
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ThemePreferencePicker(
                  current: currentThemePreference,
                  onSelected: onThemePreferenceChanged,
                ),
                const SizedBox(width: 4),
                NewGameButton(onPressed: onReset),
              ],
            ),
          ),
        ),
        // Row 2: stats on surface2 background
        Container(
          height: 26,
          color: tokens.surface2,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.shellPadH,
          ),
          alignment: Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: HudStatsRow(
              moves: moves,
              hits: hits,
              shipsLeft: shipsLeft,
              totalShips: totalShips,
            ),
          ),
        ),
      ],
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
      color: context.wbTokens.border,
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status pip + label
// ─────────────────────────────────────────────────────────────────────────────

class _StatusRow extends StatelessWidget {
  final bool isFinished;
  final bool compact;
  const _StatusRow({required this.isFinished, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final tokens = context.wbTokens;
    final dotColor = isFinished ? tokens.green : tokens.accent;
    final haloColor = isFinished
        ? tokens.green.withValues(alpha: 0.12)
        : tokens.accentFaint;

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
            isFinished
                ? (compact ? 'Завершена' : 'Игра завершена')
                : 'Игра идёт',
            style: AppTextStyles.hudStatus.copyWith(color: tokens.text2),
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}
