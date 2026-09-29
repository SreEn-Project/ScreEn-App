import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/bridge/bridge_providers.dart';
import '../../../core/l10n/labels.dart';
import '../../../core/widgets/accent_title.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../core/widgets/section_title.dart';
import '../../../l10n/app_localizations.dart';
import '../../language/domain/supported_language.dart';

/// 홈 (S-03, FL-03).
/// UI 퍼블리싱 단계: 시작 버튼 · 캡처 모드는 화면 안에서만 바뀐다.
/// 서비스 시작/중지는 FL-03, 설정 값은 SettingsRepository와 ViewModel로 연결한다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _running = false;
  CaptureMode _captureMode = CaptureMode.fullScreen;
  final EngineType _engine = EngineType.mlKit;
  final String _targetLanguage = 'ko';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.pagePadding,
            16,
            AppTokens.pagePadding,
            32,
          ),
          children: [
            const _Header(),
            const SizedBox(height: 24),
            _StatusCard(
              running: _running,
              targetLanguage: SupportedLanguage.byCode(_targetLanguage)
                  .displayName(locale),
              engine: l10n.engineName(_engine),
              captureMode: l10n.captureModeName(_captureMode),
            ),
            const SizedBox(height: 16),
            _StartButton(
              running: _running,
              onPressed: () => setState(() => _running = !_running),
            ),
            const SizedBox(height: 32),
            SectionTitle(l10n.homeCaptureModes),
            const SizedBox(height: 12),
            _CaptureModeTiles(
              selected: _captureMode,
              onSelected: (mode) => setState(() => _captureMode = mode),
            ),
            const SizedBox(height: 32),
            SectionTitle(
              l10n.homeRecent,
              // 기록 화면은 FL-13(4단계).
              action: TextButton(
                onPressed: null,
                child: Text(l10n.homeRecentSeeAll),
              ),
            ),
            const SizedBox(height: 12),
            const _RecentSection(),
          ],
        ),
      ),
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
        CircleIconButton(
          icon: Symbols.notifications_rounded,
          tooltip: l10n.homeNotifications,
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        CircleIconButton(
          icon: Symbols.settings_rounded,
          tooltip: l10n.homeSettings,
          onPressed: () => context.push(AppRoutes.settings),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.running,
    required this.targetLanguage,
    required this.engine,
    required this.captureMode,
  });

  final bool running;
  final String targetLanguage;
  final String engine;
  final String captureMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AppCard(
      gradient: context.tokens.heroGradient,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            running ? l10n.homeServiceRunning : l10n.homeServiceStopped,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            running ? l10n.homeServiceRunningHint : l10n.homeServiceHint,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          _StatusRow(
            icon: Symbols.translate_rounded,
            label: l10n.homeStatusTargetLanguage,
            value: targetLanguage,
          ),
          const SizedBox(height: 12),
          _StatusRow(
            icon: Symbols.memory_rounded,
            label: l10n.homeStatusEngine,
            value: engine,
          ),
          const SizedBox(height: 12),
          _StatusRow(
            icon: Symbols.crop_free_rounded,
            label: l10n.homeStatusCaptureMode,
            value: captureMode,
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        IconBadge(icon: icon, color: theme.colorScheme.surface),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

/// 큰 primary 알약 버튼 + 상태 점 (켜짐: accent, 꺼짐: onPrimary 반투명).
class _StartButton extends StatelessWidget {
  const _StartButton({required this.running, required this.onPressed});

  final bool running;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppTokens.largeButtonHeight + 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: running
                  ? context.tokens.accent
                  : colors.onPrimary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 12),
          Text(running ? l10n.homeStop : l10n.homeStart),
        ],
      ),
    );
  }
}

class _CaptureModeTiles extends StatelessWidget {
  const _CaptureModeTiles({required this.selected, required this.onSelected});

  final CaptureMode selected;
  final ValueChanged<CaptureMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        for (final mode in CaptureMode.values) ...[
          if (mode != CaptureMode.values.first) const SizedBox(width: 12),
          Expanded(
            child: _CaptureModeTile(
              icon: captureModeIcon(mode),
              label: l10n.captureModeName(mode),
              selected: mode == selected,
              onTap: () => onSelected(mode),
            ),
          ),
        ],
      ],
    );
  }
}

class _CaptureModeTile extends StatelessWidget {
  const _CaptureModeTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      color: selected ? theme.colorScheme.primaryContainer : null,
      child: Column(
        children: [
          IconBadge(
            icon: icon,
            size: 44,
            color: selected ? theme.colorScheme.surface : null,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.labelLarge,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
              ChoiceChip(
                label: Text(filters[i]),
                selected: _filter == i,
                onSelected: (_) => setState(() => _filter = i),
              ),
          ],
        ),
        const SizedBox(height: 12),
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
