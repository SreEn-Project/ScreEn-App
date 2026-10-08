import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_tokens.dart';
import 'app_icon_button.dart';

/// 가운데 제목 헤더 (AppBar 대신). 왼쪽 · 오른쪽에 동작을 하나씩 둘 수 있다.
/// [showBack]이 true이고 [leading]이 없으면 뒤로가기 버튼을 넣는다.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.showBack = true,
    this.large = false,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool showBack;

  /// 제목과 아이콘 버튼을 키운다 (목록처럼 헤더가 화면의 중심인 곳).
  final bool large;

  /// 제목 양옆으로 비워 두는 폭 (아이콘 버튼 하나가 들어가는 크기).
  static const double _sideSlot = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = GoRouter.maybeOf(context)?.canPop() ?? false;
    final start =
        leading ??
        (showBack && canPop
            ? AppIconButton(
                icon: Symbols.arrow_back_rounded,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                plain: true,
                size: large ? 52 : 44,
                onPressed: () => context.pop(),
              )
            : null);

    return SizedBox(
      height: AppTokens.headerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        // 제목은 항상 가운데. 양옆 동작은 내용 너비만큼 자라서 글자 버튼도 잘리지 않는다.
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: large ? _sideSlot + 8 : _sideSlot,
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: large
                    ? theme.textTheme.headlineSmall
                    : theme.textTheme.titleLarge,
              ),
            ),
            if (start != null)
              Align(alignment: Alignment.centerLeft, child: start),
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing),
          ],
        ),
      ),
    );
  }
}
