import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app/theme/app_tokens.dart';

/// 메시지 성격. 색은 토큰에서 정한다: info = 회색 배경 · success = primaryContainer · error = error 10%.
enum AppMessageKind { info, success, error }

extension AppMessageKindStyle on AppMessageKind {
  IconData get icon => switch (this) {
    AppMessageKind.info => Symbols.info_rounded,
    AppMessageKind.success => Symbols.check_circle_rounded,
    AppMessageKind.error => Symbols.error_rounded,
  };

  Color background(ColorScheme colors) => switch (this) {
    AppMessageKind.info => colors.surfaceContainerHigh,
    AppMessageKind.success => colors.primaryContainer,
    AppMessageKind.error => colors.error.withValues(alpha: 0.1),
  };

  Color foreground(ColorScheme colors) => switch (this) {
    AppMessageKind.info => colors.onSurfaceVariant,
    AppMessageKind.success => colors.onPrimaryContainer,
    AppMessageKind.error => colors.error,
  };
}

/// 화면 안에 붙는 안내 배너 (테스트 결과 · 입력 오류 · 한도 안내 등).
/// 둥근 사각형 + 아이콘 + 글자. 테두리 없음.
class AppNotice extends StatelessWidget {
  const AppNotice(this.message, {super.key, this.kind = AppMessageKind.info});

  const AppNotice.error(this.message, {super.key})
    : kind = AppMessageKind.error;

  const AppNotice.success(this.message, {super.key})
    : kind = AppMessageKind.success;

  final String message;
  final AppMessageKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = kind.foreground(colors);

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTokens.space12),
        decoration: BoxDecoration(
          color: kind.background(colors),
          borderRadius: BorderRadius.circular(AppTokens.space16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(kind.icon, size: 18, color: foreground),
            ),
            const SizedBox(width: AppTokens.space8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: kind == AppMessageKind.info
                      ? colors.onSurface
                      : foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
