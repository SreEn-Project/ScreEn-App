import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/entities/word_assembly.dart';
import '../../domain/usecases/vocabulary_usecases.dart';

part 'assembly_view_model.g.dart';

enum AssemblyPhase { setup, running, finished }

/// 단어 조립 화면(L-07)의 상태.
class AssemblyState {
  const AssemblyState({
    required this.book,
    this.phase = AssemblyPhase.setup,
    this.mode = AssemblyMode.pieces,
    this.questions = const [],
    this.results = const [],
    this.placed = const [],
    this.revealed = false,
    this.failedToStart = false,
  });

  final Wordbook? book;
  final AssemblyPhase phase;
  final AssemblyMode mode;
  final List<AssemblyQuestion> questions;

  /// 지금까지 푼 결과.
  final List<AssemblyResult> results;

  /// 지금 문제에서 완성 칸에 놓인 카드 번호 (순서대로). 글자 정렬형은 처음부터 모든 카드가 들어 있다.
  final List<int> placed;

  /// 방금 확인한 결과를 보여 주는 중 (다음 버튼을 기다린다).
  final bool revealed;
  final bool failedToStart;

  int get index => revealed ? results.length - 1 : results.length;

  AssemblyQuestion? get current =>
      phase == AssemblyPhase.running && index < questions.length
      ? questions[index]
      : null;

  AssemblyResult? get lastResult => revealed ? results.last : null;

  int get correctCount => results.where((r) => r.correct).length;

  List<AssemblyResult> get wrongResults => [
    for (final r in results)
      if (!r.correct) r,
  ];

  AssemblyState copyWith({
    AssemblyPhase? phase,
    AssemblyMode? mode,
    List<AssemblyQuestion>? questions,
    List<AssemblyResult>? results,
    List<int>? placed,
    bool? revealed,
    bool? failedToStart,
  }) => AssemblyState(
    book: book,
    phase: phase ?? this.phase,
    mode: mode ?? this.mode,
    questions: questions ?? this.questions,
    results: results ?? this.results,
    placed: placed ?? this.placed,
    revealed: revealed ?? this.revealed,
    failedToStart: failedToStart ?? this.failedToStart,
  );
}

/// 단어 조립 (AD-13): 방식 고르기 → 한 문제씩 조립하고 확인 → 점수와 틀린 단어.
@riverpod
class AssemblyViewModel extends _$AssemblyViewModel {
  @override
  Future<AssemblyState> build(int wordbookId) async {
    final books = await ref.watch(getWordbooksProvider)();
    return AssemblyState(
      book: books.where((b) => b.id == wordbookId).firstOrNull,
    );
  }

  void setMode(AssemblyMode mode) {
    final current = state.value;
    if (current == null || current.phase != AssemblyPhase.setup) return;
    state = AsyncData(current.copyWith(mode: mode, failedToStart: false));
  }

  /// 글자 정렬형은 섞인 글자가 처음부터 한 줄에 놓여 있고, 조각 고르기는 빈 칸에서 시작한다.
  List<int> _initialPlaced(AssemblyQuestion question) =>
      question.mode == AssemblyMode.letters
      ? [for (final t in question.tiles) t.id]
      : const [];

  Future<void> start() async {
    final current = state.value;
    if (current == null) return;
    final questions = await ref.read(createAssemblyGameProvider)(
      CreateAssemblyGameParams(wordbookId, current.mode),
    );
    state = AsyncData(
      questions.isEmpty
          ? current.copyWith(failedToStart: true)
          : current.copyWith(
              phase: AssemblyPhase.running,
              questions: questions,
              results: const [],
              placed: _initialPlaced(questions.first),
              revealed: false,
              failedToStart: false,
            ),
    );
  }

  /// 카드를 완성 칸에 놓는다. [at]이 있으면 그 자리에 끼우고, 없으면 끝에 붙인다.
  /// 이미 놓인 카드면 그 자리로 옮긴다 (끌어서 순서 바꾸기).
  void place(int tileId, {int? at}) {
    final current = state.value;
    final question = current?.current;
    if (current == null || question == null || current.revealed) return;
    if (!question.tiles.any((t) => t.id == tileId)) return;
    final list = [...current.placed];
    final already = list.contains(tileId);
    if (already && at == null) return;
    var index = at ?? list.length;
    if (already) {
      final from = list.indexOf(tileId);
      list.removeAt(from);
      if (from < index) index--;
    }
    list.insert(index.clamp(0, list.length), tileId);
    state = AsyncData(current.copyWith(placed: list));
  }

  /// 놓인 카드를 다시 뺀다.
  void remove(int tileId) {
    final current = state.value;
    if (current == null || current.revealed) return;
    // 글자 정렬형은 카드를 빼지 않고 자리만 바꾼다.
    if (current.current?.mode == AssemblyMode.letters) return;
    state = AsyncData(
      current.copyWith(placed: [...current.placed]..remove(tileId)),
    );
  }

  /// 마지막으로 놓은 카드를 뺀다.
  void undo() {
    final current = state.value;
    if (current == null || current.placed.isEmpty) return;
    remove(current.placed.last);
  }

  /// 지금까지 만든 글로 확인한다. 비어 있으면 무시.
  void check() {
    final current = state.value;
    final question = current?.current;
    if (current == null || question == null || current.revealed) return;
    if (current.placed.isEmpty) return;
    final given = current.placed.map((id) => question.tile(id).text).join();
    final result = AssemblyResult(question: question, given: given);
    state = AsyncData(
      current.copyWith(results: [...current.results, result], revealed: true),
    );
    unawaited(
      ref.read(recordWordAnswersProvider)([
        WordAnswer(question.wordId, correct: result.correct),
      ]),
    );
  }

  /// 결과를 본 뒤 다음 문제로. 마지막이면 끝낸다.
  void next() {
    final current = state.value;
    if (current == null || !current.revealed) return;
    final done = current.results.length >= current.questions.length;
    state = AsyncData(
      current.copyWith(
        revealed: false,
        phase: done ? AssemblyPhase.finished : AssemblyPhase.running,
        placed: done
            ? const []
            : _initialPlaced(current.questions[current.results.length]),
      ),
    );
  }

  /// 같은 방식으로 새 문제를 만들어 다시 한다.
  Future<void> retry() => start();
}
