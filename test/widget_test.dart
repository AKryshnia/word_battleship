import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:word_battleship/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders the game screen', (WidgetTester tester) async {
    // Use a desktop-sized surface so the HUD stats are visible.
    // The default test surface (800×600) causes overflow with fallback fonts
    // that don't match production Manrope metrics.
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: WordBattleshipApp()));
    // Advance past ThemeSplashScreen: 150 ms start delay + 2000 ms (assembly +
    // hold) + 350 ms fade route transition.
    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pumpAndSettle();

    // Brand text — rendered as Text.rich, toPlainText() == 'WordBattle'
    expect(find.text('WordBattle'), findsOneWidget);

    // HUD: status label
    expect(find.text('Игра идёт'), findsOneWidget);

    // HUD: new game button
    expect(find.text('Новая игра'), findsOneWidget);

    // HUD: inline stat labels (visible when shell width >= 480 px)
    expect(find.text('ходов'), findsOneWidget);
    expect(find.text('попаданий'), findsOneWidget);
    expect(find.text('кораблей'), findsOneWidget);
  });
}
