import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../service/domain/entities/service_status.dart';
import '../../../settings/domain/entities/translator_settings.dart';
import '../../../../core/l10n/labels.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../language/domain/entities/supported_language.dart';
import '../../../language/presentation/view_models/target_language_view_model.dart';
import '../../../models/presentation/view_models/language_models_view_model.dart';
import '../../../permission/presentation/view_models/permission_view_model.dart';
import '../../../settings/presentation/view_models/engine_view_model.dart';
import '../view_models/service_view_model.dart';

/// 홈 (S-03, FL-03).
/// 캡처 범위는 플로팅 버튼 메뉴에서 고르므로 홈에는 두지 않고, 언어 · 모델 설정을 둔다 (D-016).
/// 시작/중지는 네이티브 서비스와 연결됨(FL-03). 대상 언어(FL-04) · 모델 수(FL-05)도 실제 값.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // 설정 앱에서 권한을 끄고 돌아오는 경우까지 맞추려고 앞으로 올 때마다 다시 확인한다.
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
    final engine = ref.watch(engineViewModelProvider).value ?? EngineType.mlKit;
    final locale = Localizations.localeOf(context);
    final targetName = SupportedLanguage.byCode(
      ref.watch(targetLanguageViewModelProvider).value ?? 'ko',
    ).displayName(locale.languageCode);
    final models =
        ref.watch(languageModelsViewModelProvider).value ??
        const LanguageModelsState();
    final service =
        ref.watch(serviceViewModelProvider).value ?? ServiceStatus.stopped;
    final running = service == ServiceStatus.running;
    // 권한 확인 전(로딩)에는 막지 않는다. 확인 결과 빠진 권한이 있으면 시작을 막는다 (FL-02).
    final permissionsMissing =
        ref.watch(permissionViewModelProvider).value?.allGranted == false;

    return AppPage(
      withBottomNav: true,
      children: [
        const _Header(),
        const SizedBox(height: 24),
        _StatusCard(
          state: service,
          targetLanguage: targetName,
          engine: l10n.engineName(engine),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: switch (service) {
            ServiceStatus.running => l10n.homeStop,
            ServiceStatus.waitingConsent => l10n.homeStarting,
            ServiceStatus.stopped || ServiceStatus.error => l10n.homeStart,
          },
          height: AppTokens.largeButtonHeight + 4,
          leading: StatusDot(
            active: running,
            inactiveColor: Theme.of(context).colorScheme.onPrimary
                .withValues(alpha: 0.5),
          ),
          onPressed: permissionsMissing && !running
              ? null
              : () => ref.read(serviceViewModelProvider.notifier).toggle(),
        ),
        const SizedBox(height: 12),
        if (permissionsMissing && !running)
          Center(
            child: AppButton.text(
              label: l10n.homePermissionsNeeded,
              trailingIcon: Symbols.arrow_forward_rounded,
              onPressed: () => context.push(AppRoutes.permission),
            ),
          )
        else
          Text(
            l10n.homeAreaHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: 28),
        SectionTitle(l10n.homeSectionSetup),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _SetupTile(
                  icon: Symbols.translate_rounded,
                  label: l10n.homeTargetLanguage,
                  value: targetName,
                  onTap: () => context.push(AppRoutes.targetLanguage),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SetupTile(
                  icon: Symbols.download_rounded,
                  label: l10n.homeModels,
                  value: l10n.homeModelsReady(models.installed.length),
                  footer: models.downloading.isEmpty
                      ? null
                      : l10n.homeModelsDownloading(models.downloading.length),
                  busy: models.downloading.isNotEmpty,
                  onTap: () => context.go(AppRoutes.languages),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: EdgeInsets.zero,
          child: AppListTile(
            icon: engineIcon(engine),
            title: l10n.homeEngine,
            value: l10n.engineName(engine),
            onTap: () => context.go(AppRoutes.settings),
          ),
        ),
        const SizedBox(height: 28),
        SectionTitle(
          l10n.homeRecent,
          // 기록 화면은 FL-13(4단계).
          action: AppButton.text(label: l10n.homeRecentSeeAll, onPressed: null),
        ),
        const SizedBox(height: 12),
        const _RecentSection(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.homeGreeting, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              AccentTitle(
                text: l10n.homeHeadline,
                highlight: l10n.homeHeadlineHighlight,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        AppIconButton(
          icon: Symbols.notifications_rounded,
          tooltip: l10n.homeNotifications,
          onPressed: () {},
        ),
      ],
    );
  }
}

/// 그라데이션 상태 카드: 서비스 상태 + 언어 방향 + 엔진.
class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.state,
    required this.targetLanguage,
    required this.engine,
  });

  final ServiceStatus state;
  final String targetLanguage;
  final String engine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard(
      gradient: context.tokens.heroGradient,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppStatusPill(
            label: switch (state) {
              ServiceStatus.running => l10n.homeStatusOn,
              ServiceStatus.waitingConsent => l10n.homeStatusStarting,
              ServiceStatus.error => l10n.homeStatusError,
              ServiceStatus.stopped => l10n.homeStatusOff,
            },
            active: state == ServiceStatus.running,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Flexible(
                child: Text(
                  l10n.homeSourceAuto,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Symbols.arrow_forward_rounded,
                  color: colors.primary,
                ),
              ),
              Flexible(
                child: Text(
                  targetLanguage,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(switch (state) {
            ServiceStatus.running => l10n.homeServiceRunningHint,
            ServiceStatus.waitingConsent => l10n.homeServiceStartingHint,
            ServiceStatus.error => l10n.homeServiceErrorHint,
            ServiceStatus.stopped => l10n.homeServiceHint,
          }, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Symbols.memory_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                engine,
                style: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetupTile extends StatelessWidget {
  const _SetupTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.footer,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? footer;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, size: 40),
          const SizedBox(height: 14),
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge,
          ),
          if (busy) ...[
            const SizedBox(height: 12),
            const AppProgressBar(height: 5),
          ],
          if (footer != null) ...[
            const SizedBox(height: 6),
            Text(footer!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _RecentSection extends StatefulWidget {
  const _RecentSection();

  @override
  State<_RecentSection> createState() => _RecentSectionState();
}

class _RecentSectionState extends State<_RecentSection> {
  // 기록 조회는 FL-13(4단계). 지금은 필터 칩과 빈 상태만 보여 준다.
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final filters = [
      l10n.homeRecentFilterAll,
      l10n.homeRecentFilterToday,
      l10n.homeRecentFilterWeek,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (var i = 0; i < filters.length; i++)
              AppChip(
                label: filters[i],
                selected: _filter == i,
                onTap: () => setState(() => _filter = i),
              ),
          ],
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          child: Column(
            children: [
              const IconBadge(icon: Symbols.history_rounded, size: 48),
              const SizedBox(height: 12),
              Text(l10n.homeRecentEmpty, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
