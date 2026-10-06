import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/word_assembly.dart';
import '../../domain/usecases/vocabulary_usecases.dart';
import '../view_models/assembly_view_model.dart';

/// 단어 조립 (L-07, AD-13): 뜻을 보고 조각 · 글자 카드로 단어를 완성한다.
class AssemblyScreen extends ConsumerWidget {
  const AssemblyScreen({super.key, required this.wordbookId});

  final int wordbookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(assemblyViewModelProvider(wordbookId)).value;
    if (state == null) {
      return AppPage(title: l10n.assembleTitle, children: const []);
    }
    return switch (state.phase) {
      AssemblyPhase.setup => _Setup(wordbookId: wordbookId, state: state),
      AssemblyPhase.running => _Running(wordbookId: wordbookId, state: state),
      AssemblyPhase.finished => _Result(wordbookId: wordbookId, state: state),
    };
  }
}

class _Setup extends ConsumerWidget {
  const _Setup({required this.wordbookId, required this.state});

  final int wordbookId;
  final AssemblyState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final model = ref.read(assemblyViewModelProvider(wordbookId).notifier);
    final count = state.book?.wordCount ?? 0;
    final questionCount = count < CreateAssemblyGame.maxQuestions
        ? count
        : CreateAssemblyGame.maxQuestions;

    return AppPage(
      title: l10n.assembleTitle,
      bottom: AppButton(
        label: l10n.testStart,
        onPressed: count == 0 ? null : model.start,
      ),
      children: [
        AppCard(
          child: Row(
            children: [
              const IconBadge(icon: Symbols.extension_rounded, size: 44),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.book?.name ?? '',
                      style: theme.textTheme.titleMedium,
                    ),
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
        AppSegmented<AssemblyMode>(
          values: AssemblyMode.values,
          selected: state.mode,
          label: (m) => m == AssemblyMode.pieces
              ? l10n.assembleModePieces
              : l10n.assembleModeLetters,
          onChanged: model.setMode,
        ),
        const SizedBox(height: AppTokens.space12),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.sectionTitleIndent,
          ),
          child: Text(
            state.mode == AssemblyMode.pieces
                ? l10n.assembleModePiecesHint
                : l10n.assembleModeLettersHint,
            style: theme.textTheme.bodySmall,
          ),
        ),
        if (state.failedToStart) ...[
          const SizedBox(height: AppTokens.space8),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.sectionTitleIndent,
            ),
            child: Text(
              l10n.testCannotStart,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 카드 한 장. 탭하거나 끌 수 있다.
class _TileCard extends StatelessWidget {
  const _TileCard({
    super.key,
    required this.text,
    this.onTap,
    this.color,
    this.minWidth = 48,
  });

  final String text;
  final VoidCallback? onTap;
  final Color? color;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: color,
      radius: AppTokens.radiusInput,
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space12),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth, minHeight: 48),
        child: Center(
          widthFactor: 1,
          child: Text(text, style: Theme.of(context).textTheme.titleMedium),
        ),
      ),
    );
  }
}

class _Running extends ConsumerWidget {
  const _Running({required this.wordbookId, required this.state});

  final int wordbookId;
  final AssemblyState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final model = ref.read(assemblyViewModelProvider(wordbookId).notifier);
    final question = state.current;
    if (question == null) {
      return AppPage(title: l10n.assembleTitle, children: const []);
    }
    final revealed = state.revealed;
    final correct = state.lastResult?.correct ?? false;
    final isLast = state.index + 1 >= state.questions.length;
    final pieces = question.mode == AssemblyMode.pieces;
    final slotColor = !revealed
        ? null
        : correct
        ? colors.primaryContainer
        : colors.errorContainer;

    final Widget slot;
    if (pieces) {
      slot = state.placed.isEmpty
          ? Text(l10n.assembleSlotHint, style: theme.textTheme.bodySmall)
          : Wrap(
              spacing: AppTokens.space8,
              runSpacing: AppTokens.space8,
              children: [
                for (final id in state.placed)
                  _TileCard(
                    key: ValueKey('placed-$id'),
                    text: question.tile(id).text,
                    color: slotColor,
                    onTap: revealed ? null : () => model.remove(id),
                  ),
              ],
            );
    } else {
      slot = SizedBox(
        height: 56,
        child: ReorderableListView(
          scrollDirection: Axis.horizontal,
          buildDefaultDragHandles: false,
          proxyDecorator: (child, _, _) => child,
          // onReorderItem은 아래로 옮길 때의 목적지 보정이 이미 되어 있다.
          onReorderItem: model.reorder,
          children: [
            for (var i = 0; i < state.placed.length; i++)
              ReorderableDragStartListener(
                key: ValueKey('letter-${state.placed[i]}'),
                index: i,
                enabled: !revealed,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppTokens.space8),
                  child: _TileCard(
                    text: question.tile(state.placed[i]).text,
                    color: slotColor,
                    minWidth: 44,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return AppPage(
      title: l10n.assembleTitle,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (revealed)
            AppButton(
              label: isLast ? l10n.testSeeResult : l10n.testNext,
              onPressed: model.next,
            )
          else
            AppButton(
              label: l10n.testSubmit,
              onPressed: state.placed.isEmpty ? null : model.check,
            ),
        ],
      ),
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
                Text(l10n.testPromptMeaning, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppTokens.space8),
                Text(
                  question.meaning,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppTokens.sectionGap),
        SectionTitle(l10n.assembleSlot),
        const SizedBox(height: AppTokens.sectionTitleGap),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Align(alignment: Alignment.centerLeft, child: slot),
        ),
        if (pieces) ...[
          const SizedBox(height: AppTokens.sectionGap),
          SectionTitle(l10n.assembleCards),
          const SizedBox(height: AppTokens.sectionTitleGap),
          Wrap(
            spacing: AppTokens.space8,
            runSpacing: AppTokens.space8,
            children: [
              for (final tile in question.tiles)
                if (!state.placed.contains(tile.id))
                  _TileCard(
                    key: ValueKey('tile-${tile.id}'),
                    text: tile.text,
                    onTap: revealed ? null : () => model.place(tile.id),
                  ),
            ],
          ),
          if (!revealed && state.placed.isNotEmpty) ...[
            const SizedBox(height: AppTokens.space12),
            AppButton.text(label: l10n.assembleUndo, onPressed: model.undo),
          ],
        ] else if (!revealed) ...[
          const SizedBox(height: AppTokens.space12),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.sectionTitleIndent,
            ),
            child: Text(
              l10n.assembleDragHint,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
        if (revealed) ...[
          const SizedBox(height: AppTokens.sectionGap),
          Row(
            children: [
              Icon(
                correct ? Symbols.check_circle_rounded : Symbols.cancel_rounded,
                color: correct ? colors.primary : colors.error,
                size: 22,
              ),
              const SizedBox(width: AppTokens.space8),
              Expanded(
                child: Text(
                  correct ? l10n.testCorrect : l10n.testWrong(question.word),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: correct ? colors.primary : colors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.wordbookId, required this.state});

  final int wordbookId;
  final AssemblyState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final model = ref.read(assemblyViewModelProvider(wordbookId).notifier);
    final wrong = state.wrongResults;
    final total = state.questions.length;

    return AppPage(
      title: l10n.assembleResultTitle,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
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
                          if (wrong[i].given.isNotEmpty) ...[
                            const SizedBox(height: AppTokens.space4),
                            Text(
                              l10n.testYourAnswer(wrong[i].given),
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
