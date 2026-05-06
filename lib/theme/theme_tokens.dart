import 'package:flutter/material.dart';

extension WordBattleTheme on BuildContext {
  WordBattleThemeTokens get wbTokens =>
      Theme.of(this).extension<WordBattleThemeTokens>()!;
}

@immutable
class WordBattleThemeTokens extends ThemeExtension<WordBattleThemeTokens> {
  final Color background;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color border;
  final Color borderSubtle;
  final Color borderStrong;
  final Color text1;
  final Color text2;
  final Color text3;
  final Color accent;
  final Color accentHover;
  final Color accentPressed;
  final Color accentFaint;
  final Color accentMid;
  final Color accentGlow;
  final Color amber;
  final Color red;
  final Color green;
  final Color onAccent;
  final Color eventStripBackground;
  final Color eventStripBorder;
  final Color eventMissBar;
  final Color eventMissLabel;
  final Color eventHitBar;
  final Color eventHitLabel;
  final Color eventSunkBar;
  final Color eventSunkLabel;
  final Color eventWonBar;
  final Color eventWonLabel;
  final Color eventMessage;
  final Color moveLogBackground;
  final Color moveLogBorderTop;
  final Color moveLogHeader;
  final Color moveLogMissChipBackground;
  final Color moveLogMissChipBorder;
  final Color moveLogMissChipText;
  final Color moveLogHitChipBackground;
  final Color moveLogHitChipBorder;
  final Color moveLogHitChipText;

  const WordBattleThemeTokens({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.border,
    required this.borderSubtle,
    required this.borderStrong,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.accent,
    required this.accentHover,
    required this.accentPressed,
    required this.accentFaint,
    required this.accentMid,
    required this.accentGlow,
    required this.amber,
    required this.red,
    required this.green,
    required this.onAccent,
    required this.eventStripBackground,
    required this.eventStripBorder,
    required this.eventMissBar,
    required this.eventMissLabel,
    required this.eventHitBar,
    required this.eventHitLabel,
    required this.eventSunkBar,
    required this.eventSunkLabel,
    required this.eventWonBar,
    required this.eventWonLabel,
    required this.eventMessage,
    required this.moveLogBackground,
    required this.moveLogBorderTop,
    required this.moveLogHeader,
    required this.moveLogMissChipBackground,
    required this.moveLogMissChipBorder,
    required this.moveLogMissChipText,
    required this.moveLogHitChipBackground,
    required this.moveLogHitChipBorder,
    required this.moveLogHitChipText,
  });

