import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import 'pressable.dart';

/// 모서리 24dp 카드 + 옅고 넓은 그림자 (docs/design.md).
/// [gradient]를 주면 배경 대신 그라데이션을 쓴다 (홈 상단 카드 전용).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTokens.pagePadding),
    this.color,
    this.gradient,
    this.onTap,
    this.radius = AppTokens.radiusCard,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double radius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ?? Theme.of(context).colorScheme.surface)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow ? context.tokens.cardShadow : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;
    return Pressable(onTap: onTap, scale: 0.98, child: card);
  }
}
