import '../../domain/entities/vocabulary.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../datasources/vocabulary_native_data_source.dart';
import '../mappers/vocabulary_mapper.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  const VocabularyRepositoryImpl(this._dataSource, {this.onStudied});

  final VocabularyNativeDataSource _dataSource;

  /// 답을 기록하거나 외움 표시를 바꿀 때 호출한다 (연속 학습 일수용, D-072).
  final Future<void> Function()? onStudied;

  @override
  Future<List<Wordbook>> wordbooks() async => [
    for (final book in await _dataSource.getWordbooks()) book.toEntity(),
  ];

  @override
  Future<Wordbook?> createWordbook(String name) async =>
      (await _dataSource.createWordbook(name))?.toEntity();

  @override
  Future<bool> renameWordbook(int id, String name) =>
      _dataSource.renameWordbook(id, name);

  @override
  Future<void> deleteWordbook(int id) => _dataSource.deleteWordbook(id);

  @override
  Future<List<VocabularyWord>> words(
    int wordbookId, {
    String query = '',
    WordSort sort = WordSort.newest,
  }) async => [
    for (final word in await _dataSource.getWords(
      wordbookId,
      query,
      sort.toPigeon(),
    ))
      word.toEntity(),
  ];

  @override
  Future<VocabularyWord?> word(int id) async =>
      (await _dataSource.getWord(id))?.toEntity();

  @override
  Future<List<int>> wordbookIdsOf(int id) => _dataSource.getWordWordbookIds(id);

  @override
  Future<void> moveWord(int id, int fromWordbookId, int toWordbookId) =>
      _dataSource.moveWord(id, fromWordbookId, toWordbookId);

  @override
  Future<bool> addToWordbook(int id, int wordbookId) =>
      _dataSource.addWordToWordbook(id, wordbookId);

  @override
  Future<void> removeFromWordbook(int id, int wordbookId) =>
      _dataSource.removeWordFromWordbook(id, wordbookId);

  @override
  Future<void> deleteWord(int id) => _dataSource.deleteWord(id);

  @override
  Future<List<WordbookProgress>> progressOf(int id) async => [
    for (final p in await _dataSource.getWordProgress(id)) p.toEntity(),
  ];

  @override
  Future<VocabularyWord?> findSame(
    String word,
    String sourceLanguage,
    String targetLanguage,
  ) async => (await _dataSource.findSameWord(
    word,
    sourceLanguage,
    targetLanguage,
  ))?.toEntity();

  @override
  Future<void> setMemorized(int wordbookId, int id, bool memorized) async {
    await _dataSource.setMemorized(wordbookId, id, memorized);
    await onStudied?.call();
  }

  @override
  Future<void> recordAnswers(List<WordAnswer> answers) async {
    await _dataSource.recordAnswers([for (final a in answers) a.toPigeon()]);
    if (answers.isNotEmpty) await onStudied?.call();
  }

  @override
  Future<int?> saveWord(int wordbookId, WordDraft draft) =>
      _dataSource.saveWord(wordbookId, draft.toPigeon());

  @override
  Future<bool> updateWord(int id, WordDraft draft) =>
      _dataSource.updateWord(id, draft.toPigeon());

  @override
  Future<bool> addMeaning(int id, WordDraft draft) =>
      _dataSource.addWordMeaning(id, draft.toPigeon());

  @override
  Future<bool> updateMeaning(int meaningId, WordDraft draft) =>
      _dataSource.updateWordMeaning(meaningId, draft.toPigeon());

  @override
  Future<bool> deleteMeaning(int meaningId) =>
      _dataSource.deleteWordMeaning(meaningId);
}
