import 'dart:math';

import '../../../../core/domain/use_case.dart';
import '../entities/daily_word.dart';
import '../entities/falling_game.dart';
import '../entities/line_match.dart';
import '../entities/vocabulary.dart';
import '../entities/word_assembly.dart';
import '../entities/word_test.dart';
import '../repositories/vocabulary_repository.dart';

/// 단어장 목록 조회 (AD-04).
final class GetWordbooks implements NoParamsUseCase<List<Wordbook>> {
  const GetWordbooks(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<List<Wordbook>> call() => _repository.wordbooks();
}

/// 단어장 만들기 (AD-04). 이름이 비었으면 null.
final class CreateWordbook implements UseCase<Wordbook?, String> {
  const CreateWordbook(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<Wordbook?> call(String name) =>
      _repository.createWordbook(name.trim());
}

class RenameWordbookParams {
  const RenameWordbookParams(this.id, this.name);

  final int id;
  final String name;
}

/// 단어장 이름 바꾸기 (AD-04). 이름이 비었거나 겹치면 false.
final class RenameWordbook implements UseCase<bool, RenameWordbookParams> {
  const RenameWordbook(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<bool> call(RenameWordbookParams params) =>
      _repository.renameWordbook(params.id, params.name.trim());
}

/// 단어장 삭제 (AD-04). 안의 단어도 함께 지워진다.
final class DeleteWordbook implements UseCase<void, int> {
  const DeleteWordbook(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<void> call(int id) => _repository.deleteWordbook(id);
}

class GetWordsParams {
  const GetWordsParams(
    this.wordbookId, {
    this.query = '',
    this.sort = WordSort.newest,
    this.filter = WordFilter.all,
  });

  final int wordbookId;
  final String query;
  final WordSort sort;
  final WordFilter filter;
}

/// 단어장 안 단어 조회 · 검색 · 정렬 (AD-05).
final class GetWords implements UseCase<List<VocabularyWord>, GetWordsParams> {
  const GetWords(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<List<VocabularyWord>> call(GetWordsParams params) async {
    final accuracySort =
        params.sort == WordSort.accuracyHigh ||
        params.sort == WordSort.accuracyLow;
    final words = await _repository.words(
      params.wordbookId,
      query: params.query.trim(),
      // 정답률 정렬은 저장소가 모르므로 최신순으로 받아 여기서 정렬한다.
      sort: accuracySort ? WordSort.newest : params.sort,
    );
    final kept = [
      for (final w in words)
        if (params.filter.matches(w)) w,
    ];
    if (accuracySort) {
      final high = params.sort == WordSort.accuracyHigh;
      // 안 푼 단어는 방향과 상관없이 맨 뒤. 같은 정답률이면 많이 푼 쪽이 앞(높은순) / 뒤.
      kept.sort((a, b) {
        final x = a.accuracy;
        final y = b.accuracy;
        if (x == null && y == null) return 0;
        if (x == null) return 1;
        if (y == null) return -1;
        final byRate = high ? y.compareTo(x) : x.compareTo(y);
        return byRate != 0 ? byRate : b.attemptCount.compareTo(a.attemptCount);
      });
    }
    return kept;
  }
}

/// 테스트 · 게임에서 푼 결과를 단어별 정답률에 쌓는다 (AD-18).
final class RecordWordAnswers implements UseCase<void, List<WordAnswer>> {
  const RecordWordAnswers(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<void> call(List<WordAnswer> answers) =>
      answers.isEmpty ? Future.value() : _repository.recordAnswers(answers);
}

/// 단어 하나 조회 (AD-06). 없으면 null.
final class GetWord implements UseCase<VocabularyWord?, int> {
  const GetWord(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<VocabularyWord?> call(int id) => _repository.word(id);
}

class MoveWordParams {
  const MoveWordParams(this.id, this.wordbookId);

  final int id;
  final int wordbookId;
}

/// 단어를 다른 단어장으로 옮기기 (AD-05, AD-06).
final class MoveWord implements UseCase<void, MoveWordParams> {
  const MoveWord(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<void> call(MoveWordParams params) =>
      _repository.moveWord(params.id, params.wordbookId);
}

/// 단어 삭제 (AD-05, AD-06).
final class DeleteWord implements UseCase<void, int> {
  const DeleteWord(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<void> call(int id) => _repository.deleteWord(id);
}

class SetMemorizedParams {
  const SetMemorizedParams(this.id, {required this.memorized});

