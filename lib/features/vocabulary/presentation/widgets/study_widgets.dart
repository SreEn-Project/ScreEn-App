import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';

/// 학습 · 테스트 화면이 같이 쓰는 조각 (AD-15). 화면마다 배치가 제각각이던 것을 한 모양으로 맞춘다.

/// 시작 화면 맨 위: 단어장 이름과 한 줄 설명.
class StudySetupHeader extends StatelessWidget {
  const StudySetupHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          IconBadge(icon: icon, size: 44),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppTokens.space4),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 방식 고르기: 제목 + 분할 버튼 + 설명을 카드 하나에 모은다.
class StudyModeCard<T> extends StatelessWidget {
  const StudyModeCard({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.notes = const [],
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final String hint;
  final ValueChanged<T> onChanged;

  /// 설명 아래에 덧붙이는 안내 (오류 색 · 일반 색).
  final List<StudyNote> notes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.testMode, style: theme.textTheme.labelLarge),
          const SizedBox(height: AppTokens.space12),
          AppSegmented<T>(
            values: values,
            selected: selected,
            label: label,
            onChanged: onChanged,
          ),
          const SizedBox(height: AppTokens.space12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              hint,
              key: ValueKey(hint),
              style: theme.textTheme.bodySmall,
            ),
          ),
          for (final note in notes) ...[
            const SizedBox(height: AppTokens.space8),
            Text(
              note.text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: note.error ? theme.colorScheme.error : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StudyNote {
  const StudyNote(this.text, {this.error = false});

  final String text;
  final bool error;
}

/// 진행 중 맨 위: "3 / 10" + 맞힌 수 알약 + 진행 막대.
class StudyProgress extends StatelessWidget {
  const StudyProgress({
    super.key,
    required this.index,
    required this.total,
    required this.correct,
    required this.revealed,
  });

  final int index;
  final int total;
  final int correct;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Text(
              l10n.testProgress(index + 1, total),
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: ShapeDecoration(
                shape: const StadiumBorder(),
                color: colors.primaryContainer,
              ),
              child: PopEffect(
                trigger: correct,
                child: Text(
                  l10n.testCorrectSoFar(correct),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.space12),
        AppProgressBar(value: (index + (revealed ? 1 : 0)) / total),
      ],
    );
  }
}

/// 문제 카드: 작은 라벨 + 큰 글.
class StudyPrompt extends StatelessWidget {
  const StudyPrompt({super.key, required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.pagePadding,
        vertical: AppTokens.sectionGap + AppTokens.space8,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.primary,
              ),
            ),
            const SizedBox(height: AppTokens.space12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                  scale: Tween(begin: 0.94, end: 1.0).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                text,
                key: ValueKey(text),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 제출 직후 "정답이에요" / "정답: …" 띠. 나타날 때 살짝 튀어나온다.
class StudyFeedback extends StatelessWidget {
  const StudyFeedback({
    super.key,
    required this.correct,
    required this.expected,
  });

  final bool correct;
  final String expected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tone = correct ? colors.primary : colors.error;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space16,
          vertical: AppTokens.space12,
        ),
        decoration: BoxDecoration(
          color: correct ? colors.primaryContainer : colors.errorContainer,
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              correct ? Symbols.check_circle_rounded : Symbols.cancel_rounded,
              fill: 1,
              color: tone,
              size: 22,
            ),
            const SizedBox(width: AppTokens.space8),
            Expanded(
              child: Text(
                correct ? l10n.testCorrect : l10n.testWrong(expected),
                style: theme.textTheme.titleMedium?.copyWith(color: tone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 결과 맨 위 카드: 트로피 + 점수 + 한 줄. [celebrate]면 열릴 때 조각이 터진다.
class StudyResultHero extends StatefulWidget {
  const StudyResultHero({
    super.key,
    required this.score,
    required this.caption,
    this.celebrate = false,
  });

  final String score;
  final String caption;
  final bool celebrate;

  @override
  State<StudyResultHero> createState() => _StudyResultHeroState();
}

class _StudyResultHeroState extends State<StudyResultHero> {
  final _layer = GlobalKey<BurstLayerState>();
  final _badge = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.celebrate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final color = Theme.of(context).colorScheme.primary;
        _layer.currentState?.burstAt(
          _badge,
          color: color,
          count: 34,
          spread: 1.4,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppCard(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.4, end: 1),
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.elasticOut,
                  builder: (context, t, child) =>
                      Transform.scale(scale: t, child: child),
                  child: IconBadge(
                    key: _badge,
                    icon: Symbols.emoji_events_rounded,
                    size: 56,
                  ),
                ),
                const SizedBox(height: AppTokens.space16),
                Text(widget.score, style: theme.textTheme.headlineMedium),
                const SizedBox(height: AppTokens.space4),
                Text(widget.caption, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
        Positioned.fill(child: BurstLayer(key: _layer)),
      ],
    );
  }
}
