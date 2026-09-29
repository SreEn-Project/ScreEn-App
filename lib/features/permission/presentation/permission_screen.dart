import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/accent_title.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../l10n/app_localizations.dart';

/// 권한 안내 (S-02, FL-02).
/// UI 퍼블리싱 단계: "설정 열기"를 누르면 허용된 것처럼 바뀐다.
/// 실제 권한 확인 · 시스템 설정 이동은 FL-02 기능 연결 때 ViewModel로 옮긴다.
class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _overlayAllowed = false;
  bool _notificationAllowed = false;

  bool get _allAllowed => _overlayAllowed && _notificationAllowed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.pagePadding,
                  56,
                  AppTokens.pagePadding,
                  24,
                ),
                children: [
                  AccentTitle(
                    text: l10n.permissionTitle,
                    highlight: l10n.permissionHighlight,
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.permissionBody,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _PermissionCard(
                    icon: Symbols.layers_rounded,
                    title: l10n.permissionOverlayTitle,
                    body: l10n.permissionOverlayBody,
                    allowed: _overlayAllowed,
                    onOpenSettings: () =>
                        setState(() => _overlayAllowed = true),
                  ),
                  const SizedBox(height: 16),
                  _PermissionCard(
                    icon: Symbols.notifications_rounded,
                    title: l10n.permissionNotificationTitle,
                    body: l10n.permissionNotificationBody,
                    allowed: _notificationAllowed,
                    onOpenSettings: () =>
                        setState(() => _notificationAllowed = true),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.pagePadding,
                8,
                AppTokens.pagePadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_allAllowed) ...[
                    Text(
                      l10n.permissionPending,
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    onPressed: _allAllowed
                        ? () => context.go(AppRoutes.home)
                        : null,
                    child: Text(l10n.permissionContinue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.allowed,
    required this.onOpenSettings,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool allowed;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: icon, size: 44),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
              _StatusPill(allowed: allowed),
            ],
          ),
          const SizedBox(height: 12),
          Text(body, style: theme.textTheme.bodySmall),
          if (!allowed) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: onOpenSettings,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                icon: const Icon(Symbols.open_in_new_rounded, size: 18),
                label: Text(l10n.commonOpenSettings),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.allowed});

  final bool allowed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: allowed ? colors.primaryContainer : colors.surfaceContainerHigh,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: allowed ? context.tokens.accent : colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            allowed ? l10n.commonAllowed : l10n.commonNotAllowed,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: allowed
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
