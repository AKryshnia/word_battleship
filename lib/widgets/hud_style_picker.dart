import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/board_style.dart';
import '../theme/theme_variant.dart';

// Style picker button — palette icon that opens a compact popup menu listing
// the 4 theme preferences. Current selection is shown with a check; tapping any
// entry applies the preference immediately via [onSelected].
class HudStylePicker extends StatefulWidget {
  final WordBattleThemePreference current;
  final ValueChanged<WordBattleThemePreference> onSelected;

  const HudStylePicker({
    super.key,
    required this.current,
    required this.onSelected,
  });

  @override
  State<HudStylePicker> createState() => _HudStylePickerState();
}

class _HudStylePickerState extends State<HudStylePicker> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.wbTokens;
    final iconColor = _hovered ? tokens.accentHover : tokens.accent;

    return MouseRegion(
      onEnter: (_) {
        if (mounted) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (mounted) setState(() => _hovered = false);
      },
      child: PopupMenuButton<WordBattleThemePreference>(
        tooltip: 'Тема',
        initialValue: widget.current,
        onSelected: widget.onSelected,
        offset: const Offset(0, 36),
        position: PopupMenuPosition.under,
        color: tokens.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          side: BorderSide(color: tokens.border),
        ),
        itemBuilder: (context) => [
          for (final pref in WordBattleThemePreference.values)
            PopupMenuItem<WordBattleThemePreference>(
              value: pref,
              height: 40,
              child: _StyleMenuItem(
                isSelected: pref == widget.current,
                child: _StyleMenuRow(
                  pref: pref,
                  isSelected: pref == widget.current,
                ),
              ),
            ),
        ],
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: tokens.surface2,
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            border: Border.all(color: tokens.border),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.style_outlined, size: 17, color: iconColor),
        ),
      ),
    );
  }
}

class _StyleMenuItem extends StatefulWidget {
  final bool isSelected;
  final Widget child;

  const _StyleMenuItem({required this.isSelected, required this.child});

  @override
  State<_StyleMenuItem> createState() => _StyleMenuItemState();
}

class _StyleMenuItemState extends State<_StyleMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) return widget.child;

    final bg = widget.isSelected
        ? const Color(0x243FB6B0)
        : (_hovered ? context.wbTokens.surface3 : Colors.transparent);

    return MouseRegion(
      onEnter: (_) {
        if (mounted) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (mounted) setState(() => _hovered = false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: widget.child,
      ),
    );
  }
}

class _StyleMenuRow extends StatelessWidget {
  final WordBattleThemePreference pref;
  final bool isSelected;

  const _StyleMenuRow({required this.pref, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final cfg = _swatchConfig(pref);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StyleSwatch(config: cfg),
        const SizedBox(width: 10),
        Text(
          pref.label,
          style: AppTextStyles.hudStatus.copyWith(
            color: context.wbTokens.text1,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        if (isSelected)
          Icon(Icons.check, size: 16, color: context.wbTokens.accent)
        else
          const SizedBox(width: 16),
      ],
    );
  }
}

BoardStyleConfig _swatchConfig(WordBattleThemePreference pref) {
  return switch (pref) {
    WordBattleThemePreference.system =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? BoardStylePresets.graphiteInk
          : BoardStylePresets.modernInk,
    WordBattleThemePreference.paper => BoardStylePresets.modernInk,
    WordBattleThemePreference.graphite => BoardStylePresets.graphiteInk,
    WordBattleThemePreference.fluffy => BoardStylePresets.fluffy,
  };
}

class _StyleSwatch extends StatelessWidget {
  final BoardStyleConfig config;
  const _StyleSwatch({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: config.boardBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.wbTokens.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _swatchCell(config.cellDefault),
          const SizedBox(width: 2),
          _swatchCell(config.cellHit),
          const SizedBox(width: 2),
          _swatchCell(config.cellMiss),
        ],
      ),
    );
  }

  Widget _swatchCell(CellVisual v) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: v.background,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: v.borderColor, width: 0.8),
      ),
    );
  }
}
