import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/word_test.dart';
import '../../domain/usecases/vocabulary_usecases.dart';
import '../view_models/word_test_view_model.dart';

/// 암기 테스트 (L-03, AD-09): 방식 고르기 → 한 문제씩 풀고 바로 정답 확인 → 점수와 틀린 단어.
class WordTestScreen extends ConsumerWidget {
  const WordTestScreen({super.key, required this.wordbookId});

  final int wordbookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(wordTestViewModelProvider(wordbookId)).value;

    if (state == null) {
      return AppPage(title: l10n.testTitle, children: const []);
    }
    return switch (state.phase) {
      WordTestPhase.setup => _Setup(wordbookId: wordbookId, state: state),
      WordTestPhase.running => _Running(wordbookId: wordbookId, state: state),
      WordTestPhase.finished => _Result(wordbookId: wordbookId, state: state),
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

class _Note extends StatelessWidget {
  const _Note(this.text, {this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.sectionTitleIndent,
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: error ? theme.colorScheme.error : null,
        ),
      ),
    );
  }
}

class _Setup extends ConsumerWidget {
  const _Setup({required this.wordbookId, required this.state});

  final int wordbookId;
  final WordTestState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final model = ref.read(wordTestViewModelProvider(wordbookId).notifier);
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
        AppCard(
          child: Row(
            children: [
              const IconBadge(icon: Symbols.menu_book_rounded, size: 44),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book?.name ?? '', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      l10n.testQuestionCount(questionCount),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.sectionGap),
        SectionTitle(l10n.testMode),
        const SizedBox(height: AppTokens.sectionTitleGap),
        AppSegmented<WordTestMode>(
          values: const [WordTestMode.choice, WordTestMode.typing],
          selected: state.mode,
          label: (m) => m == WordTestMode.choice
              ? l10n.testModeChoice
              : l10n.testModeTyping,
          onChanged: model.setMode,
        ),
        const SizedBox(height: AppTokens.space12),
        _Note(
          state.mode == WordTestMode.choice
              ? l10n.testModeChoiceHint
              : l10n.testModeTypingHint,
        ),
        if (!state.choiceAvailable) ...[
          const SizedBox(height: AppTokens.space8),
          _Note(
            l10n.testChoiceUnavailable(CreateWordTest.minWordsForChoice),
            error: true,
          ),
        ],
        if (state.failedToStart) ...[
          const SizedBox(height: AppTokens.space8),
          _Note(l10n.testCannotStart, error: true),
        ],
      ],
    );
  }
}

class _Running extends ConsumerStatefulWidget {
  const _Running({required this.wordbookId, required this.state});

  final int wordbookId;
  final WordTestState state;

  @override
  ConsumerState<_Running> createState() => _RunningState();
}

class _RunningState extends ConsumerState<_Running> {
  final _input = TextEditingController();

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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = widget.state;
    final model = ref.read(
      wordTestViewModelProvider(widget.wordbookId).notifier,
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
          ? colors.primaryContainer
          : isPicked
          ? colors.errorContainer
          : null;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppTokens.space8),
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
              if (revealed && isAnswer)
                Icon(Symbols.check_rounded, color: colors.primary, size: 22)
              else if (isPicked)
                Icon(Symbols.close_rounded, color: colors.error, size: 22),
            ],
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
        Row(
          children: [
            Text(
              l10n.testProgress(state.index + 1, state.questions.length),
              style: theme.textTheme.labelLarge,
            ),
            const Spacer(),
            Text(
              l10n.testCorrectSoFar(state.correctCount),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppTokens.space8),
        AppProgressBar(
          value: (state.index + (revealed ? 1 : 0)) / state.questions.length,
        ),
        const SizedBox(height: AppTokens.sectionGap),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.pagePadding,
            vertical: AppTokens.sectionGap,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  typing ? l10n.testPromptMeaning : l10n.testPromptWord,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppTokens.space8),
                Text(
                  question.prompt,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppTokens.sectionGap),
        if (typing) ...[
          AppTextField(
            controller: _input,
            hint: l10n.testAnswerHint,
            autofocus: true,
            enabled: !revealed,
            onSubmitted: model.submit,
          ),
          if (revealed) ...[
            const SizedBox(height: AppTokens.space16),
            _Feedback(correct: correct, expected: question.expected),
          ],
        ] else ...[
          for (final text in question.choices) choice(text),
          if (revealed && !correct) ...[
            const SizedBox(height: AppTokens.space8),
            _Feedback(correct: false, expected: question.expected),
          ],
        ],
      ],
    );
  }
}

/// 제출 직후 "정답이에요" / "정답: …".
class _Feedback extends StatelessWidget {
  const _Feedback({required this.correct, required this.expected});

  final bool correct;
  final String expected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? Symbols.check_circle_rounded : Symbols.cancel_rounded,
            color: correct ? colors.primary : colors.error,
            size: 22,
          ),
          const SizedBox(width: AppTokens.space8),
          Expanded(
            child: Text(
              correct ? l10n.testCorrect : l10n.testWrong(expected),
              style: theme.textTheme.titleMedium?.copyWith(
                color: correct ? colors.primary : colors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.wordbookId, required this.state});

  final int wordbookId;
  final WordTestState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final model = ref.read(wordTestViewModelProvider(wordbookId).notifier);
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
        AppCard(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const IconBadge(icon: Symbols.emoji_events_rounded, size: 56),
                const SizedBox(height: AppTokens.space16),
                Text(
                  l10n.testScore(state.correctCount, total),
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTokens.space4),
                Text(
                  wrong.isEmpty
                      ? l10n.testPerfect
                      : l10n.testWrongCount(wrong.length),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
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
