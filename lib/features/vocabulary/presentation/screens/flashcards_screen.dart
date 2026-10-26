import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/vocabulary.dart';
import '../view_models/flashcards_view_model.dart';
import '../widgets/study_widgets.dart';

/// 카드 학습 (L-02, AD-08): 카드를 탭해 뒤집고, 좌우로 밀어 외움 · 못 외움을 기록한다.
class FlashcardsScreen extends ConsumerWidget {
  const FlashcardsScreen({super.key, required this.selection});

  final WordbookSelection selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(flashcardsViewModelProvider(selection)).value;
    if (state == null) {
      return AppPage(title: l10n.cardsTitle, children: const []);
    }
    return state.finished
        ? _Result(selection: selection, state: state)
        : _Deck(selection: selection, state: state);
  }
}

class _Deck extends ConsumerStatefulWidget {
  const _Deck({required this.selection, required this.state});

  final WordbookSelection selection;
  final FlashcardsState state;

  @override
  ConsumerState<_Deck> createState() => _DeckState();
}

class _DeckState extends ConsumerState<_Deck> {
  var _cardKey = GlobalKey<_SwipeCardState>();
  var _cardIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = widget.state;
    final model = ref.read(
      flashcardsViewModelProvider(widget.selection).notifier,
    );
    final word = state.current;
    // 카드마다 새 상태(뒤집힘 · 드래그 위치 초기화)로 시작한다.
    if (state.doneCount != _cardIndex) {
      _cardIndex = state.doneCount;
      _cardKey = GlobalKey<_SwipeCardState>();
    }

