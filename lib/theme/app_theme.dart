import 'package:flutter/material.dart';

import 'app_theme_dark.dart';
import 'app_theme_fluffy.dart';
import 'app_theme_light.dart';

export 'theme_foundation.dart';
export 'theme_tokens.dart';

// ═══════════════════════════════════════════════════════
// THEME
// ═══════════════════════════════════════════════════════

abstract final class AppTheme {
  static ThemeData light() => buildLightTheme();
  static ThemeData dark() => buildDarkTheme();
  static ThemeData fluffy() => buildFluffyTheme();
}
