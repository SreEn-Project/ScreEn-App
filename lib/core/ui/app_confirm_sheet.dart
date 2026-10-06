import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import 'app_button.dart';

/// 되돌릴 수 없는 동작 전에 묻는 확인 시트 (대화상자 대신 하단 시트).
/// 제목 + (선택) 설명 + primary 확인 버튼 + secondary 취소 버튼. 확인하면 true.
Future<bool> showAppConfirm(
  BuildContext context, {
  required String title,
  String? message,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.pagePadding,
            0,
            AppTokens.pagePadding,
            AppTokens.sectionGap,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              if (message != null) ...[
                const SizedBox(height: AppTokens.space8),
                Text(message, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: AppTokens.sectionGap),
              AppButton(
                label: confirmLabel,
                expand: true,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
              const SizedBox(height: AppTokens.space8),
              AppButton.secondary(
                label: cancelLabel,
                expand: true,
                onPressed: () => Navigator.of(sheetContext).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );
  return confirmed ?? false;
}
