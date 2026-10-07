import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/word_assembly.dart';
import '../../domain/usecases/vocabulary_usecases.dart';
import '../view_models/assembly_view_model.dart';
import '../widgets/study_widgets.dart';

/// 단어 조립 (L-07, AD-13): 뜻을 보고 조각 · 글자 카드를 끌어 넣어(또는 눌러서) 단어를 완성한다.
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
        StudySetupHeader(
          icon: Symbols.extension_rounded,
          title: state.book?.name ?? '',
          subtitle: l10n.testQuestionCount(questionCount),
        ),
        const SizedBox(height: AppTokens.sectionGap),
        StudyModeCard<AssemblyMode>(
          values: AssemblyMode.values,
          selected: state.mode,
          label: (m) => m == AssemblyMode.pieces
              ? l10n.assembleModePieces
              : l10n.assembleModeLetters,
          hint: state.mode == AssemblyMode.pieces
              ? l10n.assembleModePiecesHint
              : l10n.assembleModeLettersHint,
          onChanged: model.setMode,
          notes: [
            if (state.failedToStart)
              StudyNote(l10n.testCannotStart, error: true),
          ],
        ),
      ],
    );
  }
}

/// 끌어 놓을 카드 하나. [fromSlot]이면 이미 완성 칸에 있던 카드.
class _DragTile {
  const _DragTile(this.id, {required this.fromSlot});

  final int id;
  final bool fromSlot;
}

/// 카드 한 장 (모양만).
class _TileCard extends StatelessWidget {
  const _TileCard({
    required this.text,
    this.color,
    this.minWidth = 48,
    this.lifted = false,
  });

  final String text;
  final Color? color;
  final double minWidth;