    return AppPage(
      title: l10n.cardsTitle,
      bottom: word == null
          ? null
          : Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: l10n.cardsUnknown,
                    onPressed: () => _cardKey.currentState?.fling(false),
                  ),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: AppButton(
                    label: l10n.cardsKnown,
                    onPressed: () => _cardKey.currentState?.fling(true),
                  ),
                ),
              ],
            ),
      children: [
        if (word == null)
          Padding(
            padding: const EdgeInsets.only(top: AppTokens.sectionGap),
            child: Column(
              children: [
                const IconBadge(icon: Symbols.style_rounded, size: 48),
                const SizedBox(height: AppTokens.space12),
                Text(
                  l10n.learnTestNeedWords,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          )
        else ...[
          Row(
            children: [
              Text(
                l10n.cardsProgress(state.doneCount + 1, state.deck.length),
                style: theme.textTheme.labelLarge,
              ),
              const Spacer(),
              Text(
                '${l10n.cardsUnknownCount(state.unknown.length)} · '
                '${l10n.cardsKnownCount(state.known.length)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space8),
          AppProgressBar(value: state.doneCount / state.deck.length),
          // 남은 공간의 세로 가운데에 카드와 안내를 둔다.
          SizedBox(
            height: (MediaQuery.sizeOf(context).height - 320).clamp(
              360.0,
              760.0,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SwipeCard(
                    key: _cardKey,
                    word: word,
                    onSwiped: (known) => model.mark(memorized: known),
                  ),
                  const SizedBox(height: AppTokens.sectionGap),
                  Text(
                    l10n.cardsSwipeHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 탭하면 뒤집히고, 좌우로 밀면 넘어가는 카드 한 장.
class _SwipeCard extends StatefulWidget {
  const _SwipeCard({super.key, required this.word, required this.onSwiped});

  final VocabularyWord word;

  /// true = 오른쪽(외움), false = 왼쪽(못 외움).
  final ValueChanged<bool> onSwiped;

  @override
  State<_SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<_SwipeCard> with TickerProviderStateMixin {
  static const _commitFraction = 0.3;
  static const _flingVelocity = 700.0;

  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final AnimationController _out = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  double _dx = 0;
  bool _leaving = false;

  @override
  void dispose() {
    _flip.dispose();
    _out.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_leaving) return;
    _flip.isCompleted || _flip.velocity > 0 ? _flip.reverse() : _flip.forward();
  }

  /// 카드를 [known] 쪽으로 날려 보내고 끝나면 알린다. 버튼 · 스와이프 둘 다 이걸 쓴다.
  Future<void> fling(bool known) async {
    if (_leaving) return;
    _leaving = true;
    final width = MediaQuery.sizeOf(context).width;
    final from = _dx;
    final to = (known ? 1 : -1) * width * 1.2;
    _out.addListener(() {
      setState(
        () => _dx = from + (to - from) * Curves.easeIn.transform(_out.value),
      );
    });
    await _out.forward();
    if (mounted) widget.onSwiped(known);
  }

  void _onDragEnd(DragEndDetails details, double width) {
    final velocity = details.primaryVelocity ?? 0;
    if (_dx.abs() > width * _commitFraction ||
        velocity.abs() > _flingVelocity) {
      final known = velocity.abs() > _flingVelocity ? velocity > 0 : _dx > 0;
      fling(known);
    } else {
      setState(() => _dx = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    // 화면 높이의 절반 이상을 카드가 차지한다.
    final cardHeight = (MediaQuery.sizeOf(context).height * 0.46).clamp(
      300.0,
      560.0,
    );
    final tilt = (_dx / width) * 0.35;
    final progress = (_dx.abs() / (width * _commitFraction)).clamp(0.0, 1.0);
    final known = _dx > 0;

    return GestureDetector(
      onTap: _toggleFlip,
      onHorizontalDragUpdate: _leaving
          ? null
          : (d) => setState(() => _dx += d.delta.dx),
      onHorizontalDragEnd: _leaving ? null : (d) => _onDragEnd(d, width),
      child: Transform.translate(
        offset: Offset(_dx, 0),
        child: Transform.rotate(
          angle: tilt,
          child: SizedBox(
            height: cardHeight,
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _flip,
                  builder: (context, _) {
                    final angle = _flip.value * math.pi;
                    final showBack = angle > math.pi / 2;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: Transform(
                        // 뒷면은 거울상으로 보이지 않게 한 번 더 뒤집는다.
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(showBack ? math.pi : 0),
                        child: _Face(word: widget.word, back: showBack),
                      ),
                    );
                  },
                ),
                if (progress > 0.05)
                  Positioned(
                    top: AppTokens.space16,
                    left: known ? AppTokens.space16 : null,
                    right: known ? null : AppTokens.space16,
                    child: Opacity(
                      opacity: progress,
                      child: _SwipeTag(
                        label: known ? l10n.cardsKnown : l10n.cardsUnknown,
                        color: known ? colors.primary : colors.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 카드 앞면(단어) · 뒷면(뜻과 부가 정보).
class _Face extends StatelessWidget {
  const _Face({required this.word, required this.back});

  final VocabularyWord word;
  final bool back;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final extra = [
      if (word.pronunciation?.isNotEmpty ?? false) word.pronunciation!,
      if (word.partOfSpeech?.isNotEmpty ?? false) word.partOfSpeech!,
    ].join(' · ');

    return AppCard(
      color: back ? colors.primaryContainer : null,
      padding: const EdgeInsets.all(AppTokens.pagePadding),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              back ? word.meaning : word.word,
              textAlign: TextAlign.center,
              style: back
                  ? theme.textTheme.headlineMedium
                  : theme.textTheme.displaySmall,
            ),
            if (back && extra.isNotEmpty) ...[
              const SizedBox(height: AppTokens.space8),
              Text(extra, style: theme.textTheme.bodyMedium),
            ],
            if (back && (word.contextMeaning?.isNotEmpty ?? false)) ...[
              const SizedBox(height: AppTokens.space12),
              Text(
                word.contextMeaning!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (!back) ...[
              const SizedBox(height: AppTokens.space16),
              Text(l10n.cardsFlipHint, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.selection, required this.state});

  final WordbookSelection selection;
  final FlashcardsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final model = ref.read(flashcardsViewModelProvider(selection).notifier);
    final unknown = state.unknown;

    return StudyResultPage(
      title: l10n.cardsResultTitle,
      actions: [
        if (unknown.isNotEmpty) ...[
          AppButton(
            label: l10n.cardsReviewUnknown,
            onPressed: model.reviewUnknown,
          ),
          AppButton.secondary(
            label: l10n.cardsRestart,
            onPressed: model.restart,
          ),
        ] else
          AppButton(label: l10n.cardsRestart, onPressed: model.restart),
        AppButton.text(
          label: l10n.cardsDone,
          expand: true,
          onPressed: () => context.pop(),
        ),
      ],
      hero: AppCard(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const IconBadge(icon: Symbols.emoji_events_rounded, size: 56),
              const SizedBox(height: AppTokens.space16),
              Text(
                unknown.isEmpty
                    ? l10n.cardsAllKnown
                    : l10n.cardsResultSummary(
                        state.known.length,
                        unknown.length,
                      ),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
      listTitle: l10n.cardsUnknownWords,
      words: [
        for (final w in unknown)
          StudyWrongWord(word: w.word, meaning: w.meaning),
      ],
    );
  }
}

/// 스와이프 중 카드 모서리에 뜨는 "외웠어요" · "못 외웠어요" 표시.
class _SwipeTag extends StatelessWidget {
  const _SwipeTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space12,
        vertical: AppTokens.space4,
      ),
      decoration: ShapeDecoration(
        shape: StadiumBorder(side: BorderSide(color: color, width: 2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
      ),
    );
  }
}
