/// 단어장 (AD-03, AD-04).
class Wordbook {
  const Wordbook({
    required this.id,
    required this.name,
    required this.wordCount,
    required this.memorizedCount,
    required this.createdAt,
    this.correctCount = 0,
    this.attemptCount = 0,
  });

  final int id;
  final String name;
  final int wordCount;
  final int memorizedCount;
  final DateTime createdAt;

  /// 단어장 안 모든 단어의 맞힌 횟수 · 푼 횟수 합 (AD-18).
  final int correctCount;
  final int attemptCount;

  /// 정답률 0~1. 아직 푼 적이 없으면 null.
  double? get accuracy =>
      attemptCount == 0 ? null : correctCount / attemptCount;
}

/// 한 번에 학습할 단어장 모음 (AD-07). 값으로 비교하므로 Riverpod family 인자로 쓴다.
class WordbookSelection {
  WordbookSelection(Iterable<int> ids)
    : ids = List.unmodifiable({...ids}.toList()..sort());

  /// 정렬된 단어장 id (중복 없음).
  final List<int> ids;

  bool get isEmpty => ids.isEmpty;

  bool contains(int id) => ids.contains(id);

  /// 고른 단어장들을 합친 하나의 단어장처럼 요약한다 (이름은 쉼표로 이음). 하나도 없으면 null.
  Wordbook? summarize(List<Wordbook> books) {
    final picked = [
      for (final book in books)
        if (contains(book.id)) book,
    ];
    if (picked.isEmpty) return null;
    if (picked.length == 1) return picked.first;
    return Wordbook(
      id: picked.first.id,
      name: picked.map((b) => b.name).join(', '),
      wordCount: picked.fold(0, (sum, b) => sum + b.wordCount),
      memorizedCount: picked.fold(0, (sum, b) => sum + b.memorizedCount),
      createdAt: picked.first.createdAt,
      correctCount: picked.fold(0, (sum, b) => sum + b.correctCount),
      attemptCount: picked.fold(0, (sum, b) => sum + b.attemptCount),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WordbookSelection &&
      other.ids.length == ids.length &&
      [for (var i = 0; i < ids.length; i++) other.ids[i] == ids[i]]
          .every((e) => e);

  @override
  int get hashCode => Object.hashAll(ids);
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
    this.correctCount = 0,
    this.attemptCount = 0,
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

  /// 테스트 · 게임에서 맞힌 횟수와 푼 횟수 (AD-18).
  final int correctCount;
  final int attemptCount;

  /// 정답률 0~1. 아직 푼 적이 없으면 null.
  double? get accuracy =>
      attemptCount == 0 ? null : correctCount / attemptCount;

  /// 수정 시트에 채울 내용.
  WordDraft toDraft() => WordDraft(
    word: word,
    meaning: meaning,
    pronunciation: pronunciation,
    partOfSpeech: partOfSpeech,
    contextMeaning: contextMeaning,
    sentence: sentence,
    sourceLanguage: sourceLanguage,
    targetLanguage: targetLanguage,
  );
}

/// 단어 목록 정렬 (AD-05).
enum WordSort {
  newest,
  oldest,
  alphabetical,

  /// 정답률 높은 순 · 낮은 순 (AD-18). 아직 안 푼 단어는 맨 뒤.
  accuracyHigh,
  accuracyLow,
}

/// 단어 목록 필터 (AD-18): 정답률 구간.
enum WordFilter {
  all,
  notStudied,

  /// 50% 미만
  low,

  /// 50% 이상 80% 미만
  mid,

  /// 80% 이상
  high;

  bool matches(VocabularyWord word) {
    final a = word.accuracy;
    return switch (this) {
      WordFilter.all => true,
      WordFilter.notStudied => a == null,
      WordFilter.low => a != null && a < 0.5,
      WordFilter.mid => a != null && a >= 0.5 && a < 0.8,
      WordFilter.high => a != null && a >= 0.8,
    };
  }
}

/// 단어 하나를 푼 결과 (AD-18). 테스트 · 게임이 끝날 때 쌓는다.
class WordAnswer {
  const WordAnswer(this.wordId, {required this.correct});

  final int wordId;
  final bool correct;
}

/// 저장할 단어 한 건 (AD-03): 직접 추가 · 번역 기록에서 추가에서 편집 시트가 만든다.
class WordDraft {
  const WordDraft({
    required this.word,
    required this.meaning,
    this.pronunciation,
    this.partOfSpeech,
    this.contextMeaning,
    this.sentence,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  final String word;
  final String meaning;
  final String? pronunciation;
  final String? partOfSpeech;
  final String? contextMeaning;
  final String? sentence;

  /// BCP-47 언어 코드. 모르면 "und".
  final String sourceLanguage;
  final String targetLanguage;
}
