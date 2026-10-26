import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/falling_game.dart';
import '../../domain/entities/vocabulary.dart';
import '../view_models/falling_view_model.dart';
import '../widgets/study_widgets.dart';

/// 하강형 타이핑 (L-06, AD-12): 방식 고르기 → 떨어지는 블록을 입력으로 파괴 → 결과.
class FallingScreen extends ConsumerWidget {
  const FallingScreen({super.key, required this.selection});

  final WordbookSelection selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(fallingViewModelProvider(selection)).value;
    if (state == null) {
      return AppPage(title: l10n.fallTitle, children: const []);
    }
    return switch (state.phase) {
      FallingPhase.setup => _Setup(selection: selection, state: state),
      FallingPhase.playing => _Playing(
        selection: selection,
        // 새 판마다 새 상태로 시작하려고 게임 객체를 키로 쓴다.
        key: ObjectKey(state.game),
        game: state.game!,
      ),
      FallingPhase.over => _Result(selection: selection, state: state),
    };
  }
}

class _Setup extends ConsumerWidget {
  const _Setup({required this.selection, required this.state});

  final WordbookSelection selection;
  final FallingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final model = ref.read(fallingViewModelProvider(selection).notifier);
    final count = state.book?.wordCount ?? 0;

    return AppPage(
      title: l10n.fallTitle,
      bottom: AppButton(
        label: l10n.testStart,
        onPressed: count == 0 ? null : model.start,
      ),
      children: [
        StudySetupHeader(
          icon: Symbols.keyboard_rounded,
          title: state.book?.name ?? '',
          subtitle: l10n.fallRules,
        ),
        const SizedBox(height: AppTokens.sectionGap),
        StudyModeCard<FallingMode>(
          values: FallingMode.values,
          selected: state.mode,
          label: (m) => m == FallingMode.meaning
              ? l10n.fallModeMeaning
              : l10n.fallModeSpelling,
          hint: state.mode == FallingMode.meaning
              ? l10n.fallModeMeaningHint
              : l10n.fallModeSpellingHint,
          onChanged: model.setMode,
          notes: [
            if (state.failedToStart)
              StudyNote(l10n.testCannotStart, error: true),
          ],
        ),
        const SizedBox(height: AppTokens.sectionGap),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.fallSpeed,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const Spacer(),
                  Text(
                    l10n.fallSpeedValue(state.speedScale.toStringAsFixed(1)),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space8),
              AppSlider(
                value: state.speedScale,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                onChanged: model.setSpeed,
              ),
              Row(
                children: [
                  Text(
                    l10n.fallSlow,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    l10n.fallFast,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Playing extends ConsumerStatefulWidget {
  const _Playing({super.key, required this.selection, required this.game});

  final WordbookSelection selection;
  final FallingGame game;

  @override
  ConsumerState<_Playing> createState() => _PlayingState();
}

class _PlayingState extends ConsumerState<_Playing>
    with SingleTickerProviderStateMixin {
  static const _blockHeight = 48.0;
  static const _blockMaxWidth = 150.0;

  late final Ticker _ticker;
  final _input = TextEditingController();
  final _burst = GlobalKey<BurstLayerState>();
  Duration _last = Duration.zero;
  bool _finishing = false;
  Size _area = Size.zero;
  int _shake = 0;
  int _lives = 0;
  int _wrong = 0;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _lives = widget.game.lives;
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    // 화면이 잠깐 멈췄다 돌아올 때 블록이 한꺼번에 떨어지지 않게 한 틱을 0.1초로 제한한다.
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _last = elapsed;
    widget.game.update(dt);
    // 바닥에 떨어진 블록은 붉은 조각으로 깨지고 화면이 흔들린다.
    for (final b in widget.game.landedNow) {
      _burstBlock(b, Theme.of(context).colorScheme.error, count: 14);
    }
    if (widget.game.lives != _lives) {
      _lives = widget.game.lives;
      _shake++;
      HapticFeedback.heavyImpact();
    }
    setState(() {});
    if (widget.game.over && !_finishing) {
      _finishing = true;
      _ticker.stop();
      ref.read(fallingViewModelProvider(widget.selection).notifier).finish();
    }
  }

  /// 블록이 있던 자리에서 [color] 조각을 터뜨린다.
  void _burstBlock(FallingBlock b, Color color, {int count = 22}) {
    if (_area.isEmpty) return;
    final width = (_area.width / 2.2).clamp(0.0, _blockMaxWidth);
    final center = Offset(
      b.lane * (_area.width - width) + width / 2,
      b.y.clamp(0.0, 1.0) * (_area.height - _blockHeight) + _blockHeight / 2,
    );
    _burst.currentState?.burst(center, color: color, count: count);
  }

  /// 글자가 바뀔 때마다 맞는지 본다 (맞으면 바로 파괴).
  void _onChanged(String text) => _submit(text, explicit: false);

  /// 전송 버튼 · 엔터로도 낸다. 직접 낸 오답은 입력창과 화면이 흔들린다.
  void _submit(String text, {required bool explicit}) {
    if (text.trim().isEmpty) {
      if (explicit) _focus.requestFocus();
      return;
    }
    if (!widget.game.submit(text)) {
      if (explicit) {
        HapticFeedback.heavyImpact();
        setState(() {
          _wrong++;
          _shake++;
        });
        _focus.requestFocus();
      }
      return;
    }
    _input.clear();
    final hit = widget.game.lastDestroyed;
    if (hit != null) {
      _burstBlock(
        hit,
        Theme.of(context).colorScheme.primary,
        count: 18 + widget.game.combo.clamp(0, 10) * 3,
      );
    }
    HapticFeedback.lightImpact();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final game = widget.game;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: l10n.fallTitle),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.pagePadding,
              ),
              child: Row(
                children: [
                  PopEffect(
                    trigger: game.score,
                    child: Text(
                      l10n.matchScore(game.score),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: AppTokens.space12),
                  if (game.combo >= 2)
                    PopEffect(
                      trigger: game.combo,
                      scale: 1.5,
                      child: AppBadge(label: l10n.fallCombo(game.combo)),
                    ),
                  const Spacer(),
                  for (var i = 0; i < game.maxLives; i++)
                    Padding(
                      padding: const EdgeInsets.only(left: AppTokens.space4),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        scale: i < game.lives ? 1 : 0.8,
                        child: Icon(
                          Symbols.favorite_rounded,
                          fill: i < game.lives ? 1 : 0,
                          size: 22,
                          color: i < game.lives
                              ? colors.error
                              : colors.outlineVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.pagePadding,
                ),
                child: LayoutBuilder(
                  builder: (context, box) {
                    _area = Size(box.maxWidth, box.maxHeight);
                    final blockWidth = (box.maxWidth / 2.2).clamp(
                      0.0,
                      _blockMaxWidth,
                    );
                    return ShakeEffect(
                      trigger: _shake,
                      amplitude: 8,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          // 목숨을 잃으면 바닥이 붉게 번쩍인다.
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: TweenAnimationBuilder<double>(
                              key: ValueKey(_shake),
                              tween: Tween(begin: 1, end: 0),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, t, _) => Container(
                                height: 3 + 22 * t,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      colors.error.withValues(
                                        alpha: 0.4 + 0.4 * t,
                                      ),
                                      colors.error.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          for (final b in game.blocks)
                            Positioned(
                              key: ValueKey(b.id),
                              left: b.lane * (box.maxWidth - blockWidth),
                              top: b.y * (box.maxHeight - _blockHeight),
                              width: blockWidth,
                              height: _blockHeight,
                              child: _BlockCard(
                                text: b.text,
                                // 바닥에 가까워질수록 붉게 달아오른다.
                                danger: ((b.y - 0.6) / 0.35).clamp(0.0, 1.0),
                              ),
                            ),
                          Positioned.fill(child: BurstLayer(key: _burst)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.pagePadding,
                AppTokens.space8,
                AppTokens.pagePadding,
                AppTokens.space16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ShakeEffect(
                      trigger: _wrong,
                      child: AppTextField(
                        controller: _input,
                        focusNode: _focus,
                        textInputAction: TextInputAction.send,
                        hint: game.mode == FallingMode.meaning
                            ? l10n.fallInputMeaning
                            : l10n.fallInputSpelling,
                        autofocus: true,
                        onChanged: _onChanged,
                        onSubmitted: (t) => _submit(t, explicit: true),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTokens.space8),
                  AppIconButton(
                    icon: Symbols.send_rounded,
                    tooltip: l10n.fallSend,
                    filled: true,
                    onPressed: () => _submit(_input.text, explicit: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 떨어지는 블록 하나. 나타날 때 커지며 등장하고, 바닥에 가까우면 붉어진다.
class _BlockCard extends StatelessWidget {
  const _BlockCard({required this.text, required this.danger});

  final String text;
  final double danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.6 + 0.4 * t, child: child),
      ),
      child: AppCard(
        radius: AppTokens.radiusInput,
        color: Color.alphaBlend(
          colors.error.withValues(alpha: 0.22 * danger),
          colors.surface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.space8),
        child: Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Color.lerp(colors.onSurface, colors.error, danger * 0.8),
            ),
          ),
        ),
      ),
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.selection, required this.state});

  final WordbookSelection selection;
  final FallingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final model = ref.read(fallingViewModelProvider(selection).notifier);
    final game = state.game!;

    return StudyResultPage(
      title: l10n.fallResultTitle,
      actions: [
        AppButton(label: l10n.matchRetry, onPressed: model.start),
        AppButton.secondary(
          label: l10n.testDone,
          onPressed: () => context.pop(),
        ),
      ],
      hero: StudyResultHero(
        score: l10n.matchScore(game.score),
        caption: l10n.fallDestroyed(game.destroyed),
        celebrate: game.destroyed >= 5,
      ),
      listTitle: l10n.fallMissedWords,
      words: [
        for (final w in game.missedWords)
          StudyWrongWord(word: w.word, meaning: w.meaning),
      ],
    );
  }
}
