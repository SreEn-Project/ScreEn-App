import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_tokens.dart';

/// 정렬 · 필터처럼 항목 하나를 고르는 작은 팝업 메뉴. 흰 둥근 카드 + 그림자, 고른 항목에 체크.
/// 닫혀 있을 때는 [label] 알약(+ 아래 화살표)이 보인다. [active]면 강조 색.
class AppPopupMenu<T> extends StatelessWidget {
  const AppPopupMenu({
    super.key,
    required this.icon,
    required this.label,
    required this.values,
    required this.selected,
    required this.itemLabel,
    required this.onSelected,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final List<T> values;
  final T selected;
  final String Function(T) itemLabel;
  final ValueChanged<T> onSelected;

  /// 기본값이 아닌 조건이 걸려 있다 (필터가 켜진 상태 등).
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return PopupMenuButton<T>(
      tooltip: label,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 6),
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusInput),
        side: BorderSide(color: colors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final (i, v) in values.indexed) ...[
          if (i > 0)
            PopupMenuDivider(
              height: 1,
              color: colors.outlineVariant,
              indent: 12,
              endIndent: 12,
            ),
          PopupMenuItem<T>(
            value: v,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    itemLabel(v),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: v == selected ? colors.primary : null,
                      fontWeight: v == selected ? FontWeight.w700 : null,
                    ),
                  ),
                ),
                if (v == selected)
                  Icon(Symbols.check_rounded, size: 20, color: colors.primary),
              ],
            ),
          ),
        ],
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: active ? colors.primaryContainer : colors.surface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: active
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: 13,
                color: active
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
              ),
            ),
            Icon(
              Symbols.arrow_drop_down_rounded,
              size: 20,
              color: active
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
