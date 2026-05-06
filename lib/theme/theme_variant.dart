import 'package:flutter/material.dart';

import 'board_style.dart';

enum WordBattleThemeVariant { paper, graphite, fluffy }

extension WordBattleThemeVariantLabels on WordBattleThemeVariant {
  String get label => switch (this) {
    WordBattleThemeVariant.paper => 'Paper',
    WordBattleThemeVariant.graphite => 'Graphite',
    WordBattleThemeVariant.fluffy => 'Fluffy',
  };

  String get shortLabel => switch (this) {
    WordBattleThemeVariant.paper => 'Paper',
    WordBattleThemeVariant.graphite => 'Dark',
    WordBattleThemeVariant.fluffy => 'Pink',
  };

  BoardStyleConfig get boardStyle => switch (this) {
    WordBattleThemeVariant.paper => BoardStylePresets.modernInk,
    WordBattleThemeVariant.graphite => BoardStylePresets.graphiteInk,
    WordBattleThemeVariant.fluffy => BoardStylePresets.fluffy,
  };

  bool get isDark => this == WordBattleThemeVariant.graphite;
}

enum WordBattleThemePreference { system, paper, graphite, fluffy }

extension WordBattleThemePreferenceExt on WordBattleThemePreference {
  String get label => switch (this) {
    WordBattleThemePreference.system => 'Система',
    WordBattleThemePreference.paper => 'Светлая',
    WordBattleThemePreference.graphite => 'Темная',
    WordBattleThemePreference.fluffy => 'Розовая',
  };

  String get shortLabel => switch (this) {
    WordBattleThemePreference.system => 'Авто',
    WordBattleThemePreference.paper => 'Светлая',
    WordBattleThemePreference.graphite => 'Темная',
    WordBattleThemePreference.fluffy => 'Розовая',
  };

  WordBattleThemeVariant resolveVariant(Brightness platformBrightness) =>
      switch (this) {
        WordBattleThemePreference.system =>
          platformBrightness == Brightness.dark
              ? WordBattleThemeVariant.graphite
              : WordBattleThemeVariant.paper,
        WordBattleThemePreference.paper => WordBattleThemeVariant.paper,
        WordBattleThemePreference.graphite => WordBattleThemeVariant.graphite,
        WordBattleThemePreference.fluffy => WordBattleThemeVariant.fluffy,
      };
}
