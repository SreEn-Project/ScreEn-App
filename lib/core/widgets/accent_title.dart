import 'package:flutter/material.dart';

/// 굵은 제목에서 한 단어만 primary 색으로 강조한다 (docs/design.md).
/// [text] 안의 [highlight]가 처음 나오는 부분을 강조한다. 없으면 그대로 표시.
class AccentTitle extends StatelessWidget {
  const AccentTitle({
    super.key,
    required this.text,
    required this.highlight,
    this.style,
  });

  final String text;
  final String highlight;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.headlineSmall;
    final index = highlight.isEmpty ? -1 : text.indexOf(highlight);

    if (index < 0) return Text(text, style: base);

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: highlight,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          TextSpan(text: text.substring(index + highlight.length)),
        ],
      ),
    );
  }
}
