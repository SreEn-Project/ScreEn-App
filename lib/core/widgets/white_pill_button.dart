import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';

/// 흰 알약 버튼 + 옅은 그림자. 온보딩 "시작하기 →" 같은 보조 강조 동작에 쓴다.
class WhitePillButton extends StatelessWidget {
  const WhitePillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        shadows: context.tokens.cardShadow,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.surface,
          foregroundColor: colors.primary,
          minimumSize: const Size.fromHeight(AppTokens.largeButtonHeight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
