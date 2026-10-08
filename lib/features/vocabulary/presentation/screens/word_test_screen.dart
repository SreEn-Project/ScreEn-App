import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/word_test.dart';
import '../../domain/usecases/vocabulary_usecases.dart';
import '../../domain/entities/vocabulary.dart';
import '../view_models/word_test_view_model.dart';
import '../widgets/study_widgets.dart';

/// 암기 테스트 (L-03, AD-09): 방식 고르기 → 한 문제씩 풀고 바로 정답 확인 → 점수와 틀린 단어.
class WordTestScreen extends ConsumerWidget {
  const WordTestScreen({super.key, required this.selection});

  final WordbookSelection selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(wordTestViewModelProvider(selection)).value;

    if (state == null) {
      return AppPage(title: l10n.testTitle, children: const []);
    }
    return switch (state.phase) {
      WordTestPhase.setup => _Setup(selection: selection, state: state),
      WordTestPhase.running => _Running(selection: selection, state: state),
      WordTestPhase.finished => _Result(selection: selection, state: state),
    };
  }
}

/// 화면 아래에 고정하는 버튼 영역.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.pagePadding,
        AppTokens.space8,
        AppTokens.pagePadding,
        AppTokens.space16,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _Setup extends ConsumerWidget {
  const _Setup({required this.selection, required this.state});

  final WordbookSelection selection;
  final WordTestState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final model = ref.read(wordTestViewModelProvider(selection).notifier);
    final book = state.book;
    final count = book?.wordCount ?? 0;
    final questionCount = count < CreateWordTest.maxQuestions
        ? count
        : CreateWordTest.maxQuestions;

    return AppPage(
      title: l10n.testTitle,
      bottom: _BottomBar(
        children: [
          AppButton(
            label: l10n.testStart,
            onPressed: count == 0 ? null : model.start,
          ),
        ],
      ),
      children: [
        StudySetupHeader(
          icon: Symbols.menu_book_rounded,
          title: book?.name ?? '',
          subtitle: l10n.testQuestionCount(questionCount),
        ),
        const SizedBox(height: AppTokens.sectionGap),
        StudyModeCard<WordTestMode>(
          values: const [WordTestMode.choice, WordTestMode.typing],
          selected: state.mode,
          label: (m) => m == WordTestMode.choice
              ? l10n.testModeChoice
              : l10n.testModeTyping,
          hint: state.mode == WordTestMode.choice
              ? l10n.testModeChoiceHint
              : l10n.testModeTypingHint,
          onChanged: model.setMode,
          notes: [
            if (!state.choiceAvailable)
              StudyNote(
                l10n.testChoiceUnavailable(CreateWordTest.minWordsForChoice),
                error: true,
              ),
            if (state.failedToStart)
              StudyNote(l10n.testCannotStart, error: true),
          ],
        ),
      ],
    );
  }
}

class _Running extends ConsumerStatefulWidget {
  const _Running({required this.selection, required this.state});

  final WordbookSelection selection;
  final WordTestState state;

  @override
  ConsumerState<_Running> createState() => _RunningState();
}

