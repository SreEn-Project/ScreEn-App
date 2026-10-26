import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';

/// 학습 · 테스트 화면이 같이 쓰는 조각 (AD-15). 화면마다 배치가 제각각이던 것을 한 모양으로 맞춘다.

/// 정답 · 오답 표시 배경. 밝은 테마 · 어두운 테마 모두에서 글자가 읽히도록
/// 컨테이너 색 대신 primary / error를 옅게 깐다 (design.md 알림 색 규칙).
Color studyFill(ColorScheme colors, {required bool correct}) =>
    (correct ? colors.primary : colors.error).withValues(alpha: 0.16);

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
        width: double.infinity,
        padding: const EdgeInsets.all(AppTokens.space16),
        decoration: BoxDecoration(
          color: studyFill(colors, correct: correct),
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  correct
                      ? Symbols.check_circle_rounded
                      : Symbols.cancel_rounded,
                  fill: 1,
                  color: tone,
                  size: 22,
                ),
                const SizedBox(width: AppTokens.space8),
                Text(
                  correct ? l10n.testCorrect : l10n.testWrongTitle,
                  style: theme.textTheme.titleMedium?.copyWith(color: tone),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space12),
            // 정답은 맞았을 때도 틀렸을 때도 큰 글씨로 따로 보여 준다.
            Text(
              l10n.testAnswerLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            Text(
              expected,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.onSurface,
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

/// 결과 화면의 틀린(놓친) 단어 한 줄.
class StudyWrongWord {
  const StudyWrongWord({
    required this.word,
    required this.meaning,
    this.yourAnswer,
  });

  final String word;
  final String meaning;

  /// 사용자가 적은 답. 비어 있으면 보이지 않는다.
  final String? yourAnswer;
}

/// 학습 · 테스트 결과 화면의 공통 틀: 맨 위 [hero], 틀린 단어 목록, 아래 [actions] 버튼.
class StudyResultPage extends StatelessWidget {
  const StudyResultPage({
    super.key,
    required this.title,
    required this.hero,
    required this.actions,
    this.listTitle,
    this.words = const [],
  });

  final String title;
  final Widget hero;

  /// 아래 버튼들. 사이에 간격이 들어간다.
  final List<Widget> actions;
  final String? listTitle;
  final List<StudyWrongWord> words;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AppPage(
      title: title,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: AppTokens.space8),
            actions[i],
          ],
        ],
      ),
      children: [
        hero,
        if (words.isNotEmpty) ...[
          const SizedBox(height: AppTokens.sectionGap),
          SectionTitle(listTitle ?? l10n.testWrongWords),
          const SizedBox(height: AppTokens.sectionTitleGap),
          AppCard(
            padding: const EdgeInsets.symmetric(
              vertical: AppTokens.cardListPaddingV,
            ),
            child: Column(
              children: [
                for (var i = 0; i < words.length; i++) ...[
                  if (i > 0) const AppDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.rowPaddingH,
                      vertical: AppTokens.space12,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            words[i].word,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppTokens.space4),
                          Text(
                            words[i].meaning,
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (words[i].yourAnswer?.isNotEmpty ?? false) ...[
                            const SizedBox(height: AppTokens.space4),
                            Text(
                              l10n.testYourAnswer(words[i].yourAnswer!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
