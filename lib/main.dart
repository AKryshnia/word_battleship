import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/game_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_variant.dart';
import 'theme/theme_variant_provider.dart';

void main() {
  runApp(const ProviderScope(child: WordBattleshipApp()));
}

class WordBattleshipApp extends ConsumerWidget {
  const WordBattleshipApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(themeVariantProvider);
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final variant = preference.resolveVariant(platformBrightness);

    final theme = switch (variant) {
      WordBattleThemeVariant.paper => AppTheme.light(),
      WordBattleThemeVariant.graphite => AppTheme.dark(),
      WordBattleThemeVariant.fluffy => AppTheme.fluffy(),
    };

    return MaterialApp(
      title: 'WordBattle',
      debugShowCheckedModeBanner: false,
      theme: theme,
      themeMode: ThemeMode.light,
      home: const GameScreen(),
    );
  }
}