class _RunningState extends ConsumerState<_Running> {
  final _input = TextEditingController();
  int _shake = 0;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_Running old) {
    super.didUpdateWidget(old);
    // 다음 문제로 넘어가면 입력창을 비운다.
    if (old.state.index != widget.state.index) _input.clear();
    // 답을 낸 순간: 맞으면 가볍게, 틀리면 묵직하게 진동하고 틀린 카드가 흔들린다.
    if (!old.state.revealed && widget.state.revealed) {
      if (widget.state.lastAnswer?.correct ?? false) {
        HapticFeedback.mediumImpact();
      } else {
        HapticFeedback.heavyImpact();
        _shake++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = widget.state;
    final model = ref.read(
      wordTestViewModelProvider(widget.selection).notifier,
    );
    final question = state.current;
    if (question == null) {
      return AppPage(title: l10n.testTitle, children: const []);
    }
    final revealed = state.revealed;
    final given = state.lastAnswer?.answer;
    final correct = state.lastAnswer?.correct ?? false;
    final isLast = state.index + 1 >= state.questions.length;
    final typing = question.mode == WordTestMode.typing;

    Widget choice(String text) {
      final isAnswer = text == question.meaning;
      final isPicked = revealed && text == given;
      final Color? fill = !revealed
          ? null
          : isAnswer
          ? studyFill(colors, correct: true)
          : isPicked
          ? studyFill(colors, correct: false)
          : null;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppTokens.space12),
        child: ShakeEffect(
          trigger: isPicked && !isAnswer ? _shake : 0,
          child: PopEffect(
            trigger: revealed && isAnswer ? 1 : 0,
            scale: 1.04,
            child: AppCard(
              onTap: revealed ? null : () => model.submit(text),
              color: fill,
              shadow: fill == null,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.rowPaddingH,
                vertical: AppTokens.space16,
              ),
              child: Row(
                children: [
                  Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
                  if (revealed && isAnswer) ...[
                    AppBadge(label: l10n.testAnswerLabel),
                    const SizedBox(width: AppTokens.space8),
                    Icon(
                      Symbols.check_circle_rounded,
                      fill: 1,
                      color: colors.primary,
                      size: 22,
                    ),
                  ] else if (isPicked)
                    Icon(
                      Symbols.cancel_rounded,
                      fill: 1,
                      color: colors.error,
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AppPage(
      title: l10n.testTitle,
      bottom: revealed
          ? _BottomBar(
              children: [
                AppButton(
                  label: isLast ? l10n.testSeeResult : l10n.testNext,
                  onPressed: model.next,
                ),
              ],
            )
          : typing
          ? _BottomBar(
              children: [
                AppButton(
                  label: l10n.testSubmit,
                  onPressed: () => model.submit(_input.text),
                ),
              ],
            )
          : null,
      children: [
        StudyProgress(
          index: state.index,
          total: state.questions.length,
          correct: state.correctCount,
          revealed: revealed,
        ),
        const SizedBox(height: AppTokens.sectionGap),
        StudyPrompt(
          label: typing ? l10n.testPromptMeaning : l10n.testPromptWord,
          text: question.prompt,
        ),
        const SizedBox(height: AppTokens.sectionGap),
        // 답을 낸 뒤 결과(정답이에요 / 오답이에요 + 정답)를 문제 바로 아래 맨 위에 보여 준다.
        if (revealed) ...[
          StudyFeedback(correct: correct, expected: question.expected),
          const SizedBox(height: AppTokens.sectionGap),
        ],
        if (typing) ...[
          ShakeEffect(
            trigger: _shake,
            child: AppTextField(
              controller: _input,
              hint: l10n.testAnswerHint,
              autofocus: true,
              enabled: !revealed,
              onSubmitted: model.submit,
            ),
          ),
        ] else ...[
          for (final text in question.choices) choice(text),
        ],
      ],
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.selection, required this.state});

  final WordbookSelection selection;
  final WordTestState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final model = ref.read(wordTestViewModelProvider(selection).notifier);
    final wrong = state.wrongAnswers;
    final total = state.questions.length;

    return AppPage(
      title: l10n.testResultTitle,
      bottom: _BottomBar(
        children: [
          AppButton(label: l10n.testRetry, onPressed: model.retry),
          const SizedBox(height: AppTokens.space8),
          AppButton.secondary(
            label: l10n.testDone,
            onPressed: () => context.pop(),
          ),
        ],
      ),
      children: [
        StudyResultHero(
          score: l10n.testScore(state.correctCount, total),
          caption: wrong.isEmpty
              ? l10n.testPerfect
              : l10n.testWrongCount(wrong.length),
          celebrate: total > 0 && state.correctCount * 2 >= total,
        ),
        if (wrong.isNotEmpty) ...[
          const SizedBox(height: AppTokens.sectionGap),
          SectionTitle(l10n.testWrongWords),
          const SizedBox(height: AppTokens.sectionTitleGap),
          AppCard(
            padding: const EdgeInsets.symmetric(
              vertical: AppTokens.cardListPaddingV,
            ),
            child: Column(
              children: [
                for (var i = 0; i < wrong.length; i++) ...[
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
                            wrong[i].question.word,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppTokens.space4),
                          Text(
                            wrong[i].question.meaning,
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (wrong[i].answer.trim().isNotEmpty) ...[
                            const SizedBox(height: AppTokens.space4),
                            Text(
                              l10n.testYourAnswer(wrong[i].answer.trim()),
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
