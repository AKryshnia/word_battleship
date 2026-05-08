import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/theme_prefs_storage.dart';
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
  ThemeVariantNotifier({this.initial});

  final WordBattleThemePreference? initial;

  @override
  WordBattleThemePreference build() => initial ?? _initialPreference();

  void set(WordBattleThemePreference preference) {
    state = preference;
    unawaited(ThemePrefsStorage.savePreference(preference).catchError((_) {}));
  }
}

final themeVariantProvider =
    NotifierProvider<ThemeVariantNotifier, WordBattleThemePreference>(
      ThemeVariantNotifier.new,
    );
