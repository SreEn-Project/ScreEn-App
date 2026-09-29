import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import 'pressable.dart';

/// 원형 아이콘 버튼.
/// [filled] false(기본): 흰 원 + 옅은 그림자. true: primary 원 + 빛 (재생 버튼 같은 강조용).
/// [plain] true: 배경 없이 아이콘만 (헤더의 닫기 · 뒤로가기).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.filled = false,
    this.plain = false,
    this.size = 48,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool filled;
  final bool plain;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tokens = context.tokens;

    final Color? background = plain
        ? null
        : filled
        ? colors.primary
        : colors.surface;
    final Color foreground = filled
        ? colors.onPrimary
        : plain
        ? colors.onSurface
        : colors.primary;

    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onPressed,
        scale: 0.92,
        semanticLabel: tooltip,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: background,
            boxShadow: plain
                ? null
                : filled
                ? tokens.glowShadow
                : tokens.cardShadow,
          ),
          child: Icon(icon, size: size * 0.46, color: foreground),
        ),
      ),
    );
  }
}
