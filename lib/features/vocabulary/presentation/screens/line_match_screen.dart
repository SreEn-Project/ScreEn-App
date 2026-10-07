import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/line_match.dart';
import '../view_models/line_match_view_model.dart';

/// 선 잇기 매칭 (L-05, AD-11): 단어 블록에서 뜻 블록으로 드래그해 선을 잇는다.
class LineMatchScreen extends ConsumerWidget {
  const LineMatchScreen({super.key, required this.wordbookId});

  final int wordbookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(lineMatchViewModelProvider(wordbookId)).value;
    final game = state?.game;
    if (state == null || game == null) {
      return AppPage(
        title: l10n.matchTitle,
        children: [
          if (state != null)
            Padding(
              padding: const EdgeInsets.only(top: AppTokens.sectionGap),
              child: Center(
                child: Text(
                  l10n.learnTestNeedWords,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
        ],
      );
    }
    return game.finished
        ? _Result(wordbookId: wordbookId, game: game)
        : _Board(wordbookId: wordbookId, game: game);
  }
}

/// 드래그가 끝난 직후 잠깐 보여 주는 선 (맞으면 초록, 틀리면 빨강).
class _Flash {
  const _Flash({
    required this.wordId,
    required this.meaningId,
    required this.correct,
  });

  final int wordId;
  final int meaningId;
  final bool correct;
}

class _Board extends ConsumerStatefulWidget {
  const _Board({required this.wordbookId, required this.game});

  final int wordbookId;
  final LineMatchGame game;

  @override
  ConsumerState<_Board> createState() => _BoardState();
}

class _BoardState extends ConsumerState<_Board> {
  static const _blockHeight = 60.0;
  static const _rowGap = AppTokens.space12;
  static const _columnGap = 56.0;

  final _stackKey = GlobalKey();
  final _burst = GlobalKey<BurstLayerState>();
  int _shake = 0;
  final _leftKeys = <int, GlobalKey>{};
  final _rightKeys = <int, GlobalKey>{};

  int? _dragWordId;
  Offset? _dragEnd;
  _Flash? _flash;
  bool _busy = false;

  GlobalKey _key(Map<int, GlobalKey> keys, int id) =>
      keys.putIfAbsent(id, GlobalKey.new);

  /// 블록의 [_stackKey] 기준 영역. 아직 그려지지 않았으면 null.
  Rect? _rect(GlobalKey key) {
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (stack == null || box == null || !box.attached) return null;
    final origin = stack.globalToLocal(box.localToGlobal(Offset.zero));
    return origin & box.size;
  }

  int? _hit(Map<int, GlobalKey> keys, Iterable<int> ids, Offset point) {
    for (final id in ids) {
      final key = keys[id];
      final rect = key == null ? null : _rect(key);
      if (rect != null && rect.contains(point)) return id;
    }
    return null;
  }

  Offset _local(PointerEvent event) {
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    return stack?.globalToLocal(event.position) ?? event.localPosition;
  }

  void _down(PointerDownEvent event) {
    if (_busy) return;
    final id = _hit(
      _leftKeys,
      widget.game.left.map((b) => b.wordId),
      _local(event),
    );
    if (id == null) return;
    setState(() {
      _dragWordId = id;
      _dragEnd = _local(event);
    });
  }

  void _move(PointerMoveEvent event) {
    if (_dragWordId == null) return;
    setState(() => _dragEnd = _local(event));
  }

  Future<void> _up(PointerUpEvent event) async {
    final wordId = _dragWordId;
    if (wordId == null) return;
    final meaningId = _hit(
      _rightKeys,
      widget.game.right.map((b) => b.wordId),
      _local(event),
    );
    if (meaningId == null) {
      setState(() => _dragWordId = null);
      return;
    }
    final model = ref.read(
      lineMatchViewModelProvider(widget.wordbookId).notifier,
    );
    // 이어 본 결과를 먼저 알아야 선 색을 정한다 (게임은 바뀌지 않는 값이라 미리 시험해 볼 수 있다).
    final (_, outcome) = widget.game.attempt(wordId, meaningId);
    final correct = outcome == MatchOutcome.correct;
    setState(() {
      _dragWordId = null;
      _flash = _Flash(wordId: wordId, meaningId: meaningId, correct: correct);
      _busy = true;
      if (!correct) _shake++;
    });
    // 맞으면 두 블록에서 조각이 터지고, 틀리면 흔들리며 묵직하게 진동한다.
    if (correct) {
      HapticFeedback.mediumImpact();
      final color = Theme.of(context).colorScheme.primary;
      _burst.currentState
        ?..burstAt(_leftKeys[wordId]!, color: color, count: 16)
        ..burstAt(_rightKeys[meaningId]!, color: color, count: 16);
    } else {
      HapticFeedback.heavyImpact();
    }
    // 맞으면 블록이 깨지는 모습을 잠깐 보여 준 뒤 반영한다.
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    model.attempt(wordId, meaningId);
    setState(() {
      _flash = null;
      _busy = false;
    });
  }

  void _cancel(PointerCancelEvent event) {
    if (_dragWordId != null) setState(() => _dragWordId = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final game = widget.game;

    Widget block(MatchBlock b, {required GlobalKey key, required bool isWord}) {
      final active = isWord && _dragWordId == b.wordId;
      final flashing =
          _flash != null &&
          (isWord ? _flash!.wordId == b.wordId : _flash!.meaningId == b.wordId);
      final broken = flashing && _flash!.correct;
      final Color? fill = flashing
          ? (_flash!.correct ? colors.primaryContainer : colors.errorContainer)
          : active
          ? colors.primaryContainer
          : null;
      return Padding(
        key: ValueKey('${isWord ? 'w' : 'm'}${b.wordId}'),
        padding: const EdgeInsets.only(bottom: _rowGap),
        child: AnimatedScale(
          scale: broken ? 0.7 : 1,
          duration: const Duration(milliseconds: 240),
          child: AnimatedOpacity(
            opacity: broken ? 0 : 1,
            duration: const Duration(milliseconds: 240),
            child: ShakeEffect(
              trigger: flashing && !_flash!.correct ? _shake : 0,
              child: SizedBox(
                key: key,
                height: _blockHeight,
                child: AppCard(
                  color: fill,
                  radius: AppTokens.radiusInput,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.space12,
                  ),
                  child: Center(
                    child: Text(
                      b.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: isWord
                          ? theme.textTheme.titleMedium
                          : theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Offset? anchor(Map<int, GlobalKey> keys, int id, {required bool right}) {
      final key = keys[id];
      final rect = key == null ? null : _rect(key);
      if (rect == null) return null;
      return right ? rect.centerRight : rect.centerLeft;
    }

    Offset? from;
    Offset? to;
    Color lineColor = colors.primary;
    if (_flash != null) {
      from = anchor(_leftKeys, _flash!.wordId, right: true);
      to = anchor(_rightKeys, _flash!.meaningId, right: false);
      lineColor = _flash!.correct ? colors.primary : colors.error;
    } else if (_dragWordId != null) {
      from = anchor(_leftKeys, _dragWordId!, right: true);
      to = _dragEnd;
    }

    return AppPage(
      title: l10n.matchTitle,
      children: [
        Row(
          children: [
            PopEffect(
              trigger: game.score,
              child: Text(
                l10n.matchScore(game.score),
                style: theme.textTheme.titleMedium,
              ),
            ),
            const Spacer(),
            Text(
              l10n.matchRemaining(game.remaining),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppTokens.space12),
        AppProgressBar(value: game.matchedCount / game.total),
        const SizedBox(height: AppTokens.space12),
        Center(child: Text(l10n.matchHint, style: theme.textTheme.bodySmall)),
        const SizedBox(height: AppTokens.sectionTitleGap),
        // 포인터를 직접 받아 목록 스크롤과 겹치지 않게 한다.
        Listener(
          onPointerDown: _down,
          onPointerMove: _move,
          onPointerUp: _up,
          onPointerCancel: _cancel,
          // 빈 팬 제스처로 바깥 목록의 스크롤이 드래그를 가져가지 못하게 한다.
          child: GestureDetector(
            onPanUpdate: (_) {},
            child: Stack(
              key: _stackKey,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          for (final b in game.left)
                            block(
                              b,
                              key: _key(_leftKeys, b.wordId),
                              isWord: true,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: _columnGap),
                    Expanded(
                      child: Column(
                        children: [
                          for (final b in game.right)
                            block(
                              b,
                              key: _key(_rightKeys, b.wordId),
                              isWord: false,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned.fill(child: BurstLayer(key: _burst)),
                if (from != null && to != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _LinePainter(
                          from: from,
                          to: to,
                          color: lineColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter({
    required this.from,
    required this.to,
    required this.color,
  });

  final Offset from;
  final Offset to;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    canvas.drawCircle(from, 6, paint);
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.from != from || old.to != to || old.color != color;
}

class _Result extends ConsumerWidget {
  const _Result({required this.wordbookId, required this.game});

  final int wordbookId;
  final LineMatchGame game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final model = ref.read(lineMatchViewModelProvider(wordbookId).notifier);
    final missed = game.missedWords;

    return AppPage(
      title: l10n.matchResultTitle,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(label: l10n.matchRetry, onPressed: model.restart),
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
                  l10n.testScore(game.score, game.total),
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTokens.space4),
                Text(
                  missed.isEmpty
                      ? l10n.testPerfect
                      : l10n.testWrongCount(missed.length),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        if (missed.isNotEmpty) ...[
          const SizedBox(height: AppTokens.sectionGap),
          SectionTitle(l10n.testWrongWords),
          const SizedBox(height: AppTokens.sectionTitleGap),
          AppCard(
            padding: const EdgeInsets.symmetric(
              vertical: AppTokens.cardListPaddingV,
            ),
            child: Column(
              children: [
                for (var i = 0; i < missed.length; i++) ...[
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
                            missed[i].word,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppTokens.space4),
                          Text(
                            missed[i].meaning,
                            style: theme.textTheme.bodyMedium,
                          ),
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
