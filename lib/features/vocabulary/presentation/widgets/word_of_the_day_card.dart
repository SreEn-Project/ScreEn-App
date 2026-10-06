import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_models/word_of_the_day_view_model.dart';

/// 홈의 오늘의 단어 카드 (S-03, AD-14). 저장한 단어가 없으면 아무것도 그리지 않는다.
class WordOfTheDayCard extends ConsumerWidget {
  const WordOfTheDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wordOfTheDayViewModelProvider).value;
    final daily = state?.daily;
    if (state == null || daily == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final model = ref.read(wordOfTheDayViewModelProvider.notifier);
    final word = daily.word;

    Widget choice(String text) {
      final isAnswer = text == word.meaning;
      final isPicked = state.picked == text;
      final Color? fill = !state.answered
          ? null
          : isAnswer
          ? colors.primaryContainer
          : isPicked
          ? colors.errorContainer
          : null;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppTokens.space8),
        child: AppCard(
          onTap: state.answered ? null : () => model.answer(text),
          color: fill,
          shadow: fill == null,
          radius: AppTokens.radiusInput,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.rowPaddingH,
            vertical: AppTokens.space12,
          ),
          child: Row(
            children: [
              Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
              if (state.answered && isAnswer)
                Icon(Symbols.check_rounded, color: colors.primary, size: 20)
              else if (isPicked)
                Icon(Symbols.close_rounded, color: colors.error, size: 20),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.space12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconBadge(icon: Symbols.wb_sunny_rounded, size: 36),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Text(
                    l10n.wotdTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                AppButton.text(
                  label: l10n.wotdAnother,
                  onPressed: model.another,
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space12),
            Text(word.word, style: theme.textTheme.headlineSmall),
            if (word.pronunciation?.isNotEmpty ?? false) ...[
              const SizedBox(height: AppTokens.space4),
              Text(word.pronunciation!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: AppTokens.space12),
            if (daily.hasQuiz) ...[
              if (!state.answered)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.space8),
                  child: Text(
                    l10n.testPromptWord,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              for (final text in daily.choices) choice(text),
              if (state.answered)
                Text(
                  state.correct
                      ? l10n.testCorrect
                      : l10n.testWrong(word.meaning),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: state.correct ? colors.primary : colors.error,
                  ),
                ),
            ] else if (state.answered)
              Text(word.meaning, style: theme.textTheme.titleMedium)
            else
              AppButton.secondary(
                label: l10n.wotdReveal,
                height: 44,
                onPressed: model.reveal,
              ),
          ],
        ),
      ),
    );
  }
}
