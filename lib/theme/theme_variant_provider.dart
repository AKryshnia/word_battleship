import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme_variant.dart';

const _wbThemeMode = String.fromEnvironment(
  'WB_THEME_MODE',
  defaultValue: 'system',
);

WordBattleThemePreference _initialPreference() {
  return switch (_wbThemeMode) {
    'light' => WordBattleThemePreference.paper,
    'dark' => WordBattleThemePreference.graphite,
    'fluffy' => WordBattleThemePreference.fluffy,
    'system' => WordBattleThemePreference.system,
    _ => WordBattleThemePreference.system,
  };
}

class ThemeVariantNotifier extends Notifier<WordBattleThemePreference> {
  @override
  WordBattleThemePreference build() => _initialPreference();

  void set(WordBattleThemePreference preference) => state = preference;
}

final themeVariantProvider =
    NotifierProvider<ThemeVariantNotifier, WordBattleThemePreference>(
      ThemeVariantNotifier.new,
    );
