import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'pressable.dart';

/// 여러 값 중 하나를 고르는 알약 묶음 (ChoiceChip · SegmentedButton 대신).
/// 회색 트랙 안에서 고른 칸만 흰 알약으로 떠오른다.
class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
    this.enabled = true,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  /// false면 흐리게 보이고 누를 수 없다 (선택값은 그대로 보인다).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: colors.surfaceContainer,
        ),
        child: Row(
          children: [
            for (final value in values)
              Expanded(
                child: Pressable(
                  onTap: enabled ? () => onChanged(value) : null,
                  scale: 0.97,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 40,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      shape: const StadiumBorder(),
                      color: value == selected ? colors.surface : null,
                      shadows: value == selected
                          ? [
                              BoxShadow(
                                color: colors.shadow.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      label(value),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 14,
                        color: value == selected
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 필터 칩 하나. 선택: primaryContainer, 기본: 흰 배경.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Pressable(
      onTap: onTap,
      scale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: selected ? colors.primary : colors.surface,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 14,
            color: selected ? colors.onPrimary : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// "+ 발음" 같은 작은 추가 칩. 눌러서 선택 항목을 펼칠 때 쓴다.
class AppAddChip extends StatelessWidget {
  const AppAddChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Pressable(
      onTap: onTap,
      scale: 0.95,
      semanticLabel: label,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 14, 6),
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: colors.surfaceContainerHigh,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.add_rounded, size: 16, color: colors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: 13,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
