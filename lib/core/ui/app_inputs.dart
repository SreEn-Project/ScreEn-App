import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// 가는 알약 진행 막대. [value]가 null이면 얼마나 걸릴지 모르는 진행 중 표시(좌우로 오가는 막대)다.
class AppProgressBar extends StatefulWidget {
  const AppProgressBar({super.key, this.value, this.height = 6});

  final double? value;
  final double height;

  @override
  State<AppProgressBar> createState() => _AppProgressBarState();
}

class _AppProgressBarState extends State<AppProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.value == null) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(AppProgressBar old) {
    super.didUpdateWidget(old);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const indeterminateWidth = 0.3;

    Widget fill(double factor, double align) => Align(
      alignment: Alignment(align, 0),
      child: FractionallySizedBox(
        widthFactor: factor,
        child: Container(
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: colors.primary,
          ),
        ),
      ),
    );

    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: colors.primaryContainer,
      ),
      child: widget.value == null
          ? AnimatedBuilder(
              animation: _controller,
              builder: (_, _) => fill(
                indeterminateWidth,
                -1 + 2 * Curves.easeInOut.transform(_controller.value),
              ),
            )
          : fill(widget.value!.clamp(0.0, 1.0), -1),
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

/// 한 줄 입력창: 흰 둥근 사각형 + 옅은 그림자. [obscure]면 입력을 가린다 (API 키 등).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool autofocus;
  final TextAlign textAlign;

  /// 여러 줄 입력이면 1보다 크게 (예문 등).
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: colors.surface,
        shadows: context.tokens.cardShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscure,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        autofocus: autofocus,
        textAlign: textAlign,
        minLines: 1,
        maxLines: maxLines,
        autocorrect: false,
        enableSuggestions: false,
        style: theme.textTheme.bodyLarge,
        cursorColor: colors.primary,
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTokens.rowPaddingH,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
