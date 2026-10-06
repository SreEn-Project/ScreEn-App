import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/usecases/vocabulary_usecases.dart';

part 'wordbook_detail_view_model.g.dart';

/// 단어장 상세 상태 (AD-05): 검색어 · 정렬과 그에 맞는 단어.
class WordbookDetailState {
  const WordbookDetailState({
    this.query = '',
    this.sort = WordSort.newest,
    this.words = const [],
  });

  final String query;
  final WordSort sort;
  final List<VocabularyWord> words;

  /// 검색어를 걸어서 비어 보이는 상태인지 (단어장이 비어 있는 것과 구분해 안내하려고).
  bool get filtered => query.trim().isNotEmpty;

  WordbookDetailState copyWith({
    String? query,
    WordSort? sort,
    List<VocabularyWord>? words,
  }) => WordbookDetailState(
    query: query ?? this.query,
    sort: sort ?? this.sort,
    words: words ?? this.words,
  );
}

@riverpod
class WordbookDetailViewModel extends _$WordbookDetailViewModel {
  // 검색어를 빠르게 바꿀 때 늦게 온 이전 결과가 덮어쓰지 않도록 가장 마지막 요청만 반영한다.
  int _request = 0;

  @override
  Future<WordbookDetailState> build(int wordbookId) async {
    final words = await ref.watch(getWordsProvider)(GetWordsParams(wordbookId));
    return WordbookDetailState(words: words);
  }

  WordbookDetailState get _current =>
      state.value ?? const WordbookDetailState();

  Future<void> setQuery(String query) =>
      _reload(_current.copyWith(query: query));

  Future<void> setSort(WordSort sort) => _reload(_current.copyWith(sort: sort));

  /// 단어 상세에서 지우거나 옮기고 돌아왔을 때 등, 조건은 그대로 두고 다시 읽는다.
  Future<void> refresh() => _reload(_current);

  Future<void> _reload(WordbookDetailState next) async {
    final request = ++_request;
    // 목록은 그대로 두고 조건만 먼저 반영한다 (입력이 끊기지 않게).
    state = AsyncData(next);
    final words = await ref.read(getWordsProvider)(
      GetWordsParams(wordbookId, query: next.query, sort: next.sort),
    );
    if (request != _request) return;
    state = AsyncData(next.copyWith(words: words));
  }

  /// 외운 표시를 바꾼다. 화면은 바로 바꾸고 저장한다.
  Future<void> setMemorized(int id, {required bool memorized}) async {
    final now = _current;
    state = AsyncData(
      now.copyWith(
        words: [
          for (final word in now.words)
            if (word.id == id) _withMemorized(word, memorized) else word,
        ],
      ),
    );
    await ref.read(setWordMemorizedProvider)(
      SetMemorizedParams(id, memorized: memorized),
    );
  }

  Future<void> delete(int id) async {
    final now = _current;
    state = AsyncData(
      now.copyWith(
        words: [
          for (final word in now.words)
            if (word.id != id) word,
        ],
      ),
    );
    await ref.read(deleteWordProvider)(id);
  }

  Future<void> move(int id, int toWordbookId) async {
    await ref.read(moveWordProvider)(MoveWordParams(id, toWordbookId));
    await refresh();
  }

  VocabularyWord _withMemorized(VocabularyWord word, bool memorized) =>
      VocabularyWord(
        id: word.id,
        wordbookId: word.wordbookId,
        word: word.word,
        meaning: word.meaning,
        pronunciation: word.pronunciation,
        partOfSpeech: word.partOfSpeech,
        contextMeaning: word.contextMeaning,
        sentence: word.sentence,
        sourceApp: word.sourceApp,
        sourceLanguage: word.sourceLanguage,
        targetLanguage: word.targetLanguage,
        memorized: memorized,
        savedAt: word.savedAt,
      );
}
