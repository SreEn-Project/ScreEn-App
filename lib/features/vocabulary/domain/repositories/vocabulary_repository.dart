import '../entities/vocabulary.dart';

/// 단어장 · 단어 (원본은 네이티브 Room). 단어 저장은 오버레이가 하고, 앱은 관리만 한다.
abstract interface class VocabularyRepository {
  /// 만든 순서대로.
  Future<List<Wordbook>> wordbooks();

  /// 같은 이름이 이미 있으면 그 단어장을 돌려준다. 이름이 비었으면 null.
  Future<Wordbook?> createWordbook(String name);

  /// 이름이 비었거나 다른 단어장과 겹치면 false.
  Future<bool> renameWordbook(int id, String name);

  /// 안의 단어도 함께 지운다.
  Future<void> deleteWordbook(int id);

  /// [query]는 단어 · 뜻에서 찾을 글자(빈 문자열 = 전부).
  Future<List<VocabularyWord>> words(
    int wordbookId, {
    String query = '',
    WordSort sort = WordSort.newest,
  });

  Future<VocabularyWord?> word(int id);

  /// 다른 단어장으로 옮긴다. 거기에 같은 단어가 있으면 합친다.
  Future<void> moveWord(int id, int wordbookId);

  Future<void> deleteWord(int id);

  Future<void> setMemorized(int id, bool memorized);

  /// 테스트 · 게임에서 푼 결과를 단어별로 쌓는다 (AD-18).
  Future<void> recordAnswers(List<WordAnswer> answers);

  /// 단어를 저장한다. 단어 · 뜻이 비어 있으면 null. 같은 단어장에 같은 단어가 있으면 내용만 새로 고친다.
  Future<int?> saveWord(int wordbookId, WordDraft draft);

  /// 저장된 단어의 내용을 고친다. 외운 표시 · 정답률 · 저장 시각은 유지한다.
  /// 단어 · 뜻이 비었거나 같은 단어장의 다른 단어와 겹치거나 단어가 없으면 false.
  Future<bool> updateWord(int id, WordDraft draft);
}
