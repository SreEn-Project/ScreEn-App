import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import 'app_header.dart';

/// 화면 틀: 배경 + 가운데 제목 헤더 + 스크롤 본문 (Scaffold · AppBar 대신 화면에서 쓰는 것).
/// [header]가 없으면 [title]로 [AppHeader]를 만든다. 둘 다 없으면 헤더 없음.
/// [withBottomNav]이면 하단 탭바에 가리지 않도록 아래 여백을 더 둔다.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    this.title,
    this.header,
    this.headerTrailing,
    required this.children,
    this.withBottomNav = false,
    this.bottom,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppTokens.pagePadding,
    ),
  });

  final String? title;
  final Widget? header;
  final Widget? headerTrailing;
  final List<Widget> children;
  final bool withBottomNav;

  /// 스크롤 밖 하단 고정 영역 (예: 계속하기 버튼).
  final Widget? bottom;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final top =
        header ??
        (title != null
            ? AppHeader(title: title!, trailing: headerTrailing)
            : null);

    return Scaffold(
      body: SafeArea(
        bottom: !withBottomNav,
        child: Column(
          children: [
            ?top,
            Expanded(
              child: ListView(
                padding: padding.copyWith(
                  top: top == null ? 16 : 8,
                  bottom: withBottomNav ? AppTokens.bottomNavSpace + 16 : 32,
                ),
                children: children,
              ),
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.pagePadding,
                  8,
                  AppTokens.pagePadding,
                  24,
                ),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

/// 섹션 제목(작은 회색) + 카드 안 항목 묶음. 설정 화면 같은 목록에 쓴다.
class AppSection extends StatelessWidget {
  const AppSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 10),
            child: Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
