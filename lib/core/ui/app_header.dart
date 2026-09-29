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
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool showBack;

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
                size: 44,
                onPressed: () => context.pop(),
              )
            : null);

    return SizedBox(
      height: AppTokens.headerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            SizedBox(width: 56, child: Center(child: start)),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge,
              ),
            ),
            SizedBox(width: 56, child: Center(child: trailing)),
          ],
        ),
      ),
    );
  }
}
