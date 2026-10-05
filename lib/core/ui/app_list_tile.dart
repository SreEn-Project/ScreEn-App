import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_tokens.dart';
import 'icon_badge.dart';
import 'pressable.dart';

/// 목록 한 줄: 아이콘 원 + 제목 + 회색 설명 + 오른쪽 요소 (ListTile 대신).
/// [trailing]이 없고 [onTap]이 있으면 오른쪽에 › 를 붙인다.
/// [enabled]가 false면 흐리게 보이고 누를 수 없다.
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppTokens.rowPaddingH,
      vertical: AppTokens.rowPaddingV,
    ),
  });

  final String title;
  final IconData? icon;
  final String? subtitle;

  /// 오른쪽에 primary 색으로 보이는 현재 값 (예: "한국어").
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final end =
        trailing ??
        (onTap != null
            ? Icon(
                Symbols.chevron_right_rounded,
                color: colors.onSurfaceVariant,
                size: 22,
              )
            : null);

    final row = Padding(
      padding: padding,
      child: Row(
        children: [
          if (icon != null) ...[
            IconBadge(icon: icon!, size: 40),
            const SizedBox(width: AppTokens.space12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: AppTokens.space4),
                  Text(subtitle!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: AppTokens.space8),
            Text(
              value!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.primary,
              ),
            ),
          ],
          if (end != null) ...[const SizedBox(width: AppTokens.space8), end],
        ],
      ),
    );

    final body = enabled ? row : Opacity(opacity: 0.45, child: row);
    if (onTap == null || !enabled) return body;
    return Pressable(onTap: onTap, scale: 0.99, child: body);
  }
}

/// 카드 안 항목 사이 가는 구분선.
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.indent = AppTokens.rowPaddingH});

  final double indent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: indent),
      color: Theme.of(context).colorScheme.outline,
    );
  }
}
