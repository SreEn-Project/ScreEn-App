import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ColorScheme에 없는 디자인 토큰 (docs/design.md).
/// 화면에서는 `context.tokens`로 가져온다.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.background,
    required this.accent,
    required this.heroGradient,
    required this.cardShadow,
  });

  /// 화면 배경 (카드보다 한 단계 어두운 회녹색).
  final Color background;

  /// 상태 점 등 아주 작은 강조에만 쓴다.
  final Color accent;

  /// 홈 상단 상태 카드 전용.
  final Gradient heroGradient;

  /// 카드 · 흰 버튼의 옅고 넓은 그림자.
  final List<BoxShadow> cardShadow;

  static const double radiusCard = 24;
  static const double radiusSheet = 28;
  static const double radiusInput = 16;
  static const double pagePadding = 20;
  static const double largeButtonHeight = 56;

  static const light = AppTokens(
    background: AppColors.lightBackground,
    accent: AppColors.lightAccent,
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: AppColors.lightHeroGradient,
    ),
    cardShadow: [
      BoxShadow(
        color: AppColors.lightShadow,
        offset: Offset(0, 8),
        blurRadius: 24,
      ),
    ],
  );

  static const dark = AppTokens(
    background: AppColors.darkBackground,
    accent: AppColors.darkAccent,
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: AppColors.darkHeroGradient,
    ),
    cardShadow: [
      BoxShadow(
        color: AppColors.darkShadow,
        offset: Offset(0, 8),
        blurRadius: 24,
      ),
    ],
  );

  @override
  AppTokens copyWith({
    Color? background,
    Color? accent,
    Gradient? heroGradient,
    List<BoxShadow>? cardShadow,
  }) {
    return AppTokens(
      background: background ?? this.background,
      accent: accent ?? this.accent,
      heroGradient: heroGradient ?? this.heroGradient,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      background: Color.lerp(background, other.background, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      heroGradient: Gradient.lerp(heroGradient, other.heroGradient, t)!,
      cardShadow: BoxShadow.lerpList(cardShadow, other.cardShadow, t)!,
    );
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
