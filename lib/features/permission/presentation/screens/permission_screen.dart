import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/router.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_permissions.dart';
import '../view_models/permission_view_model.dart';

/// 권한 안내 (S-02, FL-02). 다른 앱 위에 표시 · 알림 권한을 확인하고 요청한다.
/// 시스템 설정에서 앱으로 돌아오면 다시 확인한다. 둘 다 허용해야 계속할 수 있다.
class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(permissionViewModelProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final permissions =
        ref.watch(permissionViewModelProvider).value ??
        const AppPermissions(overlay: false, notification: false);
    final viewModel = ref.read(permissionViewModelProvider.notifier);
    final allAllowed = permissions.allGranted;

    return AppPage(
      bottom: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!allAllowed) ...[
            Text(
              l10n.permissionPending,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
          AppButton(
            label: l10n.permissionContinue,
            onPressed: allAllowed ? () => context.go(AppRoutes.home) : null,
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
          allowed: permissions.overlay,
          actionLabel: l10n.commonOpenSettings,
          onAction: viewModel.requestOverlay,
        ),
        const SizedBox(height: 16),
        _PermissionCard(
          icon: Symbols.notifications_rounded,
          title: l10n.permissionNotificationTitle,
          body: l10n.permissionNotificationBody,
          allowed: permissions.notification,
          // 두 번 거부해 팝업이 막혔으면 앱 설정으로 보낸다.
          actionLabel: permissions.notificationBlocked
              ? l10n.commonOpenSettings
              : l10n.permissionAllow,
          onAction: viewModel.requestNotification,
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
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool allowed;
  final String actionLabel;
  final VoidCallback onAction;

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
                label: actionLabel,
                trailingIcon: Symbols.open_in_new_rounded,
                expand: false,
                height: 44,
                onPressed: onAction,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