  final int id;
  final bool memorized;
}

/// 외운 단어 표시 (AD-05).
final class SetWordMemorized implements UseCase<void, SetMemorizedParams> {
  const SetWordMemorized(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<void> call(SetMemorizedParams params) =>
      _repository.setMemorized(params.id, params.memorized);
}

class SaveWordParams {
  const SaveWordParams(this.wordbookId, this.draft);

  final int wordbookId;
  final WordDraft draft;
}

/// 단어장에 단어 저장 (AD-03). 단어 · 뜻이 비어 있으면 null.
final class SaveWord implements UseCase<int?, SaveWordParams> {
  const SaveWord(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<int?> call(SaveWordParams params) {
    final draft = params.draft;
    if (draft.word.trim().isEmpty || draft.meaning.trim().isEmpty) {
      return Future.value();
    }
    return _repository.saveWord(params.wordbookId, draft);
  }
}

class CreateWordTestParams {
  const CreateWordTestParams(this.wordbookId, this.mode, {this.random});

  final int wordbookId;
  final WordTestMode mode;

  /// 테스트에서 순서를 고정하려고 바꿔 끼운다.
  final Random? random;
}

/// 암기 테스트 문제 만들기 (AD-09).
/// 문제 수는 단어장 크기에 맞춘다(최대 [maxQuestions]개, 무작위). 4지선다의 오답 보기 3개는 같은 단어장의
/// 다른 단어에서 뽑고, 모자라면 다른 단어장에서 채운다. 보기는 서로 · 정답과 뜻이 달라야 한다.
final class CreateWordTest
    implements UseCase<List<WordTestQuestion>, CreateWordTestParams> {
  const CreateWordTest(this._repository);

  static const maxQuestions = 10;
  static const choiceCount = 4;

  final VocabularyRepository _repository;

  /// 4지선다를 만들 수 있는 최소 단어 수 (모든 단어장 합).
  static const minWordsForChoice = choiceCount;

  @override
  Future<List<WordTestQuestion>> call(CreateWordTestParams params) async {
    final random = params.random ?? Random();
    final own = await _repository.words(params.wordbookId);
    if (own.isEmpty) return const [];
    final picked = [...own]..shuffle(random);
    final targets = picked.take(maxQuestions).toList();

    if (params.mode == WordTestMode.typing) {
      return [
        for (final word in targets)
          WordTestQuestion(
            wordId: word.id,
            mode: WordTestMode.typing,
            word: word.word,
            meaning: word.meaning,
          ),
      ];
    }

    // 같은 단어장 → 다른 단어장 순으로 오답 후보를 모은다.
    final others = <VocabularyWord>[];
    for (final book in await _repository.wordbooks()) {
      if (book.id == params.wordbookId) continue;
      others.addAll(await _repository.words(book.id));
    }
    final questions = <WordTestQuestion>[];
    for (final word in targets) {
      final meanings = <String>{word.meaning.trim().toLowerCase()};
      final wrong = <String>[];
      void collect(Iterable<VocabularyWord> pool) {
        final shuffled = [...pool]..shuffle(random);
        for (final candidate in shuffled) {
          if (wrong.length == choiceCount - 1) return;
          if (candidate.id == word.id) continue;
          if (meanings.add(candidate.meaning.trim().toLowerCase())) {
            wrong.add(candidate.meaning);
          }
        }
      }

      collect(own);
      collect(others);
      if (wrong.isEmpty) continue;
      questions.add(
        WordTestQuestion(
          wordId: word.id,
          mode: WordTestMode.choice,
          word: word.word,
          meaning: word.meaning,
          choices: [word.meaning, ...wrong]..shuffle(random),
        ),
      );
    }
    return questions;
  }
}

class CreateFlashcardDeckParams {
  const CreateFlashcardDeckParams(this.wordbookId, {this.random});

  final int wordbookId;

