import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/game_screen.dart';
import 'theme/app_theme.dart';

const _themeModeDefine = String.fromEnvironment(
  'WB_THEME_MODE',
  defaultValue: 'system',
);

ThemeMode _resolveThemeMode() {
  return switch (_themeModeDefine) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.system,
  };
}

void main() {
  runApp(const ProviderScope(child: WordBattleshipApp()));
}

class WordBattleshipApp extends StatelessWidget {
  const WordBattleshipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordBattle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _resolveThemeMode(),
      home: const GameScreen(),
    );
  }
}
