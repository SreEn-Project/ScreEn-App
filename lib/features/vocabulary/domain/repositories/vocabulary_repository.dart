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

  /// 단어장을 모르는 상세 화면용: 들어 있는 첫 단어장 기준.
  Future<VocabularyWord?> word(int id);

  /// 단어가 들어 있는 단어장마다의 진도.
  Future<List<WordbookProgress>> progressOf(int id);

  /// 같은 단어(글자 · 언어쌍)가 이미 저장돼 있으면 돌려준다.
  Future<VocabularyWord?> findSame(
    String word,
    String sourceLanguage,
    String targetLanguage,
  );

  /// 단어가 들어 있는 단어장 id. 한 단어가 여러 단어장에 들 수 있다.
  Future<List<int>> wordbookIdsOf(int id);

  /// [fromWordbookId]에서 [toWordbookId]로 옮긴다. 거기에 같은 단어가 있으면 합친다.
  Future<void> moveWord(int id, int fromWordbookId, int toWordbookId);

  /// 다른 단어장에도 넣는다. 이미 들어 있거나 그 단어장에 같은 글자의 단어가 있으면 false.
  Future<bool> addToWordbook(int id, int wordbookId);

  /// 한 단어장에서만 뺀다. 마지막 단어장이었으면 단어도 지워진다.
  Future<void> removeFromWordbook(int id, int wordbookId);

  /// 모든 단어장에서 지운다.
  Future<void> deleteWord(int id);

  /// [wordbookId] 단어장에서의 외움 표시.
  Future<void> setMemorized(int wordbookId, int id, bool memorized);

  /// 테스트 · 게임에서 푼 결과를 단어별로 쌓는다 (AD-18).
  Future<void> recordAnswers(List<WordAnswer> answers);

  /// 단어를 저장한다. 단어 · 뜻이 비어 있으면 null. 같은 단어장에 같은 단어가 있으면 내용만 새로 고친다.
  Future<int?> saveWord(int wordbookId, WordDraft draft);

  /// 저장된 단어의 공통 부분과 대표 뜻을 고친다. 진도 · 저장 시각은 유지한다.
  /// 단어 · 뜻이 비었거나 들어 있는 단어장의 다른 단어와 겹치거나 단어가 없으면 false.
  Future<bool> updateWord(int id, WordDraft draft);

  /// 단어에 뜻을 더한다 (draft의 뜻 · 문맥 뜻 · 예문만 쓴다). 비었거나 같은 뜻이 있으면 false.
  Future<bool> addMeaning(int id, WordDraft draft);

  /// 뜻 하나를 고친다. 비었거나 같은 단어의 다른 뜻과 겹치면 false.
  Future<bool> updateMeaning(int meaningId, WordDraft draft);

  /// 뜻 하나를 지운다. 마지막 뜻이면 false.
  Future<bool> deleteMeaning(int meaningId);
}
