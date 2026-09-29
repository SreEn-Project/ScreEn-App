import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import 'pressable.dart';

class AppNavItem {
  const AppNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// 떠 있는 알약 모양 하단 탭바. 고른 탭은 아이콘 primary + 아래 짧은 막대.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        AppTokens.pagePadding,
        0,
        AppTokens.pagePadding,
        16,
      ),
      child: Container(
        height: 68,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          ),
          color: colors.surface,
          shadows: context.tokens.cardShadow,
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: Pressable(
                  onTap: () => onTap(i),
                  scale: 0.92,
                  semanticLabel: items[i].label,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[i].icon,
                        size: 26,
                        color: i == currentIndex
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: i == currentIndex ? 20 : 0,
                        height: 3,
                        decoration: ShapeDecoration(
                          shape: const StadiumBorder(),
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
