import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import 'pressable.dart';

/// 모서리 24dp 카드 + 1dp 옅은 테두리 + 약한 그림자 (docs/design.md).
/// 반복 목록 행마다 감싸지 말고, 목록은 카드 하나 안에 행 + 구분선으로 묶는다.
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
    this.bordered = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double radius;
  final bool shadow;

  /// 1dp 옅은 테두리. 그림자를 약하게 한 대신 표면 경계를 나눈다 (그라데이션 카드엔 안 그린다).
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ?? Theme.of(context).colorScheme.surface)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: bordered && gradient == null
            ? Border.all(color: Theme.of(context).colorScheme.outlineVariant)
            : null,
        boxShadow: shadow ? context.tokens.cardShadow : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;
    return Pressable(onTap: onTap, scale: 0.98, child: card);
  }
}
