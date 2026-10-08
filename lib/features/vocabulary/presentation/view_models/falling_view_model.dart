import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/falling_game.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/usecases/vocabulary_usecases.dart';

part 'falling_view_model.g.dart';

enum FallingPhase { setup, playing, over }

/// 하강형 타이핑 화면(L-06)의 상태. 진행 중인 [game]은 화면의 시계가 직접 굴린다.
class FallingState {
  const FallingState({
    required this.book,
    this.phase = FallingPhase.setup,
    this.mode = FallingMode.meaning,
    this.difficulty = FallingDifficulty.normal,
    this.timeLimit = 0,
    this.game,
    this.failedToStart = false,
  });

  final Wordbook? book;
  final FallingPhase phase;
  final FallingMode mode;
  final FallingDifficulty difficulty;

  /// 제한 시간(초), 0이면 없음.
  final int timeLimit;
  final FallingGame? game;
  final bool failedToStart;

  FallingState copyWith({
    FallingPhase? phase,
    FallingMode? mode,
    FallingDifficulty? difficulty,
    int? timeLimit,
    FallingGame? game,
    bool? failedToStart,
  }) => FallingState(
    book: book,
    phase: phase ?? this.phase,
    mode: mode ?? this.mode,
    difficulty: difficulty ?? this.difficulty,
    timeLimit: timeLimit ?? this.timeLimit,
    game: game ?? this.game,
    failedToStart: failedToStart ?? this.failedToStart,
  );
}

/// 하강형 타이핑 (AD-12): 방식 고르기 → 게임 → 결과.
@riverpod
class FallingViewModel extends _$FallingViewModel {
  @override
  Future<FallingState> build(int wordbookId) async {
    final books = await ref.watch(getWordbooksProvider)();
    return FallingState(
      book: books.where((b) => b.id == wordbookId).firstOrNull,
    );
  }

  void setMode(FallingMode mode) {
    final current = state.value;
    if (current == null || current.phase != FallingPhase.setup) return;
    state = AsyncData(current.copyWith(mode: mode));
  }

  void setDifficulty(FallingDifficulty difficulty) {
    final current = state.value;
    if (current == null || current.phase != FallingPhase.setup) return;
    state = AsyncData(current.copyWith(difficulty: difficulty));
  }

  void setTimeLimit(int seconds) {
    final current = state.value;
    if (current == null || current.phase != FallingPhase.setup) return;
    state = AsyncData(current.copyWith(timeLimit: seconds));
  }

  Future<void> start() async {
    final current = state.value;
    if (current == null) return;
    final game = await ref.read(createFallingGameProvider)(
      CreateFallingGameParams(
        wordbookId,
        current.mode,
        difficulty: current.difficulty,
        timeLimit: current.timeLimit,
      ),
    );
    state = AsyncData(
      game == null
          ? current.copyWith(failedToStart: true)
          : current.copyWith(
              phase: FallingPhase.playing,
              game: game,
              failedToStart: false,
            ),
    );
  }

  /// 목숨이 다 떨어졌다. 결과로 넘어간다.
  void finish() {
    final current = state.value;
    if (current == null || current.phase != FallingPhase.playing) return;
    state = AsyncData(current.copyWith(phase: FallingPhase.over));
  }
}
