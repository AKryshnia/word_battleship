import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_variant.dart';

class ThemePrefsStorage {
  static const String _key = 'word-battleship-theme-pref-v1';

  static Future<void> savePreference(
    WordBattleThemePreference preference,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, preference.name);
  }

  static Future<WordBattleThemePreference?> loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;
      for (final pref in WordBattleThemePreference.values) {
        if (pref.name == raw) return pref;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
