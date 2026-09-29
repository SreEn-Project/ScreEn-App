import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../core/ui/ui.dart';
import '../l10n/app_localizations.dart';

/// 하단 탭(홈 · 언어 · 설정) 틀. 탭바는 본문 위에 떠 있다.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        Positioned.fill(child: shell),
        Align(
          alignment: Alignment.bottomCenter,
          child: AppBottomNav(
            currentIndex: shell.currentIndex,
            onTap: (index) => shell.goBranch(
              index,
              initialLocation: index == shell.currentIndex,
            ),
            items: [
              AppNavItem(icon: Symbols.home_rounded, label: l10n.navHome),
              AppNavItem(
                icon: Symbols.translate_rounded,
                label: l10n.navLanguages,
              ),
              AppNavItem(
                icon: Symbols.settings_rounded,
                label: l10n.navSettings,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
