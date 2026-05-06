import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NewGameButton extends StatelessWidget {
  final VoidCallback onPressed;
  const NewGameButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final tokens = context.wbTokens;
    final style =
        TextButton.styleFrom(
          foregroundColor: tokens.newGameButtonText,
          overlayColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            side: BorderSide(color: tokens.newGameButtonBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return tokens.newGameButtonPressedBackground;
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return tokens.newGameButtonHoverBackground;
            }
            return tokens.newGameButtonBackground;
          }),
        );

    return TextButton(
      onPressed: onPressed,
      style: style,
      child: Text('Новая игра', style: AppTextStyles.newGameButton),
    );
  }
}
