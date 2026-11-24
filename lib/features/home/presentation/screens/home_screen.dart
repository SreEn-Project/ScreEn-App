import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
import '../../../study_log/domain/entities/study_streak.dart';
import '../../../study_log/presentation/view_models/study_streak_view_model.dart';
import '../../../vocabulary/domain/entities/vocabulary.dart';
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
    // 학습하면 단어장 통계가 바뀌므로, 그때 연속 일수도 다시 읽는다.
    ref.listen(
      wordbooksViewModelProvider,
      (_, _) => ref.read(studyStreakViewModelProvider.notifier).refresh(),
    );
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
    final memorizedCount =
        books?.fold<int>(0, (sum, b) => sum + b.memorizedCount) ?? 0;

    return AppPage(
      withBottomNav: true,
      children: [
        const _Header(),
        const _SectionDivider(),
        // 학습 앱: 학습 기록이 맨 위. 번역 시작은 그 아래 카드에서.
        _StudyCard(
          streak:
              ref.watch(studyStreakViewModelProvider).value ??
              StudyStreak.empty,
          words: wordCount,
          memorized: memorizedCount,
          ranking:
              ([...?books]..sort(
                    (a, b) => b.memorizedCount.compareTo(a.memorizedCount),
                  ))
                  .take(3)
                  .toList(),
          empty: bookCount == 0,
          canStart: wordCount > 0,
          onOpen: () => context.go(AppRoutes.vocabulary),
          onStart: () => context.push(AppRoutes.learning),
        ),
        const _SectionDivider(),
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
        const _SectionDivider(),
        const WordOfTheDayCard(),
        const _SectionDivider(),
        SectionTitle(l10n.homeSectionSetup),
        const SizedBox(height: AppTokens.space8),
        AppCard.elevated(
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
        const _SectionDivider(),
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

/// 섹션 사이 가는 선 + 넉넉한 여백. 카드 대신 구역을 이 선으로 나눈다.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppTokens.space24),
      child: AppDivider(indent: 0),
    );
  }
}

