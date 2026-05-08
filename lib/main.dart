import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/game_provider.dart';
import 'screens/theme_splash_screen.dart';
import 'services/storage_service.dart';
import 'services/theme_prefs_storage.dart';
import 'theme/app_theme.dart';
import 'theme/theme_variant.dart';
import 'theme/theme_variant_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final savedGame = await StorageService.loadGameState();
  final savedTheme = await ThemePrefsStorage.loadPreference();

  runApp(
    ProviderScope(
      overrides: [
        gameProvider.overrideWith(() => GameProvider(initial: savedGame)),
        themeVariantProvider.overrideWith(
          () => ThemeVariantNotifier(initial: savedTheme),
        ),
      ],
      child: const WordBattleshipApp(),
    ),
  );
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
      home: const ThemeSplashScreen(),
    );
  }
}
