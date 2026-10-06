/// 암기 테스트 방식 (AD-09).
enum WordTestMode {
  /// 뜻을 보고 단어를 직접 입력한다.
  typing,

  /// 단어를 보고 보기 4개 중 뜻을 고른다.
  choice,
}

/// 테스트 문제 하나 (AD-09).
class WordTestQuestion {
  const WordTestQuestion({
    required this.wordId,
    required this.mode,
    required this.word,
    required this.meaning,
    this.choices = const [],
  });

  final int wordId;
  final WordTestMode mode;
  final String word;
  final String meaning;

  /// 4지선다 보기(뜻). 정답이 섞여 있다. 입력형은 비어 있다.
  final List<String> choices;

  /// 문제로 보여 줄 글: 입력형은 뜻, 4지선다형은 단어.
  String get prompt => mode == WordTestMode.typing ? meaning : word;

  /// 정답: 입력형은 단어, 4지선다형은 뜻.
  String get expected => mode == WordTestMode.typing ? word : meaning;

  /// 입력형은 대소문자와 앞뒤 공백을 무시하고 비교한다.
  bool isCorrect(String answer) => mode == WordTestMode.typing
      ? _normalize(answer) == _normalize(word)
      : answer == meaning;

  static String _normalize(String text) => text.trim().toLowerCase();
}

/// 풀이 결과 한 건.
class WordTestAnswer {
  const WordTestAnswer({required this.question, required this.answer});

  final WordTestQuestion question;

  /// 입력한 글 또는 고른 보기. 비워 둔 채 넘기면 빈 문자열.
  final String answer;

  bool get correct => question.isCorrect(answer);
}
