import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/vocabulary.dart';
import '../../domain/usecases/vocabulary_usecases.dart';

part 'all_words_view_model.g.dart';

/// 전체 단어 화면 상태 (AD-05): 검색어 · 정렬 · 필터와 그에 맞는 단어.
class AllWordsState {
  const AllWordsState({
    this.query = '',
    this.sort = WordSort.newest,
    this.filter = WordFilter.all,
    this.words = const [],
  });

  final String query;
  final WordSort sort;
  final WordFilter filter;
  final List<VocabularyWord> words;

  bool get filtered => query.trim().isNotEmpty || filter != WordFilter.all;

  AllWordsState copyWith({
    String? query,
    WordSort? sort,
    WordFilter? filter,
    List<VocabularyWord>? words,
  }) => AllWordsState(
    query: query ?? this.query,
    sort: sort ?? this.sort,
    filter: filter ?? this.filter,
    words: words ?? this.words,
  );
}

@riverpod
class AllWordsViewModel extends _$AllWordsViewModel {
  int _request = 0;

  @override
  Future<AllWordsState> build() async {
    final words = await ref.watch(getAllWordsProvider)(
      const GetAllWordsParams(),
    );
    return AllWordsState(words: words);
  }

  AllWordsState get _current => state.value ?? const AllWordsState();

  Future<void> setQuery(String query) =>
      _reload(_current.copyWith(query: query));

  Future<void> setSort(WordSort sort) => _reload(_current.copyWith(sort: sort));

  Future<void> setFilter(WordFilter filter) =>
      _reload(_current.copyWith(filter: filter));

  /// 상세에서 고치거나 지우고 돌아왔을 때 등, 조건은 그대로 두고 다시 읽는다.
  Future<void> refresh() => _reload(_current);

  Future<void> _reload(AllWordsState next) async {
    final request = ++_request;
    state = AsyncData(next);
    final words = await ref.read(getAllWordsProvider)(
      GetAllWordsParams(
        query: next.query,
        sort: next.sort,
        filter: next.filter,
      ),
    );
    if (request != _request) return;
    state = AsyncData(next.copyWith(words: words));
  }
}
