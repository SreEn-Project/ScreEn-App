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
import '../../../history/domain/entities/history_entry.dart';
import '../../../history/presentation/view_models/history_view_model.dart';
import '../../../history/presentation/widgets/history_card.dart';
import '../view_models/service_view_model.dart';
import '../../../vocabulary/presentation/view_models/wordbooks_view_model.dart';
import '../../../vocabulary/presentation/widgets/word_of_the_day_card.dart';

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

    final books = ref.watch(wordbooksViewModelProvider).value;
    final bookCount = books?.length ?? 0;
    final wordCount = books?.fold<int>(0, (sum, b) => sum + b.wordCount) ?? 0;

    return AppPage(
      withBottomNav: true,
      children: [
        const _Header(),
        const SizedBox(height: AppTokens.space24),
        // 번역 상태와 시작/중지는 한 덩어리: 화면에서 가장 먼저 읽히는 곳.
        _StatusCard(
          state: service,
          targetLanguage: targetName,
          engine: l10n.engineName(engine),
          action: AppButton(
            label: switch (service) {
              ServiceStatus.running => l10n.homeStop,
              ServiceStatus.waitingConsent => l10n.homeStarting,
              ServiceStatus.stopped || ServiceStatus.error => l10n.homeStart,
            },
            height: AppTokens.largeButtonHeight,
            leading: StatusDot(
              active: running,
              inactiveColor: Theme.of(context).colorScheme.onPrimary
                  .withValues(alpha: 0.5),
            ),
            onPressed: permissionsMissing && !running
                ? null
                : () => ref.read(serviceViewModelProvider.notifier).toggle(),
          ),
          hint: permissionsMissing && !running
              ? AppButton.text(
                  label: l10n.homePermissionsNeeded,
                  trailingIcon: Symbols.arrow_forward_rounded,
                  onPressed: () => context.push(AppRoutes.permission),
                )
              : Text(
                  l10n.homeAreaHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
        ),
        const SizedBox(height: AppTokens.sectionGap),
        SectionTitle(
          l10n.homeSectionStudy,
          action: AppButton.text(
            label: l10n.vocabTitle,
            onPressed: () => context.go(AppRoutes.vocabulary),
          ),
        ),
        const SizedBox(height: AppTokens.space12),
        _StudyCard(
          summary: bookCount == 0
              ? l10n.homeStudyEmpty
              : l10n.homeStudySummary(bookCount, wordCount),
          canStart: wordCount > 0,
          onStart: () => context.push(AppRoutes.learning),
        ),
        const SizedBox(height: AppTokens.space12),
        const WordOfTheDayCard(),
        const SizedBox(height: AppTokens.space12),
        SectionTitle(l10n.homeSectionSetup),
        const SizedBox(height: AppTokens.space12),
        AppCard(
          padding: const EdgeInsets.symmetric(
            vertical: AppTokens.cardListPaddingV,
          ),
          child: Column(
            children: [
              AppListTile(
                title: l10n.homeTargetLanguage,
                value: targetName,
                onTap: () => context.push(AppRoutes.targetLanguage),
              ),
              const AppDivider(),
              AppListTile(
                title: l10n.homeModels,
                value: l10n.homeModelsReady(models.installed.length),
                subtitle: models.downloading.isEmpty
                    ? null
                    : l10n.homeModelsDownloading(models.downloading.length),
                onTap: () => context.push(AppRoutes.languages),
              ),
              const AppDivider(),
              AppListTile(
                title: l10n.homeEngine,
                value: l10n.engineName(engine),
                onTap: () => context.go(AppRoutes.settings),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.sectionGap),
        SectionTitle(
          l10n.homeRecent,
          action: AppButton.text(
            label: l10n.homeRecentSeeAll,
            onPressed: () => context.go(AppRoutes.history),
          ),
        ),
        const SizedBox(height: AppTokens.space12),
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

/// 번역 상태 카드(흰 바탕): 서비스 상태 + 언어 방향 + 엔진 + 시작/중지 버튼.
class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.state,
    required this.targetLanguage,
    required this.engine,
    required this.action,
    required this.hint,
  });

  final ServiceStatus state;
  final String targetLanguage;
  final String engine;
  final Widget action;
  final Widget hint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppTokens.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
              const Spacer(),
              Icon(Symbols.memory_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                engine,
                style: theme.textTheme.labelLarge?.copyWith(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space16),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space12,
                ),
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
          const SizedBox(height: AppTokens.space8),
          Text(switch (state) {
            ServiceStatus.running => l10n.homeServiceRunningHint,
            ServiceStatus.waitingConsent => l10n.homeServiceStartingHint,
            ServiceStatus.error => l10n.homeServiceErrorHint,
            ServiceStatus.stopped => l10n.homeServiceHint,
          }, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppTokens.space16),
          action,
          const SizedBox(height: AppTokens.space12),
          Center(child: hint),
        ],
      ),
    );
  }
}

/// 학습 진입 카드: 단어장 요약 + 학습 시작.
class _StudyCard extends StatelessWidget {
  const _StudyCard({
    required this.summary,
    required this.canStart,
    required this.onStart,
  });

  final String summary;
  final bool canStart;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppTokens.pagePadding),
      child: Row(
        children: [
          Expanded(child: Text(summary, style: theme.textTheme.titleMedium)),
          const SizedBox(width: AppTokens.space12),
          AppButton.secondary(
            label: l10n.homeStudyStart,
            expand: false,
            height: 44,
            onPressed: canStart ? onStart : null,
          ),
        ],
      ),
    );
  }
}

class _RecentSection extends ConsumerStatefulWidget {
  const _RecentSection();

  @override
  ConsumerState<_RecentSection> createState() => _RecentSectionState();
}

class _RecentSectionState extends ConsumerState<_RecentSection>
    with WidgetsBindingObserver {
  HistoryPeriod _period = HistoryPeriod.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 번역은 다른 앱 위에서 이루어지므로, 앱으로 돌아올 때 새 기록을 다시 읽는다.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(recentHistoryProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final periods = {
      HistoryPeriod.all: l10n.homeRecentFilterAll,
      HistoryPeriod.today: l10n.homeRecentFilterToday,
      HistoryPeriod.week: l10n.homeRecentFilterWeek,
    };
    final entries =
        ref.watch(recentHistoryProvider(_period)).value ??
        const <HistoryEntry>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final period in HistoryPeriod.values)
              AppChip(
                label: periods[period]!,
                selected: _period == period,
                onTap: () => setState(() => _period = period),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (entries.isEmpty)
          AppCard(
            padding: EdgeInsets.zero,
            child: Center(
              child: AppEmptyState(
                icon: Symbols.history_rounded,
                title: l10n.homeRecentEmpty,
              ),
            ),
          )
        else
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
            child: Column(
              children: [
                for (final (i, entry) in entries.indexed) ...[
                  if (i > 0) const AppDivider(indent: 0),
                  HistoryCard(entry: entry, flat: true),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
