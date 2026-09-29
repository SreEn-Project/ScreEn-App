import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import 'pressable.dart';

enum AppButtonVariant {
  /// primary 알약 + 아래로 번지는 빛. 화면의 주요 동작 하나에만.
  primary,

  /// 흰 알약 + 옅은 그림자, 글자 primary.
  secondary,

  /// 배경 없는 글자 버튼.
  text,
}

/// 앱 버튼 (D-015). Material 버튼 대신 쓴다.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leading,
    this.trailingIcon,
    this.expand = true,
    this.height = AppTokens.largeButtonHeight,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.trailingIcon,
    this.expand = true,
    this.height = AppTokens.largeButtonHeight,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.trailingIcon,
    this.expand = false,
    this.height = 40,
  }) : variant = AppButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  /// 글자 앞에 붙는 위젯 (아이콘, 상태 점 등).
  final Widget? leading;
  final IconData? trailingIcon;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tokens = context.tokens;
    final enabled = onPressed != null;

    final (
      Color? background,
      Color foreground,
      List<BoxShadow>? shadow,
    ) = switch (variant) {
      AppButtonVariant.primary => (
        enabled ? colors.primary : colors.surfaceContainerHighest,
        enabled ? colors.onPrimary : colors.onSurfaceVariant,
        enabled ? tokens.glowShadow : null,
      ),
      AppButtonVariant.secondary => (
        colors.surface,
        enabled ? colors.primary : colors.onSurfaceVariant,
        tokens.cardShadow,
      ),
      AppButtonVariant.text => (
        null,
        enabled ? colors.primary : colors.onSurfaceVariant,
        null,
      ),
    };

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 10)],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: foreground,
              fontSize: variant == AppButtonVariant.text ? 15 : 16,
            ),
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: 20, color: foreground),
        ],
      ],
    );

    return Pressable(
      onTap: onPressed,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        padding: EdgeInsets.symmetric(
          horizontal: variant == AppButtonVariant.text ? 12 : 28,
        ),
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: background,
          shadows: shadow,
        ),
        child: content,
      ),
    );
  }
}
