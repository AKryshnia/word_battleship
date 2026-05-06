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
