import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import 'pressable.dart';

/// 모서리 24dp 카드 + 1dp 옅은 테두리 (그림자는 기본 없음, docs/design.md).
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
    this.shadow = false,
    this.bordered = true,
    this.elevated = false,
  });

  /// 테두리 없이 떠 보이는 카드 (큰 그림자). 화면에 붙은 구역 아래에서 덩어리 하나만 띄울 때 쓴다.
  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTokens.pagePadding),
    this.onTap,
    this.radius = AppTokens.radiusCard,
  }) : color = null,
       gradient = null,
       shadow = false,
       bordered = false,
       elevated = true;

  /// 테두리 · 그림자 · 배경 없는 평평한 구역. 카드 대신 구역을 선(구분선)과 큰 글자로 나눌 때 쓴다.
  const AppCard.flat({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.onTap,
  }) : color = Colors.transparent,
       gradient = null,
       radius = AppTokens.radiusCard,
       shadow = false,
       bordered = false,
       elevated = false;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double radius;
  final bool shadow;

  /// true면 짧고 진한 그림자로 화면 위에 확실히 떠 보인다.
  final bool elevated;

  /// 1dp 옅은 테두리. 그림자를 약하게 한 대신 표면 경계를 나눈다 (그라데이션 카드엔 안 그린다).
  final bool bordered;

  bool get isFlat =>
      bordered == false && shadow == false && color == Colors.transparent;

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
        boxShadow: elevated
            ? _elevatedShadow(Theme.of(context).colorScheme)
            : shadow
            ? context.tokens.cardShadow
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    final body = isFlat ? FlatScope(child: card) : card;
    if (onTap == null) return body;
    return Pressable(onTap: onTap, scale: 0.98, child: body);
  }
}

/// [AppCard.flat] 안임을 알린다: 안쪽 목록 행 · 구분선은 페이지 여백에 맞춰 좌우 패딩을 줄인다.
class FlatScope extends InheritedWidget {
  const FlatScope({super.key, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FlatScope>() != null;

  /// 평평한 구역 안 행의 좌우 패딩.
  static const double rowPaddingH = AppTokens.space4;

  @override
  bool updateShouldNotify(FlatScope oldWidget) => false;
}

/// 떠 보이는 카드의 그림자: 번지지 않고 짧고 진하게(가까운 그림자 + 받침 그림자).
List<BoxShadow> _elevatedShadow(ColorScheme colors) => [
  BoxShadow(
    color: colors.onSurface.withValues(alpha: 0.16),
    blurRadius: 4,
    offset: const Offset(0, 2),
  ),
  BoxShadow(
    color: colors.onSurface.withValues(alpha: 0.14),
    blurRadius: 12,
    offset: const Offset(0, 6),
  ),
];
