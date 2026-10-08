import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/word_test.dart';
import 'package:translation_poc_app/features/vocabulary/domain/usecases/vocabulary_usecases.dart';
import 'package:translation_poc_app/features/vocabulary/presentation/view_models/word_test_view_model.dart';

import '../../fakes.dart';

VocabularyWord _word(int id, String word, {int correct = 0, int attempt = 0}) =>
    VocabularyWord(
      id: id,
      wordbookId: 1,
      word: word,
      meaning: '뜻$id',
      sourceLanguage: 'en',
      targetLanguage: 'ko',
      memorized: false,
      savedAt: DateTime(2026, 10, id),
      correctCount: correct,
      attemptCount: attempt,
    );

Wordbook _book() => Wordbook(
  id: 1,
  name: '영어',
  wordCount: 4,
  memorizedCount: 0,
  createdAt: DateTime(2026, 10, 1),
);

void main() {
  final words = [
    _word(1, 'a', correct: 9, attempt: 10), // 90%
    _word(2, 'b', correct: 1, attempt: 4), // 25%
    _word(3, 'c'), // 안 풂
    _word(4, 'd', correct: 3, attempt: 5), // 60%
  ];

  Future<List<String>> run(
    FakeVocabularyRepository repository,
    WordSort sort,
    WordFilter filter,
  ) async {
    final result = await GetWords(repository)(
      GetWordsParams(1, sort: sort, filter: filter),
    );
    return [for (final w in result) w.word];
  }

  test('정답률 정렬은 안 푼 단어를 맨 뒤에 둔다', () async {
    final repository = FakeVocabularyRepository(books: [_book()], words: words);
    expect(await run(repository, WordSort.accuracyHigh, WordFilter.all), [
      'a',
      'd',
      'b',
      'c',
    ]);
    expect(await run(repository, WordSort.accuracyLow, WordFilter.all), [
      'b',
      'd',
      'a',
      'c',
    ]);
  });

  test('필터는 정답률 구간으로 거른다', () async {
    final repository = FakeVocabularyRepository(books: [_book()], words: words);
    expect(await run(repository, WordSort.newest, WordFilter.low), ['b']);
    expect(await run(repository, WordSort.newest, WordFilter.mid), ['d']);
    expect(await run(repository, WordSort.newest, WordFilter.high), ['a']);
    expect(await run(repository, WordSort.newest, WordFilter.notStudied), [
      'c',
    ]);
  });

  test('테스트에서 답을 내면 단어별 정답 · 시도 횟수가 쌓인다', () async {
    final repository = FakeVocabularyRepository(
      books: [_book()],
      words: [_word(1, 'apple'), _word(2, 'pear')],
    );
    final container = ProviderContainer(
      overrides: fakeNativeOverrides(vocabulary: repository),
    );
    addTearDown(container.dispose);
    final provider = wordTestViewModelProvider(WordbookSelection([1]));
    await container.read(provider.future);
    final model = container.read(provider.notifier);
    model.setMode(WordTestMode.typing);
    await model.start();
    final question = container.read(provider).value!.current!;
    model.submit(question.expected);
    await Future<void>.delayed(Duration.zero);
    expect(repository.recorded.single.wordId, question.wordId);
    expect(repository.recorded.single.correct, isTrue);
    final saved = repository.savedWords.firstWhere(
      (w) => w.id == question.wordId,
    );
    expect(saved.attemptCount, 1);
    expect(saved.correctCount, 1);
    expect(saved.accuracy, 1.0);
  });
}
