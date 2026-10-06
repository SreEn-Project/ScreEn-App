/// 단어장 (AD-03, AD-04).
class Wordbook {
  const Wordbook({
    required this.id,
    required this.name,
    required this.wordCount,
    required this.memorizedCount,
    required this.createdAt,
  });

  final int id;
  final String name;
  final int wordCount;
  final int memorizedCount;
  final DateTime createdAt;
}

/// 저장한 단어 (AD-03, AD-05, AD-06).
class VocabularyWord {
  const VocabularyWord({
    required this.id,
    required this.wordbookId,
    required this.word,
    required this.meaning,
    this.pronunciation,
    this.partOfSpeech,
    this.contextMeaning,
    this.sentence,
    this.sourceApp,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.memorized,
    required this.savedAt,
  });

  final int id;
  final int wordbookId;
  final String word;
  final String meaning;
  final String? pronunciation;
  final String? partOfSpeech;

  /// 주변 문장 기준 문맥 뜻 (AI 엔진으로 저장했을 때만).
  final String? contextMeaning;

  /// 단어를 고른 원래 문장 (문맥 예문).
  final String? sentence;
  final String? sourceApp;

  /// BCP-47 언어 코드.
  final String sourceLanguage;
  final String targetLanguage;
  final bool memorized;
  final DateTime savedAt;
}

/// 단어 목록 정렬 (AD-05).
enum WordSort { newest, oldest, alphabetical }
