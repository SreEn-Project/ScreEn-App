import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/router.dart';
import '../../../core/ui/ui.dart';
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

    return AppPage(
      bottom: Column(
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
          AppButton(
            label: l10n.permissionContinue,
            onPressed: _allAllowed ? () => context.go(AppRoutes.home) : null,
          ),
        ],
      ),
      children: [
        const SizedBox(height: 40),
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
          onOpenSettings: () => setState(() => _overlayAllowed = true),
        ),
        const SizedBox(height: 16),
        _PermissionCard(
          icon: Symbols.notifications_rounded,
          title: l10n.permissionNotificationTitle,
          body: l10n.permissionNotificationBody,
          allowed: _notificationAllowed,
          onOpenSettings: () => setState(() => _notificationAllowed = true),
        ),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: icon, size: 44),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
              AppStatusPill(
                label: allowed ? l10n.commonAllowed : l10n.commonNotAllowed,
                active: allowed,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(body, style: theme.textTheme.bodySmall),
          if (!allowed) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton.secondary(
                label: l10n.commonOpenSettings,
                trailingIcon: Symbols.open_in_new_rounded,
                expand: false,
                height: 44,
                onPressed: onOpenSettings,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
