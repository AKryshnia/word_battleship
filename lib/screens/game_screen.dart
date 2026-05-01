import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../theme/board_style.dart';
import '../widgets/game_shell.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  // Visual board style — held in screen state so swapping it does not touch
  // game logic or trigger any provider rebuild. Defaults to Modern (Ink on
  // Paper); persistence is intentionally not added here since the project's
  // existing storage layer is scoped to game state, not preferences.
  BoardVisualStyle _boardStyle = BoardStylePresets.defaultStyle;

  @override
  void initState() {
    super.initState();
    // Apply the real layout profile on the first frame when context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profile = _layoutProfile(context);
      final current = ref.read(gameProvider).layoutProfile;
      if (current != profile) {
        ref.read(gameProvider.notifier).resetGame(profile);
      }
    });
  }

  EdgeInsets _outerPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 420) return const EdgeInsets.symmetric(horizontal: 6, vertical: 6);
    if (width < 700) return const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  }

  LayoutProfile _layoutProfile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 420) return LayoutProfile.compact;
    if (width < 700) return LayoutProfile.medium;
    return LayoutProfile.wide;
  }

  void _onStyleChange(BoardVisualStyle style) {
    if (style == _boardStyle) return;
    setState(() => _boardStyle = style);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: _outerPadding(context),
          child: Column(
            // CrossAxisAlignment.center + ConstrainedBox(maxWidth) below
            // centres the shell on wide screens while filling narrow ones.
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: SizedBox(
                    width: double.infinity,
                    child: GameShell(
                      gameState: gameState,
                      onReset: () =>
                          notifier.resetGame(_layoutProfile(context)),
                      onCellClick: (row, col) =>
                          notifier.handleCellClick(row, col),
                      boardStyle: _boardStyle,
                      onStyleChange: _onStyleChange,
                    ),
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
