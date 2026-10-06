import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import 'icon_badge.dart';

/// 빈 목록 · 검색 결과 없음 · 불러오기 실패 같은 "보여 줄 것이 없는" 상태.
/// 연한 초록 원 아이콘 + 제목 + (선택) 회색 설명 + (선택) 아래 동작.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppTokens.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconBadge(icon: icon, size: 48),
          const SizedBox(height: AppTokens.space12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          if (message != null) ...[
            const SizedBox(height: AppTokens.space4),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppTokens.space16),
            action!,
          ],
        ],
      ),
    );
  }
}
