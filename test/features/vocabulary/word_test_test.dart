import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/features/vocabulary/di.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/word_test.dart';
import 'package:translation_poc_app/features/vocabulary/domain/usecases/vocabulary_usecases.dart';
import 'package:translation_poc_app/features/vocabulary/presentation/view_models/word_test_view_model.dart';

import '../../fakes.dart';

Wordbook _book(int id, String name) => Wordbook(
  id: id,
  name: name,
  wordCount: 0,
  memorizedCount: 0,
  createdAt: DateTime(2026, 10, 1),
);

VocabularyWord _word(int id, int bookId, String word, String meaning) =>
    VocabularyWord(
      id: id,
      wordbookId: bookId,
      word: word,
      meaning: meaning,
      sourceLanguage: 'en',
      targetLanguage: 'ko',
      memorized: false,
      savedAt: DateTime(2026, 10, 1),
    );

void main() {
  late FakeVocabularyRepository repository;

  setUp(() {
    repository = FakeVocabularyRepository(
      books: [_book(1, '영어'), _book(2, '일본어')],
      words: [
        _word(1, 1, 'apple', '사과'),
        _word(2, 1, 'banana', '바나나'),
        _word(3, 2, 'cherry', '체리'),
        _word(4, 2, 'grape', '포도'),
        _word(5, 2, 'melon', '멜론'),
      ],
    );
  });

  group('CreateWordTest', () {
    test('입력형은 단어장의 단어 수만큼 문제를 낸다 (10개까지)', () async {
      final questions = await CreateWordTest(repository)(
        CreateWordTestParams(
          WordbookSelection([1]),
          WordTestMode.typing,
          random: Random(1),
        ),
      );
      expect(questions.map((q) => q.word).toSet(), {'apple', 'banana'});
      expect(questions.every((q) => q.choices.isEmpty), isTrue);
    });

    test('4지선다는 같은 단어장이 모자라면 다른 단어장에서 보기를 채운다', () async {
      final questions = await CreateWordTest(repository)(
        CreateWordTestParams(
          WordbookSelection([1]),
          WordTestMode.choice,
          random: Random(1),
        ),
      );
      expect(questions, hasLength(2));
      for (final q in questions) {
        expect(q.choices, hasLength(4));
        expect(q.choices.toSet(), hasLength(4));
        expect(q.choices, contains(q.meaning));
      }
    });

    test('보기에 정답과 같은 뜻이 겹쳐 들어가지 않는다', () async {
      repository.savedWords.add(_word(6, 2, 'apple', '사과'));
      final questions = await CreateWordTest(repository)(
        CreateWordTestParams(
          WordbookSelection([1]),
          WordTestMode.choice,
          random: Random(2),
        ),
      );
      for (final q in questions) {
        expect(q.choices.where((c) => c == q.meaning), hasLength(1));
      }
    });

    test('단어장 여러 개를 고르면 단어를 합쳐 문제를 낸다 (AD-07)', () async {
      final questions = await CreateWordTest(repository)(
        CreateWordTestParams(
          WordbookSelection([1, 2]),
          WordTestMode.typing,
          random: Random(1),
        ),
      );
      expect(questions.map((q) => q.word).toSet(), {
        'apple',
        'banana',
        'cherry',
        'grape',
        'melon',
      });
    });

    test('같은 단어장 id를 여러 번 줘도 한 번만 센다', () {
      expect(WordbookSelection([2, 1, 2]), WordbookSelection([1, 2]));
      expect(WordbookSelection([2, 1, 2]).ids, [1, 2]);
    });

    test('단어가 없는 단어장은 문제가 없다', () async {
      repository.books.add(_book(3, '빈 단어장'));
      final questions = await CreateWordTest(repository)(
        CreateWordTestParams(WordbookSelection([3]), WordTestMode.typing),
      );
      expect(questions, isEmpty);
    });
  });

  group('정답 확인', () {
    test('입력형은 대소문자와 앞뒤 공백을 무시한다', () {
      const q = WordTestQuestion(
        wordId: 1,
        mode: WordTestMode.typing,
        word: 'Apple',
        meaning: '사과',
      );
      expect(q.isCorrect('  apple '), isTrue);
      expect(q.isCorrect('apples'), isFalse);
      expect(q.prompt, '사과');
    });

    test('4지선다는 고른 뜻이 정답 뜻이어야 한다', () {
      const q = WordTestQuestion(
        wordId: 1,
        mode: WordTestMode.choice,
        word: 'apple',
        meaning: '사과',
        choices: ['사과', '체리'],
      );
      expect(q.isCorrect('사과'), isTrue);
      expect(q.isCorrect('체리'), isFalse);
      expect(q.prompt, 'apple');
    });
  });

  group('WordTestViewModel', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [vocabularyRepositoryProvider.overrideWithValue(repository)],
      );
      container.listen(
        wordTestViewModelProvider(WordbookSelection([1])),
        (_, _) {},
      );
    });

    tearDown(() => container.dispose());

    WordTestViewModel model() => container.read(
      wordTestViewModelProvider(WordbookSelection([1])).notifier,
    );
    WordTestState now() => container
        .read(wordTestViewModelProvider(WordbookSelection([1])))
        .requireValue;

    test('단어가 4개 이상이면 4지선다가 기본이고, 모자라면 입력형만 된다', () async {
      await container.read(
        wordTestViewModelProvider(WordbookSelection([1])).future,
      );
      expect(now().choiceAvailable, isTrue);
      expect(now().mode, WordTestMode.choice);

      repository.savedWords.removeRange(2, 5);
      container.invalidate(wordTestViewModelProvider(WordbookSelection([1])));
      await container.read(
        wordTestViewModelProvider(WordbookSelection([1])).future,
      );
      expect(now().choiceAvailable, isFalse);
      expect(now().mode, WordTestMode.typing);
      model().setMode(WordTestMode.choice);
      expect(now().mode, WordTestMode.typing);
    });

    test('끝까지 풀면 점수와 틀린 단어가 나온다', () async {
      await container.read(
        wordTestViewModelProvider(WordbookSelection([1])).future,
      );
      model().setMode(WordTestMode.typing);
      await model().start();
      expect(now().phase, WordTestPhase.running);
      expect(now().questions, hasLength(2));

      final first = now().current!;
      model().submit(first.word);
      expect(now().revealed, isTrue);
      expect(now().lastAnswer!.correct, isTrue);
      // 답을 낸 뒤에는 다시 낼 수 없다.
      model().submit('엉뚱한 답');
      expect(now().answers, hasLength(1));
      model().next();
      expect(now().phase, WordTestPhase.running);

      model().submit('틀림');
      model().next();
      expect(now().phase, WordTestPhase.finished);
      expect(now().correctCount, 1);
      expect(now().wrongAnswers, hasLength(1));
    });

    test('다시 풀면 새 문제로 처음부터 시작한다', () async {
      await container.read(
        wordTestViewModelProvider(WordbookSelection([1])).future,
      );
      model().setMode(WordTestMode.typing);
      await model().start();
      model().submit('x');
      model().next();
      await model().retry();
      expect(now().answers, isEmpty);
      expect(now().phase, WordTestPhase.running);
    });
  });
}
