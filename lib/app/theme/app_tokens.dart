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
    required this.floatShadow,
    required this.glowShadow,
  });

  /// 화면 배경 (카드보다 한 단계 어두운 회녹색).
  final Color background;

  /// 상태 점 등 아주 작은 강조에만 쓴다.
  final Color accent;

  /// 홈 상단 상태 카드 전용.
  final Gradient heroGradient;

  /// 카드 · 흰 버튼 · 탭바의 옅고 넓은 그림자 (primary로 물듦).
  final List<BoxShadow> cardShadow;

  /// 떠 있는 요소(팝업 · 탭바 · 토스트)의 그림자. 카드보다 한 단계 진하다.
  final List<BoxShadow> floatShadow;

  /// primary 버튼 아래 번지는 빛.
  final List<BoxShadow> glowShadow;

  /// 모서리 스케일: XS 8(작은 배지) · S 12(입력 · 작은 버튼) · M 16(보조 버튼 · 작은 패널)
  /// · L 20(주요 패널) · XL 24(대표 패널). 알약은 칩 · 상태 배지 · 큰 시작 버튼에만.
  static const double radiusXs = 8;
  static const double radiusS = 12;
  static const double radiusM = 16;
  static const double radiusL = 20;
  static const double radiusCard = 24;
  static const double radiusSheet = 28;
  static const double radiusInput = 16;
  static const double pagePadding = 20;

  /// 간격 토큰 (8 배수 기준, 4 보조). margin · gap · padding은 이 값만 쓴다.
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;

  /// 카드 안 목록 한 줄의 좌우 · 위아래 패딩, 카드 위아래 패딩, 구분선 들여쓰기.
  static const double rowPaddingH = pagePadding;
  static const double rowPaddingV = 14;
  static const double cardListPaddingV = 6;

  /// 섹션 사이 간격 · 섹션 제목과 카드 사이 간격 · 제목 왼쪽 들여쓰기.
  static const double sectionGap = space24;
  static const double sectionTitleGap = 10;
  static const double sectionTitleIndent = 6;
  static const double largeButtonHeight = 56;
  static const double headerHeight = 56;

  /// 하단 탭바 높이 + 아래 여백. 스크롤 화면 아래쪽에 이만큼 비워 둔다.
  static const double bottomNavSpace = 104;

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
    floatShadow: [
      BoxShadow(
        color: AppColors.lightFloatShadow,
        offset: Offset(0, 8),
        blurRadius: 24,
      ),
    ],
    glowShadow: [
      BoxShadow(
        color: AppColors.lightGlow,
        offset: Offset(0, 10),
        blurRadius: 24,
        spreadRadius: -4,
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
    floatShadow: [
      BoxShadow(
        color: AppColors.darkFloatShadow,
        offset: Offset(0, 8),
        blurRadius: 24,
      ),
    ],
    glowShadow: [
      BoxShadow(
        color: AppColors.darkGlow,
        offset: Offset(0, 10),
        blurRadius: 24,
        spreadRadius: -4,
      ),
    ],
  );

  @override
  AppTokens copyWith({
    Color? background,
    Color? accent,
    Gradient? heroGradient,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? floatShadow,
    List<BoxShadow>? glowShadow,
  }) {
    return AppTokens(
      background: background ?? this.background,
      accent: accent ?? this.accent,
      heroGradient: heroGradient ?? this.heroGradient,
      cardShadow: cardShadow ?? this.cardShadow,
      floatShadow: floatShadow ?? this.floatShadow,
      glowShadow: glowShadow ?? this.glowShadow,
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
      floatShadow: BoxShadow.lerpList(floatShadow, other.floatShadow, t)!,
      glowShadow: BoxShadow.lerpList(glowShadow, other.glowShadow, t)!,
    );
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}

/// 헤더 · 하단 탭바와 본문을 나누는 선 색 (구분선보다 한 단계 진하다).
Color barLineColor(ColorScheme colors) =>
    Color.alphaBlend(colors.onSurface.withValues(alpha: 0.14), colors.surface);
