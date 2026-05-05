import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/board_style.dart';

// Style picker button — palette icon that opens a compact popup menu listing
// the 4 visual styles. Current selection is shown with a check; tapping any
// entry applies the style immediately via [onSelected].
class HudStylePicker extends StatefulWidget {
  final BoardVisualStyle current;
  final ValueChanged<BoardVisualStyle> onSelected;

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
    // default: brand accent #3FB6B0 — matches "Battle" in logo
    // hover: ~75 % brightness of accent — visibly darker, still teal
    final iconColor = _hovered ? const Color(0xFF2A9490) : AppColors.accent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: PopupMenuButton<BoardVisualStyle>(
        tooltip: 'Стиль поля',
        initialValue: widget.current,
        onSelected: widget.onSelected,
        offset: const Offset(0, 36),
        position: PopupMenuPosition.under,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          side: const BorderSide(color: AppColors.border),
        ),
        itemBuilder: (context) => [
          for (final style in BoardVisualStyle.values)
            PopupMenuItem<BoardVisualStyle>(
              value: style,
              height: 40,
              child: _StyleMenuRow(
                style: style,
                isSelected: style == widget.current,
              ),
            ),
        ],
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.style_outlined, size: 17, color: iconColor),
        ),
      ),
    );
  }
}

class _StyleMenuRow extends StatelessWidget {
  final BoardVisualStyle style;
  final bool isSelected;

  const _StyleMenuRow({required this.style, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final cfg = BoardStylePresets.of(style);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StyleSwatch(config: cfg),
        const SizedBox(width: 10),
        Text(
          style.label,
          style: AppTextStyles.hudStatus.copyWith(
            color: AppColors.text1,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        if (isSelected)
          const Icon(Icons.check, size: 16, color: AppColors.accent)
        else
          const SizedBox(width: 16),
      ],
    );
  }
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
        border: Border.all(color: AppColors.borderSubtle),
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