/// 번역 구역: 서비스 상태 + 큰 언어 방향 + 시작/중지 버튼 (카드 없이).
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

    return Column(
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
        Text(
          l10n.homeSourceAuto,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        Row(
          children: [
            Icon(Symbols.arrow_forward_rounded, color: colors.primary),
            const SizedBox(width: AppTokens.space8),
            Flexible(
              child: Text(
                targetLanguage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineLarge?.copyWith(
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
        const SizedBox(height: AppTokens.space24),
        action,
        const SizedBox(height: AppTokens.space12),
        Center(child: hint),
      ],
    );
  }
}

/// 학습 기록 구역(홈 맨 위): 연속 일수 · 외운 단어 · 내 단어장 순위 + 학습 시작 (카드 없이).
/// 순위는 다른 사람과의 비교가 아니라(서버 없음, D-072) 내 단어장끼리 외운 단어 수 비교.
class _StudyCard extends StatelessWidget {
  const _StudyCard({
    required this.streak,
    required this.words,
    required this.memorized,
    required this.ranking,
    required this.empty,
    required this.canStart,
    required this.onOpen,
    required this.onStart,
  });

  final StudyStreak streak;
  final int words;
  final int memorized;
  final List<Wordbook> ranking;
  final bool empty;
  final bool canStart;
  final VoidCallback onOpen;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final today = DateTime.now();

    final streakHint = streak.studiedToday
        ? l10n.homeStreakDone
        : streak.current > 0
        ? l10n.homeStreakKeep
        : l10n.homeStreakStart;

    // 달력 칸: 요일 · 날짜. 학습한 날은 연한 초록 칸, 오늘은 테두리 + 불꽃.
    Widget dayCell(int back, double width) {
      final date = DateTime(today.year, today.month, today.day - back);
      final done = streak.studiedBack(back);
      final isToday = back == 0;
      final label = DateFormat.E(locale).format(date);
      final fg = done ? colors.onPrimaryContainer : colors.onSurfaceVariant;
      return SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.only(right: AppTokens.space4),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTokens.radiusS),
              color: done ? colors.primaryContainer : null,
              border: Border.all(
                color: isToday
                    ? colors.primary
                    : done
                    ? Colors.transparent
                    : colors.outline,
                width: isToday ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(color: fg),
                ),
                const SizedBox(height: 2),
                Text(
                  '${date.day}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: done ? colors.primary : colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                if (isToday)
                  Icon(
                    Symbols.local_fire_department_rounded,
                    size: 18,
                    fill: done ? 1 : 0,
                    color: done
                        ? context.tokens.accent
                        : colors.onSurfaceVariant,
                  )
                else if (done)
                  Icon(Symbols.check_rounded, size: 16, color: colors.primary)
                else
                  const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    }

    final top = ranking.isEmpty ? 1 : math.max(1, ranking.first.memorizedCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.homeStudyRecord,
                style: theme.textTheme.titleLarge,
              ),
            ),
            AppButton.text(label: l10n.vocabTitle, onPressed: onOpen),
          ],
        ),
        const SizedBox(height: AppTokens.space12),
        if (empty)
          Text(l10n.homeStudyEmpty, style: theme.textTheme.bodySmall)
        else ...[
          // 연속 일수: 가장 크게.
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Icon(
                Symbols.local_fire_department_rounded,
                fill: 1,
                color: streak.current > 0
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppTokens.space4),
              Text(
                '${streak.current}',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppTokens.space8),
              Text(l10n.homeStreakUnit, style: theme.textTheme.titleMedium),
              const Spacer(),
              if (streak.best > 0)
                Text(
                  l10n.homeStreakBest(streak.best),
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: AppTokens.space4),
          Text(streakHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppTokens.space16),
          // 7칸이 한 화면에 보이고, 왼쪽으로 밀면 이전 날짜(8주 전까지)가 나온다.
          // 목록은 화면 양끝까지 뻗어서, 밀 때 칸이 페이지 여백에서 잘려 보이지 않고 화면 끝에서 걸친다.
          LayoutBuilder(
            builder: (context, box) {
              final cell = (box.maxWidth + AppTokens.space4) / 7;
              final bleed = box.maxWidth + 2 * AppTokens.pagePadding;
              return SizedBox(
                height: 72,
                child: OverflowBox(
                  minWidth: bleed,
                  maxWidth: bleed,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.pagePadding,
                    ),
                    itemCount: 56,
                    itemExtent: cell,
                    itemBuilder: (_, back) => dayCell(back, cell),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppTokens.space24),
          // 외운 단어.
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$memorized',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: AppTokens.space8),
              Expanded(
                child: Text(
                  '${l10n.homeStatMemorized} · ${l10n.homeMemorizedOf(words)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space8),
          _Bar(value: words == 0 ? 0 : memorized / words),
          if (ranking.length > 1) ...[
            const SizedBox(height: AppTokens.space24),
            Text(l10n.homeRankTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTokens.space8),
            for (var i = 0; i < ranking.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '${i + 1}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: i == 0
                              ? colors.primary
                              : colors.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        ranking[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: AppTokens.space12),
                    Expanded(
                      flex: 4,
                      child: _Bar(value: ranking[i].memorizedCount / top),
                    ),
                    const SizedBox(width: AppTokens.space12),
                    SizedBox(
                      width: 40,
                      child: Text(
                        l10n.homeRankCount(ranking[i].memorizedCount),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
        const SizedBox(height: AppTokens.space24),
        AppButton.secondary(
          label: l10n.homeStudyStart,
          height: 48,
          onPressed: canStart ? onStart : null,
        ),
      ],
    );
  }
}

/// 가는 진행 막대 (0~1).
class _Bar extends StatelessWidget {
  const _Bar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          Container(height: 6, color: colors.outline.withValues(alpha: 0.5)),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(height: 6, color: colors.primary),
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
          AppCard.elevated(
            padding: EdgeInsets.zero,
            child: Center(
              child: AppEmptyState(
                icon: Symbols.history_rounded,
                title: l10n.homeRecentEmpty,
              ),
            ),
          )
        else
          AppCard.elevated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space12,
              vertical: AppTokens.cardListPaddingV,
            ),
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
