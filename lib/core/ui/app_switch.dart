import 'package:flutter/material.dart';

import 'pressable.dart';

/// 켜고 끄는 스위치 (Material Switch 대신). 켜짐: primary 트랙, 꺼짐: 회색 트랙.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const width = 48.0;
    const height = 28.0;
    const knob = 22.0;

    return Semantics(
      toggled: value,
      child: Pressable(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        scale: 0.95,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width,
          height: height,
          padding: const EdgeInsets.all(3),
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: value ? colors.primary : colors.surfaceContainerHighest,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: knob,
              height: knob,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? colors.onPrimary : colors.surface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
