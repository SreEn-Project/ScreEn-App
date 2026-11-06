import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/features/vocabulary/di.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:translation_poc_app/features/vocabulary/presentation/view_models/word_detail_view_model.dart';
import 'package:translation_poc_app/features/vocabulary/presentation/view_models/wordbook_detail_view_model.dart';
import 'package:translation_poc_app/features/vocabulary/presentation/view_models/wordbooks_view_model.dart';

import '../../fakes.dart';

Wordbook _book(int id, String name) => Wordbook(
  id: id,
  name: name,
  wordCount: 0,
  memorizedCount: 0,
  createdAt: DateTime(2026, 10, 1),
);

VocabularyWord _word(
  int id,
  int bookId,
  String word,
  String meaning, {
  int day = 1,
  bool memorized = false,
}) => VocabularyWord(
  id: id,
  wordbookId: bookId,
  word: word,
  meaning: meaning,
  sourceLanguage: 'en',
  targetLanguage: 'ko',
  memorized: memorized,
  savedAt: DateTime(2026, 10, day),
);

void main() {
  late FakeVocabularyRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeVocabularyRepository(
      books: [_book(1, '영어'), _book(2, '일본어')],
      words: [
        _word(1, 1, 'banana', '바나나', day: 1),
        _word(2, 1, 'Apple', '사과', day: 3, memorized: true),
        _word(3, 1, 'cherry', '체리', day: 2),
        _word(4, 2, 'banana', '바나나', day: 5),
      ],
    );
    container = ProviderContainer(
      overrides: [vocabularyRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  group('단어장 목록', () {
    Future<List<Wordbook>> ready() =>
        container.read(wordbooksViewModelProvider.future);
    WordbooksViewModel model() =>
        container.read(wordbooksViewModelProvider.notifier);
    List<Wordbook> now() =>
        container.read(wordbooksViewModelProvider).requireValue;

    setUp(() => container.listen(wordbooksViewModelProvider, (_, _) {}));

    test('단어 수와 외운 단어 수를 함께 보여 준다', () async {
      final books = await ready();
      expect(books.map((b) => b.name), ['영어', '일본어']);
      expect(books.first.wordCount, 3);
      expect(books.first.memorizedCount, 1);
    });

    test('새 단어장을 만들면 목록에 붙는다', () async {
      await ready();
      final created = await model().create('  독일어  ');
      expect(created?.name, '독일어');
      expect(now().map((b) => b.name), ['영어', '일본어', '독일어']);
    });

    test('빈 이름은 만들지 않는다', () async {
      await ready();
      expect(await model().create('   '), isNull);
      expect(now(), hasLength(2));
    });

    test('같은 이름으로 만들면 있던 단어장을 돌려준다', () async {
      await ready();
      final again = await model().create('영어');
      expect(again?.id, 1);
      expect(now(), hasLength(2));
    });

    test('이름 변경: 겹치는 이름은 거부한다', () async {
      await ready();
      expect(await model().rename(1, '일본어'), isFalse);
      expect(await model().rename(1, '영어회화'), isTrue);
      expect(now().first.name, '영어회화');
    });

    test('삭제하면 안의 단어도 지워진다', () async {
      await ready();
      await model().delete(1);
      expect(now().map((b) => b.id), [2]);
      expect(repository.savedWords.map((w) => w.id), [4]);
    });
  });

  group('단어장 상세', () {
    final provider = wordbookDetailViewModelProvider(1);
    Future<WordbookDetailState> ready() => container.read(provider.future);
    WordbookDetailViewModel model() => container.read(provider.notifier);
    WordbookDetailState now() => container.read(provider).requireValue;

    setUp(() => container.listen(provider, (_, _) {}));

    test('처음에는 최신순이다', () async {
      expect((await ready()).words.map((w) => w.id), [2, 3, 1]);
    });

    test('정렬: 오래된순 · 이름순(대소문자 무시)', () async {
      await ready();
      await model().setSort(WordSort.oldest);
      expect(now().words.map((w) => w.id), [1, 3, 2]);
      await model().setSort(WordSort.alphabetical);
      expect(now().words.map((w) => w.word), ['Apple', 'banana', 'cherry']);
    });

    test('검색은 단어와 뜻 모두에서 찾고, 정렬은 유지한다', () async {
      await ready();
      await model().setSort(WordSort.alphabetical);
      await model().setQuery('사과');
      expect(now().words.map((w) => w.id), [2]);
      expect(now().filtered, isTrue);
      await model().setQuery('AN');
      expect(now().words.map((w) => w.word), ['banana']);
      expect(now().sort, WordSort.alphabetical);
    });

    test('외운 표시를 바꾸면 화면과 저장소에 반영된다', () async {
      await ready();
      await model().setMemorized(1, memorized: true);
      expect(now().words.firstWhere((w) => w.id == 1).memorized, isTrue);
      expect(
        repository.savedWords.firstWhere((w) => w.id == 1).memorized,
        isTrue,
      );
    });

    test('삭제는 목록과 저장소에서 지운다', () async {
      await ready();
      await model().delete(3);
      expect(now().words.map((w) => w.id), [2, 1]);
      expect(repository.savedWords.any((w) => w.id == 3), isFalse);
    });

    test('다른 단어장에도 든 단어를 빼면 그 단어장에는 남는다', () async {
      await ready();
      expect(await model().addTo(3, 2), isTrue);
      await model().delete(3);
      expect(now().words.map((w) => w.id), [2, 1]);
      expect(repository.savedWords.any((w) => w.id == 3), isTrue);
      expect(await repository.words(2), isNotEmpty);
      expect((await repository.words(2)).map((w) => w.id), contains(3));
    });

    test('이동하면 이 단어장에서 사라진다', () async {
      await ready();
      await model().move(3, 2);
      expect(now().words.map((w) => w.id), [2, 1]);
      expect(repository.savedWords.firstWhere((w) => w.id == 3).wordbookId, 2);
    });

    test('옮길 단어장에 같은 단어가 있으면 합친다', () async {
      await ready();
      await model().move(1, 2);
      expect(now().words.map((w) => w.id), [2, 3]);
      expect(
        repository.savedWords.where((w) => w.word == 'banana'),
        hasLength(1),
      );
    });
  });

  group('단어 상세', () {
    test('저장한 단어를 읽는다', () async {
      final word = await container.read(wordDetailViewModelProvider(2).future);
      expect(word?.word, 'Apple');
    });

    test('없는 단어는 null이다', () async {
      expect(
        await container.read(wordDetailViewModelProvider(999).future),
        isNull,
      );
    });

    test('다른 단어장에도 넣으면 두 곳에 든다', () async {
      final provider = wordDetailViewModelProvider(3);
      container.listen(provider, (_, _) {});
      await container.read(provider.future);
      final model = container.read(provider.notifier);
      expect(await model.addTo(2), isTrue);
      expect(await model.wordbookIds(), [1, 2]);
      // 같은 단어 하나라서 두 단어장에서 같은 id로 보인다.
      expect(repository.savedWords.where((w) => w.id == 3), hasLength(1));
    });

    test('그 단어장에 같은 글자가 있거나 이미 들어 있으면 넣지 않는다', () async {
      final provider = wordDetailViewModelProvider(1);
      container.listen(provider, (_, _) {});
      await container.read(provider.future);
      final model = container.read(provider.notifier);
      expect(await model.addTo(2), isFalse);
      expect(await model.addTo(1), isFalse);
    });

    test('삭제하면 저장소에서 지운다', () async {
      final provider = wordDetailViewModelProvider(3);
      container.listen(provider, (_, _) {});
      await container.read(provider.future);
      await container.read(provider.notifier).delete();
      expect(repository.savedWords.any((w) => w.id == 3), isFalse);
    });
  });
}
