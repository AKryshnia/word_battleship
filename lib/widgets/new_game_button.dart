import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NewGameButton extends StatelessWidget {
  final VoidCallback onPressed;
  const NewGameButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? const Color(0xFF7CD4CE) : const Color(0xFF1A4F4C);
    final border = isDark ? const Color(0x333FB6B0) : Colors.transparent;
    final style = TextButton.styleFrom(
      backgroundColor: isDark ? null : const Color(0xFFD6EEEB),
      foregroundColor: fg,
      overlayColor: isDark ? Colors.transparent : fg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        side: BorderSide(color: border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return TextButton(
      onPressed: onPressed,
      style: isDark
          ? style.copyWith(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return const Color(0x4D3FB6B0);
                }
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.focused)) {
                  return const Color(0x383FB6B0);
                }
                return const Color(0x243FB6B0);
              }),
            )
          : style,
      child: Text('Новая игра', style: AppTextStyles.newGameButton),
    );
  }
}
