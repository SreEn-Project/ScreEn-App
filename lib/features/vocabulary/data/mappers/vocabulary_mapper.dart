import '../../../../core/bridge/translator_api.g.dart' as pigeon;
import '../../domain/entities/vocabulary.dart';

// Pigeon 타입 ↔ 도메인 엔티티. 도메인은 Pigeon을 모른다 (D-018).

extension WordbookMapper on pigeon.Wordbook {
  Wordbook toEntity() => Wordbook(
    id: id,
    name: name,
    wordCount: wordCount,
    memorizedCount: memorizedCount,
    correctCount: correctCount,
    attemptCount: attemptCount,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
  );
}

extension VocabWordMapper on pigeon.VocabWord {
  VocabularyWord toEntity() => VocabularyWord(
    id: id,
    wordbookId: wordbookId,
    word: word,
    meaning: meaning,
    pronunciation: pronunciation,
    partOfSpeech: partOfSpeech,
    contextMeaning: contextMeaning,
    sentence: sentence,
    sourceApp: sourceApp,
    sourceLanguage: sourceLanguage,
    targetLanguage: targetLanguage,
    memorized: memorized,
    savedAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    correctCount: correctCount,
    attemptCount: attemptCount,
  );
}

extension WordSortMapper on WordSort {
  pigeon.VocabSort toPigeon() => switch (this) {
    WordSort.newest => pigeon.VocabSort.newest,
    WordSort.oldest => pigeon.VocabSort.oldest,
    WordSort.alphabetical => pigeon.VocabSort.alphabetical,
    // 정답률 정렬은 GetWords 유스케이스가 하므로 저장소에는 최신순으로 요청한다.
    WordSort.accuracyHigh || WordSort.accuracyLow => pigeon.VocabSort.newest,
  };
}

extension WordDraftMapper on WordDraft {
  pigeon.VocabWordInput toPigeon() => pigeon.VocabWordInput(
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

extension WordAnswerMapper on WordAnswer {
  pigeon.WordAnswer toPigeon() =>
      pigeon.WordAnswer(wordId: wordId, correct: correct);
}
