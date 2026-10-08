import '../../../../core/bridge/translator_api.g.dart' as pigeon;

/// 네이티브 단어장 API(Pigeon, Room)를 감싼다.
class VocabularyNativeDataSource {
  const VocabularyNativeDataSource(this._api);

  final pigeon.VocabularyHostApi _api;

  Future<List<pigeon.Wordbook>> getWordbooks() => _api.getWordbooks();

  Future<pigeon.Wordbook?> createWordbook(String name) =>
      _api.createWordbook(name);

  Future<bool> renameWordbook(int id, String name) =>
      _api.renameWordbook(id, name);

  Future<void> deleteWordbook(int id) => _api.deleteWordbook(id);

  Future<List<pigeon.VocabWord>> getWords(
    int wordbookId,
    String query,
    pigeon.VocabSort sort,
  ) => _api.getWords(wordbookId, query, sort);

  Future<pigeon.VocabWord?> getWord(int id) => _api.getWord(id);

  Future<void> moveWord(int id, int wordbookId) =>
      _api.moveWord(id, wordbookId);

  Future<void> deleteWord(int id) => _api.deleteWord(id);

  Future<void> setMemorized(int id, bool memorized) =>
      _api.setMemorized(id, memorized);

  Future<void> recordAnswers(List<pigeon.WordAnswer> answers) =>
      _api.recordAnswers(answers);

  Future<int?> saveWord(int wordbookId, pigeon.VocabWordInput input) =>
      _api.saveWord(wordbookId, input);

  Future<bool> updateWord(int id, pigeon.VocabWordInput input) =>
      _api.updateWord(id, input);
}
