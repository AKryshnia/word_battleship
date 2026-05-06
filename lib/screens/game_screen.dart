import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_variant.dart';
import '../theme/theme_variant_provider.dart';
import '../widgets/game_shell.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
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
    if (width < 420) {
      return const EdgeInsets.symmetric(horizontal: 6, vertical: 6);
    }
    if (width < 700) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    }
    return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  }

  LayoutProfile _layoutProfile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 420) return LayoutProfile.compact;
    if (width < 700) return LayoutProfile.medium;
    return LayoutProfile.wide;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    final preference = ref.watch(themeVariantProvider);
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final boardStyleConfig = preference
        .resolveVariant(platformBrightness)
        .boardStyle;

    return Scaffold(
      backgroundColor: context.wbTokens.background,
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
                      boardStyleConfig: boardStyleConfig,
                      currentThemePreference: preference,
                      onThemePreferenceChanged: ref
                          .read(themeVariantProvider.notifier)
                          .set,
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
