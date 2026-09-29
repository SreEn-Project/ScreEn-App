import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';

/// 작은 배지 (secondaryContainer). 예: "대상 언어 전용".
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: colors.secondaryContainer,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colors.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// 상태 점 + 글자 알약. [active]면 accent 점 + primaryContainer 배경.
class AppStatusPill extends StatelessWidget {
  const AppStatusPill({super.key, required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: active ? colors.primaryContainer : colors.surfaceContainerHigh,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusDot(active: active, size: 6),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 켜짐 표시 점. 켜짐: accent, 꺼짐: [inactiveColor] 또는 onSurfaceVariant.
class StatusDot extends StatelessWidget {
  const StatusDot({
    super.key,
    required this.active,
    this.size = 10,
    this.inactiveColor,
  });

  final bool active;
  final double size;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? context.tokens.accent
            : inactiveColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
