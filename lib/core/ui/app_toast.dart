import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import 'app_notice.dart';

/// 잠깐 떴다 사라지는 한 줄 메시지 (복사했어요 · 저장했어요 · 실패했어요).
/// 흰 알약 + 그림자 + 성격 아이콘. SnackBar는 쓰지 않는다.
/// 한 번에 하나만 뜨고, 새로 띄우면 이전 것을 바꾼다.
class AppToast {
  AppToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static const Duration _visible = Duration(milliseconds: 2400);

  /// 하단 탭바 위로 띄운다.
  static void show(
    BuildContext context,
    String message, {
    AppMessageKind kind = AppMessageKind.success,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    dismiss();
    final entry = OverlayEntry(
      builder: (_) => _ToastView(message: message, kind: kind),
    );
    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(_visible, dismiss);
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }
}

class _ToastView extends StatelessWidget {
  const _ToastView({required this.message, required this.kind});

  final String message;
  final AppMessageKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final media = MediaQuery.of(context);
    final iconColor = kind == AppMessageKind.error
        ? colors.error
        : colors.primary;

    return Positioned(
      left: AppTokens.pagePadding,
      right: AppTokens.pagePadding,
      bottom:
          media.viewInsets.bottom +
          media.padding.bottom +
          AppTokens.bottomNavSpace,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 12),
              child: child,
            ),
          ),
          child: Align(
            child: Semantics(
              liveRegion: true,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.space16,
                    vertical: AppTokens.space12,
                  ),
                  decoration: ShapeDecoration(
                    shape: const StadiumBorder(),
                    color: colors.surface,
                    shadows: context.tokens.cardShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(kind.icon, size: 20, color: iconColor),
                      const SizedBox(width: AppTokens.space8),
                      Flexible(
                        child: Text(
                          message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
