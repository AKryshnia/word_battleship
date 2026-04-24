import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:word_battleship/main.dart';

void main() {
  testWidgets('renders the game screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: WordBattleshipApp()));

    expect(find.text('Word Battleship'), findsOneWidget);
    expect(find.text('Game in Progress'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('Total Ships'), findsOneWidget);
    expect(find.text('Ships Left'), findsOneWidget);
    expect(find.text('Sunk'), findsOneWidget);
    expect(find.text('Moves'), findsOneWidget);
    expect(find.text('Hits'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
  });
}