  static const light = WordBattleThemeTokens(
    background: Color(0xFFF8F6F1),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF4F2EB),
    surface3: Color(0xFFEDE9E0),
    border: Color(0xFFDDD8D1),
    borderSubtle: Color(0xFFEBE7E1),
    borderStrong: Color(0xFFC8C2BA),
    text1: Color(0xFF1E1B17),
    text2: Color(0xFF5A5450),
    text3: Color(0xFF9C9488),
    accent: Color(0xFF3FB6B0),
    accentHover: Color(0xFF2A9490),
    accentPressed: Color(0xFF1A4F4C),
    accentFaint: Color(0x173FB6B0),
    accentMid: Color(0x2E3FB6B0),
    accentGlow: Color(0x383FB6B0),
    amber: Color(0xFFC06A14),
    red: Color(0xFFC05C3C),
    green: Color(0xFF1A9E60),
    onAccent: Colors.white,
    eventStripBackground: Color(0xFFFFFFFF),
    eventStripBorder: Color(0xFFEBE7E1),
    eventMissBar: Color(0xFFC8C0AE),
    eventMissLabel: Color(0xFF9A8E70),
    eventHitBar: Color(0xFF3FB6B0),
    eventHitLabel: Color(0xFF1A4F4C),
    eventSunkBar: Color(0xFFB85020),
    eventSunkLabel: Color(0xFF8A3818),
    eventWonBar: Color(0xFF1A8A50),
    eventWonLabel: Color(0xFF0E5A33),
    eventMessage: Color(0xFF2A2A28),
    moveLogBackground: Color(0xFFFFFFFF),
    moveLogBorderTop: Color(0xFFEBE7E1),
    moveLogHeader: Color(0xFF9C9488),
    moveLogMissChipBackground: Color(0xFFF8F6F1),
    moveLogMissChipBorder: Color(0xFFDDD8D1),
    moveLogMissChipText: Color(0xFF9C9488),
    moveLogHitChipBackground: Color(0x14C05C3C),
    moveLogHitChipBorder: Color(0x28C05C3C),
    moveLogHitChipText: Color(0xFF9A4428),
  );

  static const dark = WordBattleThemeTokens(
    background: Color(0xFF181715),
    surface: Color(0xFF222220),
    surface2: Color(0xFF2A2A28),
    surface3: Color(0xFF33332F),
    border: Color(0xFF3A3A37),
    borderSubtle: Color(0xFF2E2E2C),
    borderStrong: Color(0xFF4A4A45),
    text1: Color(0xFFF0EAD9),
    text2: Color(0xFFADA89B),
    text3: Color(0xFF6E6A60),
    accent: Color(0xFF3FB6B0),
    accentHover: Color(0xFF5BC8C2),
    accentPressed: Color(0xFF2C9A94),
    accentFaint: Color(0x1C3FB6B0),
    accentMid: Color(0x383FB6B0),
    accentGlow: Color(0x4D3FB6B0),
    amber: Color(0xFFE2A340),
    red: Color(0xFFDC5A32),
    green: Color(0xFF42C17A),
    onAccent: Color(0xFF0A2827),
    eventStripBackground: Color(0xFF222220),
    eventStripBorder: Color(0xFF2E2E2C),
    eventMissBar: Color(0xFF5A564C),
    eventMissLabel: Color(0xFF988F7E),
    eventHitBar: Color(0xFF3FB6B0),
    eventHitLabel: Color(0xFF7CD4CE),
    eventSunkBar: Color(0xFFDC5A32),
    eventSunkLabel: Color(0xFFEC885E),
    eventWonBar: Color(0xFF42C17A),
    eventWonLabel: Color(0xFF82D6A4),
    eventMessage: Color(0xFFE8E2D0),
    moveLogBackground: Color(0xFF222220),
    moveLogBorderTop: Color(0xFF2E2E2C),
    moveLogHeader: Color(0xFF6E6A60),
    moveLogMissChipBackground: Color(0xFF26261F),
    moveLogMissChipBorder: Color(0xFF3A3A37),
    moveLogMissChipText: Color(0xFF988F7E),
    moveLogHitChipBackground: Color(0x1C3FB6B0),
    moveLogHitChipBorder: Color(0x423FB6B0),
    moveLogHitChipText: Color(0xFF7CD4CE),
  );

  @override
  WordBattleThemeTokens copyWith({
    Color? background,
    Color? surface,
    Color? surface2,
    Color? surface3,
    Color? border,
    Color? borderSubtle,
    Color? borderStrong,
    Color? text1,
    Color? text2,
    Color? text3,
    Color? accent,
    Color? accentHover,
    Color? accentPressed,
    Color? accentFaint,
    Color? accentMid,
    Color? accentGlow,
    Color? amber,
    Color? red,
    Color? green,
    Color? onAccent,
    Color? eventStripBackground,
    Color? eventStripBorder,
    Color? eventMissBar,
    Color? eventMissLabel,
    Color? eventHitBar,
    Color? eventHitLabel,
    Color? eventSunkBar,
    Color? eventSunkLabel,
    Color? eventWonBar,
    Color? eventWonLabel,
    Color? eventMessage,
    Color? moveLogBackground,
    Color? moveLogBorderTop,
    Color? moveLogHeader,
    Color? moveLogMissChipBackground,
    Color? moveLogMissChipBorder,
    Color? moveLogMissChipText,
    Color? moveLogHitChipBackground,
    Color? moveLogHitChipBorder,
    Color? moveLogHitChipText,
  }) {
    return WordBattleThemeTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      text1: text1 ?? this.text1,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      accentPressed: accentPressed ?? this.accentPressed,
      accentFaint: accentFaint ?? this.accentFaint,
      accentMid: accentMid ?? this.accentMid,
      accentGlow: accentGlow ?? this.accentGlow,
      amber: amber ?? this.amber,
      red: red ?? this.red,
      green: green ?? this.green,
      onAccent: onAccent ?? this.onAccent,
      eventStripBackground: eventStripBackground ?? this.eventStripBackground,
      eventStripBorder: eventStripBorder ?? this.eventStripBorder,
      eventMissBar: eventMissBar ?? this.eventMissBar,
      eventMissLabel: eventMissLabel ?? this.eventMissLabel,
      eventHitBar: eventHitBar ?? this.eventHitBar,
      eventHitLabel: eventHitLabel ?? this.eventHitLabel,
      eventSunkBar: eventSunkBar ?? this.eventSunkBar,
      eventSunkLabel: eventSunkLabel ?? this.eventSunkLabel,
      eventWonBar: eventWonBar ?? this.eventWonBar,
      eventWonLabel: eventWonLabel ?? this.eventWonLabel,
      eventMessage: eventMessage ?? this.eventMessage,
      moveLogBackground: moveLogBackground ?? this.moveLogBackground,
      moveLogBorderTop: moveLogBorderTop ?? this.moveLogBorderTop,
      moveLogHeader: moveLogHeader ?? this.moveLogHeader,
      moveLogMissChipBackground:
          moveLogMissChipBackground ?? this.moveLogMissChipBackground,
      moveLogMissChipBorder:
          moveLogMissChipBorder ?? this.moveLogMissChipBorder,
      moveLogMissChipText: moveLogMissChipText ?? this.moveLogMissChipText,
      moveLogHitChipBackground:
          moveLogHitChipBackground ?? this.moveLogHitChipBackground,
      moveLogHitChipBorder: moveLogHitChipBorder ?? this.moveLogHitChipBorder,
      moveLogHitChipText: moveLogHitChipText ?? this.moveLogHitChipText,
    );
  }

  @override
  WordBattleThemeTokens lerp(
    ThemeExtension<WordBattleThemeTokens>? other,
    double t,
  ) {
    if (other is! WordBattleThemeTokens) return this;
    return WordBattleThemeTokens(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      text1: Color.lerp(text1, other.text1, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      accentPressed: Color.lerp(accentPressed, other.accentPressed, t)!,
      accentFaint: Color.lerp(accentFaint, other.accentFaint, t)!,
      accentMid: Color.lerp(accentMid, other.accentMid, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      red: Color.lerp(red, other.red, t)!,
      green: Color.lerp(green, other.green, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      eventStripBackground: Color.lerp(
        eventStripBackground,
        other.eventStripBackground,
        t,
      )!,
      eventStripBorder: Color.lerp(
        eventStripBorder,
        other.eventStripBorder,
        t,
      )!,
      eventMissBar: Color.lerp(eventMissBar, other.eventMissBar, t)!,
      eventMissLabel: Color.lerp(eventMissLabel, other.eventMissLabel, t)!,
      eventHitBar: Color.lerp(eventHitBar, other.eventHitBar, t)!,
      eventHitLabel: Color.lerp(eventHitLabel, other.eventHitLabel, t)!,
      eventSunkBar: Color.lerp(eventSunkBar, other.eventSunkBar, t)!,
      eventSunkLabel: Color.lerp(eventSunkLabel, other.eventSunkLabel, t)!,
      eventWonBar: Color.lerp(eventWonBar, other.eventWonBar, t)!,
      eventWonLabel: Color.lerp(eventWonLabel, other.eventWonLabel, t)!,
      eventMessage: Color.lerp(eventMessage, other.eventMessage, t)!,
      moveLogBackground: Color.lerp(
        moveLogBackground,
        other.moveLogBackground,
        t,
      )!,
      moveLogBorderTop: Color.lerp(
        moveLogBorderTop,
        other.moveLogBorderTop,
        t,
      )!,
      moveLogHeader: Color.lerp(moveLogHeader, other.moveLogHeader, t)!,
      moveLogMissChipBackground: Color.lerp(
        moveLogMissChipBackground,
        other.moveLogMissChipBackground,
        t,
      )!,
      moveLogMissChipBorder: Color.lerp(
        moveLogMissChipBorder,
        other.moveLogMissChipBorder,
        t,
      )!,
      moveLogMissChipText: Color.lerp(
        moveLogMissChipText,
        other.moveLogMissChipText,
        t,
      )!,
      moveLogHitChipBackground: Color.lerp(
        moveLogHitChipBackground,
        other.moveLogHitChipBackground,
        t,
      )!,
      moveLogHitChipBorder: Color.lerp(
        moveLogHitChipBorder,
        other.moveLogHitChipBorder,
        t,
      )!,
      moveLogHitChipText: Color.lerp(
        moveLogHitChipText,
        other.moveLogHitChipText,
        t,
      )!,
    );
  }
}
