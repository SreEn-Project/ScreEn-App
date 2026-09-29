import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/accent_title.dart';
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';

/// 홈 (S-03) 레이아웃. 상태 값은 자리 표시이며,
/// 서비스 시작/중지는 FL-03, 언어 · 엔진 · 모드는 FL-04/FL-06/FL-08에서 ViewModel과 연결한다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
              targetLanguage: l10n.languageKorean,
              engine: l10n.engineMlKit,
              captureMode: l10n.captureModeFull,
            ),
            const SizedBox(height: 16),
            const _StartButton(running: false, onPressed: null),
            const SizedBox(height: 32),
            _SectionTitle(l10n.homeCaptureModes),
            const SizedBox(height: 12),
            const _CaptureModeTiles(),
            const SizedBox(height: 32),
            _SectionTitle(l10n.homeRecent),
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
        _CircleIconButton(
          icon: Symbols.notifications_rounded,
          tooltip: l10n.homeNotifications,
          onPressed: () {},
        ),
      ],
    );
  }
}

/// 흰 원 + 옅은 그림자 아이콘 버튼.
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        boxShadow: context.tokens.cardShadow,
      ),
      child: IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.targetLanguage,
    required this.engine,
    required this.captureMode,
  });

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
          Text(l10n.homeServiceStopped, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(l10n.homeServiceHint, style: theme.textTheme.bodySmall),
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
        _IconBadge(icon: icon, color: theme.colorScheme.surface),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

/// 원형 배경 위 선 아이콘. 기본 배경은 primaryContainer.
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, this.color, this.size = 36});

  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? colors.primaryContainer,
      ),
      child: Icon(icon, size: size * 0.55, color: colors.onPrimaryContainer),
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
          Text(l10n.homeStart),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _CaptureModeTiles extends StatelessWidget {
  const _CaptureModeTiles();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _CaptureModeTile(
            icon: Symbols.fullscreen_rounded,
            label: l10n.captureModeFull,
            selected: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CaptureModeTile(
            icon: Symbols.crop_rounded,
            label: l10n.captureModeRegion,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CaptureModeTile(
            icon: Symbols.push_pin_rounded,
            label: l10n.captureModeFixed,
          ),
        ),
      ],
    );
  }
}

class _CaptureModeTile extends StatelessWidget {
  const _CaptureModeTile({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      color: selected ? theme.colorScheme.primaryContainer : null,
      child: Column(
        children: [
          _IconBadge(
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
              const _IconBadge(icon: Symbols.history_rounded, size: 48),
              const SizedBox(height: 12),
              Text(l10n.homeRecentEmpty, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
