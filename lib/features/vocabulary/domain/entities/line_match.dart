import 'dart:math';

import 'vocabulary.dart';

/// 선 잇기 블록 하나 (AD-11). 왼쪽 열은 단어, 오른쪽 열은 뜻이다. [wordId]는 원래 단어의 id.
class MatchBlock {
  const MatchBlock({required this.wordId, required this.text});

  final int wordId;
  final String text;
}

/// 선 잇기 시도 결과 (AD-11).
enum MatchOutcome { correct, wrong }

/// 선 잇기 게임 (AD-11): 화면에는 한 번에 최대 [visible]쌍이 보이고, 맞힐 때마다 아래에서 새 쌍이 채워진다.
/// 단어장의 단어를 모두 맞히면 끝난다. 변하지 않는 값이라 시도할 때마다 새 게임을 돌려준다.
class LineMatchGame {
  const LineMatchGame._({
    required this.words,
    required this.left,
    required this.right,
    required this.pool,
    required this.matchedCount,
    required this.score,
    required this.missedIds,
    required this.wrongCount,
    required this.visible,
    required this.random,
  });

  /// 한 화면에 쌓이는 쌍의 수.
  static const defaultVisible = 5;

  factory LineMatchGame.start(
    List<VocabularyWord> words, {
    int visible = defaultVisible,
    Random? random,
  }) {
    final rng = random ?? Random();
    final shuffled = [...words]..shuffle(rng);
    final shown = shuffled.take(visible).toList();
    return LineMatchGame._(
      words: shuffled,
      left: [for (final w in shown) MatchBlock(wordId: w.id, text: w.word)],
      right: ([for (final w in shown) MatchBlock(wordId: w.id, text: w.meaning)]
        ..shuffle(rng)),
      pool: shuffled.skip(visible).toList(),
      matchedCount: 0,
      score: 0,
      missedIds: const {},
      wrongCount: 0,
      visible: visible,
      random: rng,
    );
  }

  /// 이번 판에 쓰는 모든 단어 (무작위 순서).
  final List<VocabularyWord> words;
  final List<MatchBlock> left;
  final List<MatchBlock> right;

  /// 아직 화면에 안 나온 단어.
  final List<VocabularyWord> pool;
  final int matchedCount;

  /// 처음 시도에 맞힌 단어 수 (점수).
  final int score;

  /// 한 번이라도 틀린 단어의 id.
  final Set<int> missedIds;
  final int wrongCount;
  final int visible;
  final Random random;

  int get total => words.length;

  /// 아직 못 맞힌 단어 수 (화면에 있는 것 + 아직 안 나온 것).
  int get remaining => left.length + pool.length;
  bool get finished => left.isEmpty;

  List<VocabularyWord> get missedWords => [
    for (final w in words)
      if (missedIds.contains(w.id)) w,
  ];

  /// 단어 블록 [wordId]를 뜻 블록 [meaningOwnerId]에 이었을 때의 결과.
  /// 같은 뜻을 가진 다른 단어의 블록에 이어도 맞는 것으로 친다.
  (LineMatchGame, MatchOutcome) attempt(int wordId, int meaningOwnerId) {
    final word = left.where((b) => b.wordId == wordId).firstOrNull;
    final meaning = right.where((b) => b.wordId == meaningOwnerId).firstOrNull;
    if (word == null || meaning == null) return (this, MatchOutcome.wrong);

    final original = words.firstWhere((w) => w.id == wordId);
    final correct =
        wordId == meaningOwnerId || _same(original.meaning, meaning.text);
    if (!correct) {
      return (
        _copy(missedIds: {...missedIds, wordId}, wrongCount: wrongCount + 1),
        MatchOutcome.wrong,
      );
    }

    final newLeft = [...left]..removeWhere((b) => b.wordId == wordId);
    final newRight = [...right]..removeWhere((b) => b.wordId == meaningOwnerId);
    final newPool = [...pool];
    // 빈 자리를 아래에서부터 새 쌍으로 채운다. 뜻은 아무 자리에나 끼워 넣는다.
    if (newPool.isNotEmpty) {
      final next = newPool.removeAt(0);
      newLeft.add(MatchBlock(wordId: next.id, text: next.word));
      newRight.insert(
        random.nextInt(newRight.length + 1),
        MatchBlock(wordId: next.id, text: next.meaning),
      );
    }
    final matched = matchedCount + 1;
    // 한 묶음(visible쌍)을 맞힐 때마다 남은 블록을 한 번 섞는다.
    if (matched % visible == 0) {
      newLeft.shuffle(random);
      newRight.shuffle(random);
    }
    return (
      _copy(
        left: newLeft,
        right: newRight,
        pool: newPool,
        matchedCount: matched,
        score: missedIds.contains(wordId) ? score : score + 1,
      ),
      MatchOutcome.correct,
    );
  }

  static bool _same(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  LineMatchGame _copy({
    List<MatchBlock>? left,
    List<MatchBlock>? right,
    List<VocabularyWord>? pool,
    int? matchedCount,
    int? score,
    Set<int>? missedIds,
    int? wrongCount,
  }) => LineMatchGame._(
    words: words,
    left: left ?? this.left,
    right: right ?? this.right,
    pool: pool ?? this.pool,
    matchedCount: matchedCount ?? this.matchedCount,
    score: score ?? this.score,
    missedIds: missedIds ?? this.missedIds,
    wrongCount: wrongCount ?? this.wrongCount,
    visible: visible,
    random: random,
  );
}
