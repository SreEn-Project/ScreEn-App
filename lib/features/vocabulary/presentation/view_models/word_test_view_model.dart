import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/entities/word_test.dart';
import '../../domain/usecases/vocabulary_usecases.dart';

part 'word_test_view_model.g.dart';

enum WordTestPhase { setup, running, finished }

/// 암기 테스트 화면(L-03)의 상태.
class WordTestState {
  const WordTestState({
    required this.book,
    required this.choiceAvailable,
    this.phase = WordTestPhase.setup,
    this.mode = WordTestMode.choice,
    this.questions = const [],
    this.answers = const [],
    this.revealed = false,
    this.failedToStart = false,
  });

  /// 시험 볼 단어장. 없어졌으면 null.
  final Wordbook? book;

  /// 4지선다는 모든 단어장을 합쳐 단어가 [CreateWordTest.minWordsForChoice]개 이상일 때만 만들 수 있다.
  final bool choiceAvailable;
  final WordTestPhase phase;
  final WordTestMode mode;
  final List<WordTestQuestion> questions;

  /// 지금까지 푼 답.
  final List<WordTestAnswer> answers;

  /// 방금 푼 문제의 정답 · 오답을 보여 주는 중 (다음 버튼을 기다린다).
  final bool revealed;

  /// 문제를 만들지 못했다 (단어가 없음 등).
  final bool failedToStart;

  /// 지금 보여 줄 문제의 번호 (0부터).
  int get index => revealed ? answers.length - 1 : answers.length;

  WordTestQuestion? get current =>
      phase == WordTestPhase.running && index < questions.length
      ? questions[index]
      : null;

  /// 보여 주는 중인 문제의 내 답.
  WordTestAnswer? get lastAnswer => revealed ? answers.last : null;

  int get correctCount => answers.where((a) => a.correct).length;

  List<WordTestAnswer> get wrongAnswers => [
    for (final a in answers)
      if (!a.correct) a,
  ];

  WordTestState copyWith({
    WordTestPhase? phase,
    WordTestMode? mode,
    List<WordTestQuestion>? questions,
    List<WordTestAnswer>? answers,
    bool? revealed,
    bool? failedToStart,
  }) => WordTestState(
    book: book,
    choiceAvailable: choiceAvailable,
    phase: phase ?? this.phase,
    mode: mode ?? this.mode,
    questions: questions ?? this.questions,
    answers: answers ?? this.answers,
    revealed: revealed ?? this.revealed,
    failedToStart: failedToStart ?? this.failedToStart,
  );
}

/// 암기 테스트 (AD-09, L-03): 방식 고르기 → 문제 풀기(제출하면 바로 정답 · 오답) → 점수와 틀린 단어.
@riverpod
class WordTestViewModel extends _$WordTestViewModel {
  @override
  Future<WordTestState> build(WordbookSelection selection) async {
    final books = await ref.watch(getWordbooksProvider)();
    final total = books.fold<int>(0, (sum, b) => sum + b.wordCount);
    final book = selection.summarize(books);
    final choiceAvailable = total >= CreateWordTest.minWordsForChoice;
    return WordTestState(
      book: book,
      choiceAvailable: choiceAvailable,
      mode: choiceAvailable ? WordTestMode.choice : WordTestMode.typing,
    );
  }

  void setMode(WordTestMode mode) {
    final current = state.value;
    if (current == null || current.phase != WordTestPhase.setup) return;
    if (mode == WordTestMode.choice && !current.choiceAvailable) return;
    state = AsyncData(current.copyWith(mode: mode, failedToStart: false));
  }

  Future<void> start() async {
    final current = state.value;
    if (current == null) return;
    final questions = await ref.read(createWordTestProvider)(
      CreateWordTestParams(selection, current.mode),
    );
    state = AsyncData(
      questions.isEmpty
          ? current.copyWith(failedToStart: true)
          : current.copyWith(
              phase: WordTestPhase.running,
              questions: questions,
              answers: const [],
              revealed: false,
              failedToStart: false,
            ),
    );
  }

  /// 현재 문제의 답을 낸다. 이미 낸 뒤면 무시한다.
  void submit(String answer) {
    final current = state.value;
    final question = current?.current;
    if (current == null || question == null || current.revealed) return;
    final given = WordTestAnswer(question: question, answer: answer);
    state = AsyncData(
      current.copyWith(answers: [...current.answers, given], revealed: true),
    );
    // 단어별 정답률에 쌓는다 (AD-18).
    unawaited(
      ref.read(recordWordAnswersProvider)([
        WordAnswer(question.wordId, correct: given.correct),
      ]),
    );
  }

  /// 결과를 본 뒤 다음 문제로. 마지막이면 끝낸다.
  void next() {
    final current = state.value;
    if (current == null || !current.revealed) return;
    final done = current.answers.length >= current.questions.length;
    state = AsyncData(
      current.copyWith(
        revealed: false,
        phase: done ? WordTestPhase.finished : WordTestPhase.running,
      ),
    );
  }

  /// 같은 방식으로 새 문제를 만들어 다시 본다.
  Future<void> retry() => start();

  /// 방식 고르기 화면으로 돌아간다.
  void backToSetup() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        phase: WordTestPhase.setup,
        questions: const [],
        answers: const [],
        revealed: false,
      ),
    );
  }
}
