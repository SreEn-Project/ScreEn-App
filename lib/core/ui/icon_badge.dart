import 'package:flutter/material.dart';

/// 원형 배경 위 선 아이콘. 기본 배경은 primaryContainer (docs/design.md).
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, this.color, this.size = 36});

  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? colors.primaryContainer,
      ),
      child: Icon(icon, size: size * 0.55, color: colors.onPrimaryContainer),
    );
  }
}
