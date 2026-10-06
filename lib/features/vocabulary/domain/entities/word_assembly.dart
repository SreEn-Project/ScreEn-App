import 'dart:math';

import 'vocabulary.dart';

/// 단어 조립 방식 (AD-13).
enum AssemblyMode {
  /// 단어를 조각낸 카드(다른 단어 조각 섞임)에서 골라 순서대로 채운다.
  pieces,

  /// 섞인 글자 카드를 끌어 올바른 순서로 정렬한다.
  letters,
}

/// 조각 · 글자 카드 하나.
class AssemblyTile {
  const AssemblyTile({required this.id, required this.text});

  /// 문제 안에서 카드를 구분하는 번호 (같은 글자 카드가 여러 개일 수 있다).
  final int id;
  final String text;
}

/// 단어 조립 문제 하나 (AD-13).
class AssemblyQuestion {
  const AssemblyQuestion({
    required this.wordId,
    required this.mode,
    required this.word,
    required this.meaning,
    required this.tiles,
    required this.answer,
  });

  final int wordId;
  final AssemblyMode mode;
  final String word;
  final String meaning;

  /// 화면에 보이는 카드 (섞인 순서). 조각 선택형은 다른 단어의 조각이 섞여 있다.
  final List<AssemblyTile> tiles;

  /// 정답 글 (소문자, 공백 없음).
  final String answer;

  AssemblyTile tile(int id) => tiles.firstWhere((t) => t.id == id);

  /// [tileIds] 순서대로 이어 붙인 글이 정답인지 (대소문자 무시).
  bool isCorrect(List<int> tileIds) =>
      tileIds.map((id) => tile(id).text).join().toLowerCase() == answer;

  /// 단어 [word]로 문제를 만든다. [others]는 조각 선택형에서 방해 조각을 뽑을 다른 단어들.
  static AssemblyQuestion build(
    VocabularyWord word,
    AssemblyMode mode, {
    Iterable<VocabularyWord> others = const [],
    required Random random,
  }) {
    final letters = _letters(word.word);
    final answer = letters.join().toLowerCase();
    final texts = mode == AssemblyMode.letters ? [...letters] : _chunk(letters);
    final realCount = texts.length;

    if (mode == AssemblyMode.pieces) {
      // 다른 단어의 조각을 방해 카드로 섞는다. 정답 조각과 같은 글은 헷갈리니 뺀다.
      final taken = texts.map((t) => t.toLowerCase()).toSet();
      final pool = <String>[];
      for (final other in others) {
        if (other.id == word.id) continue;
        for (final piece in _chunk(_letters(other.word))) {
          if (taken.add(piece.toLowerCase())) pool.add(piece);
        }
      }
      pool.shuffle(random);
      texts.addAll(pool.take(max(2, realCount ~/ 2)));
    }

    List<AssemblyTile> make() {
      final list = [
        for (var i = 0; i < texts.length; i++)
          AssemblyTile(id: i, text: texts[i]),
      ]..shuffle(random);
      return list;
    }

    var tiles = make();
    // 글자 정렬형은 섞은 결과가 이미 정답이면 한 번 더 섞는다 (글자가 2종 이상일 때만).
    if (mode == AssemblyMode.letters && texts.toSet().length > 1) {
      var guard = 0;
      while (tiles.map((t) => t.text).join().toLowerCase() == answer &&
          guard++ < 10) {
        tiles = make();
      }
    }
    return AssemblyQuestion(
      wordId: word.id,
      mode: mode,
      word: word.word,
      meaning: word.meaning,
      tiles: tiles,
      answer: answer,
    );
  }

  /// 공백을 뺀 글자들.
  static List<String> _letters(String word) => [
    for (final rune in word.runes)
      if (!_isSpace(rune)) String.fromCharCode(rune),
  ];

  static bool _isSpace(int rune) => String.fromCharCode(rune).trim().isEmpty;

  /// 글자를 2~3개씩 묶은 조각. 짧은 단어는 더 잘게 쪼갠다.
  static List<String> _chunk(List<String> letters) {
    final n = letters.length;
    final size = n <= 3 ? 1 : (n <= 6 ? 2 : 3);
    return [
      for (var i = 0; i < n; i += size)
        letters.sublist(i, min(i + size, n)).join(),
    ];
  }
}

/// 한 문제를 푼 결과.
class AssemblyResult {
  const AssemblyResult({required this.question, required this.given});

  final AssemblyQuestion question;

  /// 만든 글 (카드를 이어 붙인 것).
  final String given;

  bool get correct => given.toLowerCase() == question.answer;
}
