import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_tokens.dart';

/// 검색 입력창: 흰 알약 + 옅은 그림자, 테두리 없음.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: colors.surface,
        shadows: context.tokens.cardShadow,
      ),
      child: TextField(
        onChanged: onChanged,
        style: theme.textTheme.bodyLarge,
        cursorColor: colors.primary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Symbols.search_rounded,
            color: colors.onSurfaceVariant,
          ),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

/// 가는 알약 진행 막대.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.value, this.height = 6});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: height,
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: colors.primaryContainer,
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

/// 값 조절 막대 (Material Slider 대신). 트랙은 가늘게, 손잡이는 흰 원 + primary 테두리.
class AppSlider extends StatelessWidget {
  const AppSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
  });

  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  double _snap(double v) {
    final clamped = v.clamp(min, max);
    if (divisions == null) return clamped;
    final step = (max - min) / divisions!;
    return min + ((clamped - min) / step).round() * step;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const knob = 22.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - knob;
        final t = (value - min) / (max - min);

        void update(Offset local) => onChanged(
          _snap(min + ((local.dx - knob / 2) / width) * (max - min)),
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => update(d.localPosition),
          onHorizontalDragUpdate: (d) => update(d.localPosition),
          child: SizedBox(
            height: 36,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: knob / 2),
                  child: AppProgressBar(value: t, height: 6),
                ),
                Positioned(
                  left: t * width,
                  child: Container(
                    width: knob,
                    height: knob,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface,
                      border: Border.all(color: colors.primary, width: 3),
                      boxShadow: context.tokens.cardShadow,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
