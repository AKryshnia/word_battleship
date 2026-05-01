import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/game_screen.dart';
import 'theme/app_theme.dart';

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
      home: const GameScreen(),
    );
  }
}
