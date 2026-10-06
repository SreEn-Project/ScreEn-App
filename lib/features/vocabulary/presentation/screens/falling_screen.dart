import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/falling_game.dart';
import '../view_models/falling_view_model.dart';

/// 하강형 타이핑 (L-06, AD-12): 방식 고르기 → 떨어지는 블록을 입력으로 파괴 → 결과.
class FallingScreen extends ConsumerWidget {
  const FallingScreen({super.key, required this.wordbookId});

  final int wordbookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(fallingViewModelProvider(wordbookId)).value;
    if (state == null) {
      return AppPage(title: l10n.fallTitle, children: const []);
    }
    return switch (state.phase) {
      FallingPhase.setup => _Setup(wordbookId: wordbookId, state: state),
      FallingPhase.playing => _Playing(
        wordbookId: wordbookId,
        // 새 판마다 새 상태로 시작하려고 게임 객체를 키로 쓴다.
        key: ObjectKey(state.game),
        game: state.game!,
      ),
      FallingPhase.over => _Result(wordbookId: wordbookId, state: state),
    };
  }
}

class _Setup extends ConsumerWidget {
  const _Setup({required this.wordbookId, required this.state});

  final int wordbookId;
  final FallingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final model = ref.read(fallingViewModelProvider(wordbookId).notifier);
    final count = state.book?.wordCount ?? 0;

    return AppPage(
      title: l10n.fallTitle,
      bottom: AppButton(
        label: l10n.testStart,
        onPressed: count == 0 ? null : model.start,
      ),
      children: [
        AppCard(
          child: Row(
            children: [
              const IconBadge(icon: Symbols.keyboard_rounded, size: 44),
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
                    Text(l10n.fallRules, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.sectionGap),
        SectionTitle(l10n.testMode),
        const SizedBox(height: AppTokens.sectionTitleGap),
        AppSegmented<FallingMode>(
          values: FallingMode.values,
          selected: state.mode,
          label: (m) => m == FallingMode.meaning
              ? l10n.fallModeMeaning
              : l10n.fallModeSpelling,
          onChanged: model.setMode,
        ),
        const SizedBox(height: AppTokens.space12),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.sectionTitleIndent,
          ),
          child: Text(
            state.mode == FallingMode.meaning
                ? l10n.fallModeMeaningHint
                : l10n.fallModeSpellingHint,
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

class _Playing extends ConsumerStatefulWidget {
  const _Playing({super.key, required this.wordbookId, required this.game});

  final int wordbookId;
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
  Duration _last = Duration.zero;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _input.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    // 화면이 잠깐 멈췄다 돌아올 때 블록이 한꺼번에 떨어지지 않게 한 틱을 0.1초로 제한한다.
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _last = elapsed;
    widget.game.update(dt);
    setState(() {});
    if (widget.game.over && !_finishing) {
      _finishing = true;
      _ticker.stop();
      ref.read(fallingViewModelProvider(widget.wordbookId).notifier).finish();
    }
  }

  /// 글자가 바뀔 때마다 맞는지 본다 (제출 키 없이 바로 파괴, 키보드도 안 닫힌다).
  void _onChanged(String text) {
    if (widget.game.submit(text)) {
      _input.clear();
      setState(() {});
    }
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
                  Text(
                    l10n.matchScore(game.score),
                    style: theme.textTheme.labelLarge,
                  ),
                  const Spacer(),
                  for (var i = 0; i < game.maxLives; i++)
                    Padding(
                      padding: const EdgeInsets.only(left: AppTokens.space4),
                      child: Icon(
                        Symbols.favorite_rounded,
                        fill: i < game.lives ? 1 : 0,
                        size: 22,
                        color: i < game.lives
                            ? colors.error
                            : colors.outlineVariant,
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
                    final blockWidth = (box.maxWidth / 2.2).clamp(
                      0.0,
                      _blockMaxWidth,
                    );
                    return Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 3,
                            color: colors.error.withValues(alpha: 0.4),
                          ),
                        ),
                        for (final b in game.blocks)
                          Positioned(
                            key: ValueKey(b.id),
                            left: b.lane * (box.maxWidth - blockWidth),
                            top: b.y * (box.maxHeight - _blockHeight),
                            width: blockWidth,
                            height: _blockHeight,
                            child: AppCard(
                              radius: AppTokens.radiusInput,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTokens.space8,
                              ),
                              child: Center(
                                child: Text(
                                  b.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                            ),
                          ),
                      ],
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
              child: AppTextField(
                controller: _input,
                hint: game.mode == FallingMode.meaning
                    ? l10n.fallInputMeaning
                    : l10n.fallInputSpelling,
                autofocus: true,
                onChanged: _onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Result extends ConsumerWidget {
  const _Result({required this.wordbookId, required this.state});

  final int wordbookId;
  final FallingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final model = ref.read(fallingViewModelProvider(wordbookId).notifier);
    final game = state.game!;
    final missed = game.missedWords;

    return AppPage(
      title: l10n.fallResultTitle,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(label: l10n.matchRetry, onPressed: model.start),
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
                  l10n.matchScore(game.score),
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTokens.space4),
                Text(
                  l10n.fallDestroyed(game.destroyed),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        if (missed.isNotEmpty) ...[
          const SizedBox(height: AppTokens.sectionGap),
          SectionTitle(l10n.fallMissedWords),
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
