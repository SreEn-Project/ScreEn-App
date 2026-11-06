import '../../domain/entities/vocabulary.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../datasources/vocabulary_native_data_source.dart';
import '../mappers/vocabulary_mapper.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  const VocabularyRepositoryImpl(this._dataSource);

  final VocabularyNativeDataSource _dataSource;

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
  Future<void> setMemorized(int id, bool memorized) =>
      _dataSource.setMemorized(id, memorized);

  @override
  Future<void> recordAnswers(List<WordAnswer> answers) =>
      _dataSource.recordAnswers([for (final a in answers) a.toPigeon()]);

  @override
  Future<int?> saveWord(int wordbookId, WordDraft draft) =>
      _dataSource.saveWord(wordbookId, draft.toPigeon());

  @override
  Future<bool> updateWord(int id, WordDraft draft) =>
      _dataSource.updateWord(id, draft.toPigeon());
}