  /// 테스트에서 순서를 고정하려고 바꿔 끼운다.
  final Random? random;
}

/// 카드 학습용 단어 묶음 만들기 (AD-08): 단어장의 모든 단어를 무작위 순서로.
final class CreateFlashcardDeck
    implements UseCase<List<VocabularyWord>, CreateFlashcardDeckParams> {
  const CreateFlashcardDeck(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<List<VocabularyWord>> call(CreateFlashcardDeckParams params) async {
    final words = await _repository.words(params.wordbookId);
    return [...words]..shuffle(params.random ?? Random());
  }
}

class CreateLineMatchGameParams {
  const CreateLineMatchGameParams(this.wordbookId, {this.random});

  final int wordbookId;

  /// 테스트에서 순서를 고정하려고 바꿔 끼운다.
  final Random? random;
}

/// 선 잇기 게임 만들기 (AD-11). 단어가 없으면 null.
final class CreateLineMatchGame
    implements UseCase<LineMatchGame?, CreateLineMatchGameParams> {
  const CreateLineMatchGame(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<LineMatchGame?> call(CreateLineMatchGameParams params) async {
    final words = await _repository.words(params.wordbookId);
    if (words.isEmpty) return null;
    return LineMatchGame.start(words, random: params.random);
  }
}

class CreateFallingGameParams {
  const CreateFallingGameParams(
    this.wordbookId,
    this.mode, {
    this.random,
    this.speedScale = 1.0,
  });

  final int wordbookId;
  final FallingMode mode;

  /// 낙하 속도 배율 (0.5 ~ 2.0).
  final double speedScale;

  /// 테스트에서 순서를 고정하려고 바꿔 끼운다.
  final Random? random;
}

/// 하강형 타이핑 게임 만들기 (AD-12). 단어가 없으면 null.
final class CreateFallingGame
    implements UseCase<FallingGame?, CreateFallingGameParams> {
  const CreateFallingGame(this._repository);

  final VocabularyRepository _repository;

  @override
  Future<FallingGame?> call(CreateFallingGameParams params) async {
    final words = await _repository.words(params.wordbookId);
    if (words.isEmpty) return null;
    return FallingGame(
      words: words,
      mode: params.mode,
      random: params.random,
      speedScale: params.speedScale,
    );
  }
}

class CreateAssemblyGameParams {
  const CreateAssemblyGameParams(this.wordbookId, this.mode, {this.random});

  final int wordbookId;
  final AssemblyMode mode;

  /// 테스트에서 순서를 고정하려고 바꿔 끼운다.
  final Random? random;
}

/// 단어 조립 문제 만들기 (AD-13). 단어장에서 최대 [maxQuestions]개를 무작위로 뽑는다.
final class CreateAssemblyGame
    implements UseCase<List<AssemblyQuestion>, CreateAssemblyGameParams> {
  const CreateAssemblyGame(this._repository);

  static const maxQuestions = 10;

  final VocabularyRepository _repository;

  @override
  Future<List<AssemblyQuestion>> call(CreateAssemblyGameParams params) async {
    final random = params.random ?? Random();
    final words = await _repository.words(params.wordbookId);
    if (words.isEmpty) return const [];
    final targets = ([...words]..shuffle(random)).take(maxQuestions);
    return [
      for (final word in targets)
        AssemblyQuestion.build(
          word,
          params.mode,
          others: words,
          random: random,
        ),
    ];
  }
}

class GetWordOfTheDayParams {
  const GetWordOfTheDayParams(this.date, {this.skip = 0});

  final DateTime date;

  /// "다른 단어 보기"를 누른 횟수. 하루 단어에서 순서대로 다음 단어로 넘어간다.
  final int skip;
}

/// 오늘의 단어 고르기 (AD-14): 모든 단어장의 단어 중 날짜로 정한 한 단어. 같은 날에는 같은 단어가 나온다
/// (단어를 새로 저장하면 바뀔 수 있다). 단어가 없으면 null.
final class GetWordOfTheDay
    implements UseCase<DailyWord?, GetWordOfTheDayParams> {
  const GetWordOfTheDay(this._repository);

  static const choiceCount = 4;

  final VocabularyRepository _repository;

  @override
  Future<DailyWord?> call(GetWordOfTheDayParams params) async {
    final all = <VocabularyWord>[];
    for (final book in await _repository.wordbooks()) {
      all.addAll(await _repository.words(book.id));
    }
    if (all.isEmpty) return null;
    all.sort((a, b) => a.id.compareTo(b.id));

    final date = params.date;
    final day = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(2000)).inDays;
    final random = Random(day);
    final word = all[(random.nextInt(all.length) + params.skip) % all.length];

    final seen = <String>{word.meaning.trim().toLowerCase()};
    final wrong = <String>[];
    for (final other in [...all]..shuffle(random)) {
      if (wrong.length == choiceCount - 1) break;
      if (seen.add(other.meaning.trim().toLowerCase())) {
        wrong.add(other.meaning);
      }
    }
    if (wrong.isEmpty) return DailyWord(word: word);
    return DailyWord(
      word: word,
      choices: [word.meaning, ...wrong]..shuffle(random),
    );
  }
}
