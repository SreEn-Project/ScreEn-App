import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/line_match.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/usecases/vocabulary_usecases.dart';

part 'line_match_view_model.g.dart';

/// 선 잇기 화면(L-05)의 상태. 단어가 없으면 [game]이 null.
class LineMatchState {
  const LineMatchState({required this.bookName, this.game});

  final String bookName;
  final LineMatchGame? game;
}

/// 선 잇기 매칭 (AD-11).
@riverpod
class LineMatchViewModel extends _$LineMatchViewModel {
  @override
  Future<LineMatchState> build(int wordbookId) async {
    final books = await ref.watch(getWordbooksProvider)();
    final book = books.where((b) => b.id == wordbookId).firstOrNull;
    final game = await ref.read(createLineMatchGameProvider)(
      CreateLineMatchGameParams(wordbookId),
    );
    return LineMatchState(bookName: book?.name ?? '', game: game);
  }

  /// 단어 블록 [wordId]를 뜻 블록 [meaningOwnerId]에 이은 결과를 반영한다.
  MatchOutcome attempt(int wordId, int meaningOwnerId) {
    final current = state.value;
    final game = current?.game;
    if (current == null || game == null) return MatchOutcome.wrong;
    final (next, outcome) = game.attempt(wordId, meaningOwnerId);
    state = AsyncData(LineMatchState(bookName: current.bookName, game: next));
    unawaited(
      ref.read(recordWordAnswersProvider)([
        WordAnswer(wordId, correct: outcome == MatchOutcome.correct),
      ]),
    );
    return outcome;
  }

  /// 같은 단어장으로 새 판을 시작한다.
  Future<void> restart() async {
    final current = state.value;
    if (current == null) return;
    final game = await ref.read(createLineMatchGameProvider)(
      CreateLineMatchGameParams(wordbookId),
    );
    state = AsyncData(LineMatchState(bookName: current.bookName, game: game));
  }
}
