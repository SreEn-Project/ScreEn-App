import 'vocabulary.dart';

/// 오늘의 단어 (AD-14): 단어 하나와 간단한 문제의 보기.
class DailyWord {
  const DailyWord({required this.word, this.choices = const []});

  final VocabularyWord word;

  /// 뜻 보기 (정답 포함, 섞임). 오답으로 쓸 다른 단어가 없으면 비어 있고, 이때는 뜻 보기 버튼으로 확인한다.
  final List<String> choices;

  bool get hasQuiz => choices.length >= 2;
}
