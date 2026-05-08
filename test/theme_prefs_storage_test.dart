import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_battleship/services/theme_prefs_storage.dart';
import 'package:word_battleship/theme/theme_variant.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('empty store returns null', () async {
    final loaded = await ThemePrefsStorage.loadPreference();
    expect(loaded, isNull);
  });

  test('round-trips every WordBattleThemePreference value', () async {
    for (final pref in WordBattleThemePreference.values) {
      SharedPreferences.setMockInitialValues({});
      await ThemePrefsStorage.savePreference(pref);
      final loaded = await ThemePrefsStorage.loadPreference();
      expect(loaded, pref, reason: 'preference $pref must round-trip');
    }
  });

  test('unknown raw value returns null', () async {
    SharedPreferences.setMockInitialValues({
      'word-battleship-theme-pref-v1': 'crimson',
    });

    final loaded = await ThemePrefsStorage.loadPreference();
    expect(loaded, isNull);
  });
}