  /// 끄는 중 손가락 위에 뜬 모양.
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppCard(
      color: color ?? (lifted ? colors.primaryContainer : null),
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

/// 끌 수 있고 누를 수도 있는 카드.
class _DraggableTile extends StatelessWidget {
  const _DraggableTile({
    super.key,
    required this.data,
    required this.text,
    required this.onTap,
    this.color,
    this.minWidth = 48,
    this.enabled = true,
  });

  final _DragTile data;
  final String text;
  final VoidCallback? onTap;
  final Color? color;
  final double minWidth;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final card = _TileCard(text: text, color: color, minWidth: minWidth);
    if (!enabled) return card;
    return Draggable<_DragTile>(
      data: data,
      maxSimultaneousDrags: 1,
      onDragStarted: HapticFeedback.selectionClick,
      // 손가락에 가리지 않게 카드를 손가락 위쪽에 띄운다.
      dragAnchorStrategy: (draggable, ctx, position) => const Offset(28, 64),
      feedback: Material(
        type: MaterialType.transparency,
        child: Transform.scale(
          scale: 1.12,
          child: _TileCard(text: text, minWidth: minWidth, lifted: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: card),
      child: Pressable(onTap: onTap, scale: 0.94, child: card),
    );
  }
}

class _Running extends ConsumerStatefulWidget {
  const _Running({required this.wordbookId, required this.state});

  final int wordbookId;
  final AssemblyState state;

  @override
  ConsumerState<_Running> createState() => _RunningState();
}

class _RunningState extends ConsumerState<_Running> {
  final _slotScroll = ScrollController();
  final _burst = GlobalKey<BurstLayerState>();
  final _slotKey = GlobalKey();
  int _shake = 0;

  /// 글자 정렬형에서 눌러 고른 카드 (다음에 누른 자리로 옮긴다).
  int? _selected;

  @override
  void dispose() {
    _slotScroll.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_Running old) {
    super.didUpdateWidget(old);
    final s = widget.state;
    if (!old.state.revealed && s.revealed) {
      // 확인한 순간: 맞으면 조각이 터지고, 틀리면 흔들린다.
      if (s.lastResult?.correct ?? false) {
        HapticFeedback.mediumImpact();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _burst.currentState?.burstAt(
            _slotKey,
            color: Theme.of(context).colorScheme.primary,
            count: 30,
            spread: 1.3,
          );
        });
      } else {
        HapticFeedback.heavyImpact();
        _shake++;
      }
    }
  }

  AssemblyViewModel get _model =>
      ref.read(assemblyViewModelProvider(widget.wordbookId).notifier);

  /// 카드를 [at] 자리에 끼운다 (없으면 끝).
  void _drop(_DragTile drag, {int? at}) {
    HapticFeedback.lightImpact();
    _selected = null;
    _model.place(drag.id, at: at);
  }

  /// 글자 정렬형: 한 장을 누르고 다른 장을 누르면 그 자리로 옮긴다.
  void _tapLetter(int id, int index) {
    HapticFeedback.selectionClick();
    final from = _selected;
    setState(() => _selected = from == id ? null : (from == null ? id : null));
    if (from != null && from != id) _model.place(from, at: index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = widget.state;
    final model = _model;
    final question = state.current;
    if (question == null) {
      return AppPage(title: l10n.assembleTitle, children: const []);
    }
    final revealed = state.revealed;
    final correct = state.lastResult?.correct ?? false;
    final isLast = state.index + 1 >= state.questions.length;
    final letters = question.mode == AssemblyMode.letters;
    final slotColor = !revealed
        ? null
        : correct
        ? colors.primaryContainer
        : colors.errorContainer;

    Widget placedChip(int i) {
      final id = state.placed[i];
      return DragTarget<_DragTile>(
        key: ValueKey('placed-$id'),
        onWillAcceptWithDetails: (d) => !revealed && d.data.id != id,
        onAcceptWithDetails: (d) => _drop(d.data, at: i),
        builder: (context, candidates, _) => AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          // 끌어 온 카드가 이 앞에 들어갈 자리를 벌려 보여 준다.
          padding: EdgeInsets.only(
            left: candidates.isEmpty ? 0 : 28,
            right: AppTokens.space8,
          ),
          child: _DraggableTile(
            data: _DragTile(id, fromSlot: true),
            text: question.tile(id).text,
            color:
                slotColor ?? (_selected == id ? colors.primaryContainer : null),
            minWidth: letters ? 44 : 48,
            enabled: !revealed,
            onTap: revealed
                ? null
                : letters
                ? () => _tapLetter(id, i)
                : () => model.remove(id),
          ),
        ),
      );
    }

    // 완성 칸: 한 줄로 늘어놓고 넘치면 옆으로 민다 (아래 스크롤 막대로도 이동).
    final slot = ShakeEffect(
      trigger: _shake,
      child: DragTarget<_DragTile>(
        onWillAcceptWithDetails: (_) => !revealed,
        // 글자 정렬형에서 칸 빈 곳에 놓으면 맨 뒤로 보낸다.
        onAcceptWithDetails: (d) =>
            _drop(d.data, at: letters ? state.placed.length : null),
        builder: (context, candidates, _) => AnimatedContainer(
          key: _slotKey,
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(AppTokens.space12),
          decoration: BoxDecoration(
            color: candidates.isEmpty
                ? colors.surface
                : colors.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
            border: Border.all(
              color: candidates.isEmpty
                  ? colors.outlineVariant.withValues(alpha: 0.6)
                  : colors.primary,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                controller: _slotScroll,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Row(
                    children: [
                      for (var i = 0; i < state.placed.length; i++)
                        placedChip(i),
                      if (state.placed.isEmpty && !letters)
                        Text(
                          l10n.assembleSlotHint,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
              AppScrollBar(controller: _slotScroll),
            ],
          ),
        ),
      ),
    );

    // 카드 더미: 눌러서 채우거나 끌어서 넣는다. 완성 칸의 카드를 여기로 끌어오면 빠진다.
    final pool = DragTarget<_DragTile>(
      onWillAcceptWithDetails: (d) => !revealed && d.data.fromSlot,
      onAcceptWithDetails: (d) {
        HapticFeedback.selectionClick();
        model.remove(d.data.id);
      },
      builder: (context, candidates, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.all(AppTokens.space12),
        decoration: BoxDecoration(
          color: candidates.isEmpty
              ? Colors.transparent
              : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
        child: Wrap(
          spacing: AppTokens.space8,
          runSpacing: AppTokens.space8,
          children: [
            for (final tile in question.tiles)
              if (!state.placed.contains(tile.id))
                _DraggableTile(
                  key: ValueKey('tile-${tile.id}'),
                  data: _DragTile(tile.id, fromSlot: false),
                  text: tile.text,
                  enabled: !revealed,
                  onTap: revealed
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          model.place(tile.id);
                        },
                ),
          ],
        ),
      ),
    );

    return Stack(
      children: [
        AppPage(
          title: l10n.assembleTitle,
          bottom: revealed
              ? AppButton(
                  label: isLast ? l10n.testSeeResult : l10n.testNext,
                  onPressed: model.next,
                )
              : AppButton(
                  label: l10n.testSubmit,
                  onPressed: state.placed.isEmpty ? null : model.check,
                ),
          children: [
            StudyProgress(
              index: state.index,
              total: state.questions.length,
              correct: state.correctCount,
              revealed: revealed,
            ),
            const SizedBox(height: AppTokens.sectionGap),
            StudyPrompt(label: l10n.testPromptMeaning, text: question.meaning),
            const SizedBox(height: AppTokens.sectionGap),
            SectionTitle(letters ? l10n.assembleSortTitle : l10n.assembleSlot),
            const SizedBox(height: AppTokens.sectionTitleGap),
            slot,
            if (!letters) ...[
              const SizedBox(height: AppTokens.sectionGap),
              SectionTitle(l10n.assembleCards),
              const SizedBox(height: AppTokens.sectionTitleGap),
              pool,
            ],
            if (!revealed) ...[
              const SizedBox(height: AppTokens.space8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.sectionTitleIndent,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        letters ? l10n.assembleSortHint : l10n.assembleDragHint,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    if (!letters && state.placed.isNotEmpty)
                      AppButton.text(
                        label: l10n.assembleUndo,
                        onPressed: model.undo,
                      ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: AppTokens.sectionGap),
              StudyFeedback(correct: correct, expected: question.word),
            ],
          ],
        ),
        Positioned.fill(child: BurstLayer(key: _burst)),
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
