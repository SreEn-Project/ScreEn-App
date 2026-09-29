import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';

/// 모서리 24dp 흰 카드 + 옅고 넓은 그림자 (docs/design.md).
/// [gradient]를 주면 배경 대신 그라데이션을 쓴다 (홈 상단 카드 전용).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTokens.pagePadding),
    this.color,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTokens.radiusCard);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ?? Theme.of(context).colorScheme.surface)
            : null,
        gradient: gradient,
        borderRadius: radius,
        boxShadow: context.tokens.cardShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
