import 'dart:math';

import 'vocabulary.dart';

/// 하강형 타이핑 방식 (AD-12).
enum FallingMode {
  /// 단어가 떨어진다. 뜻을 입력한다.
  meaning,

  /// 뜻이 떨어진다. 단어(철자)를 입력한다.
  spelling,
}

/// 하강형 난이도 (AD-17): 낙하 속도와 블록이 나오는 간격에 곱한다.
enum FallingDifficulty {
  easy(0.7),
  normal(1.0),
  hard(1.45);

  const FallingDifficulty(this.factor);

  final double factor;
}

/// 떨어지는 블록 하나 (AD-12).
class FallingBlock {
  FallingBlock({
    required this.id,
    required this.wordId,
    required this.text,
    required this.answers,
    required this.lane,
  });

  final int id;
  final int wordId;

  /// 블록에 적힌 글 (방식에 따라 단어 또는 뜻).
  final String text;

  /// 맞는 입력들 (소문자 · 앞뒤 공백 제거). 뜻은 쉼표 · 세미콜론 · 슬래시로 나뉜 조각도 맞다.
  final List<String> answers;

  /// 가로 위치, 0(왼쪽 끝)~1(오른쪽 끝).
  final double lane;

  /// 세로 위치, 0(맨 위)~1(바닥).
  double y = 0;
}

/// 하강형 타이핑 게임 규칙 (AD-12). 화면의 시계가 [update]를 계속 불러 진행시킨다.
/// 화면 없이 테스트하려고 순수 Dart로 두었다.
class FallingGame {
  FallingGame({
    required this.words,
    required this.mode,
    Random? random,
    this.maxLives = 3,
    this.difficulty = FallingDifficulty.normal,
    this.timeLimit = 0,
  }) : _random = random ?? Random(),
       lives = maxLives {
    assert(words.isNotEmpty);
    _refill();
  }

  static const maxOnScreen = 4;

  /// 처음 낙하 속도 (화면 높이 / 초).
  static const baseSpeed = 0.11;
  static const maxSpeedFactor = 3.0;
  static const pointsPerWord = 10;

  final List<VocabularyWord> words;
  final FallingMode mode;
  final int maxLives;
  final Random _random;
  final FallingDifficulty difficulty;

  /// 제한 시간(초). 0이면 목숨이 다 떨어질 때까지.
  final int timeLimit;

  /// 지금까지 흐른 시간(초).
  double elapsed = 0;

  final List<FallingBlock> blocks = [];
  final List<VocabularyWord> _queue = [];
  final Set<int> missedIds = {};
  int lives;
  int score = 0;

  /// 파괴한 블록 수.
  int destroyed = 0;

  /// 이어서 맞힌 수 (놓치면 0으로 돌아간다) · 가장 길었던 기록.
  int combo = 0;
  int bestCombo = 0;

  /// 방금 [submit]으로 파괴한 블록 (효과를 그릴 위치용).
  FallingBlock? lastDestroyed;

  /// 직전 [update]에서 바닥에 떨어진 블록들.
  final List<FallingBlock> landedNow = [];
  int _nextBlockId = 0;
  double _untilSpawn = 0.6;

  bool get timeUp => timeLimit > 0 && elapsed >= timeLimit;

  bool get over => lives <= 0 || timeUp;

  /// 남은 시간(초, 올림). 제한이 없으면 null.
  int? get secondsLeft =>
      timeLimit == 0 ? null : (timeLimit - elapsed).ceil().clamp(0, timeLimit);

  List<VocabularyWord> get missedWords => [
    for (final w in words)
      if (missedIds.contains(w.id)) w,
  ];

  /// 진행할수록 빨라지는 낙하 속도 (화면 높이 / 초).
  double get speed =>
      baseSpeed * difficulty.factor * min(maxSpeedFactor, 1 + destroyed * 0.06);

  double get _spawnInterval =>
      max(1.1, 2.6 - destroyed * 0.08) / difficulty.factor;

  void _refill() => _queue
    ..addAll(words)
    ..shuffle(_random);

  static String normalize(String text) => text.trim().toLowerCase();

  List<String> _answersOf(VocabularyWord word) {
    if (mode == FallingMode.spelling) return [normalize(word.word)];
    final full = normalize(word.meaning);
    final pieces = word.meaning
        .split(RegExp('[,;/]'))
        .map(normalize)
        .where((p) => p.isNotEmpty);
    return {full, ...pieces}.toList();
  }

  void _spawn() {
    // 이미 떨어지는 단어는 건너뛰고 다음 단어를 쓴다. 모두 떨어지는 중이면 이번엔 거른다.
    for (var tries = 0; tries < words.length; tries++) {
      if (_queue.isEmpty) _refill();
      final word = _queue.removeAt(0);
      if (blocks.any((b) => b.wordId == word.id)) {
        _queue.add(word);
        continue;
      }
      // 가로 4칸 중 위쪽에 블록이 없는 칸을 고른다.
      const lanes = [0.0, 1 / 3, 2 / 3, 1.0];
      final free = [
        for (final l in lanes)
          if (!blocks.any((b) => (b.lane - l).abs() < 0.2 && b.y < 0.25)) l,
      ];
      final pool = free.isEmpty ? lanes : free;
      blocks.add(
        FallingBlock(
          id: _nextBlockId++,
          wordId: word.id,
          text: mode == FallingMode.meaning ? word.word : word.meaning,
          answers: _answersOf(word),
          lane: pool[_random.nextInt(pool.length)],
        ),
      );
      return;
    }
  }

  /// [seconds]만큼 시간을 흘린다.
  void update(double seconds) {
    landedNow.clear();
    if (over) return;
    elapsed += seconds;
    for (final b in blocks) {
      b.y += speed * seconds;
    }
    final landed = blocks.where((b) => b.y >= 1).toList();
    landedNow.addAll(landed);
    for (final b in landed) {
      blocks.remove(b);
      missedIds.add(b.wordId);
      lives--;
      combo = 0;
    }
    if (over) {
      blocks.clear();
      return;
    }
    _untilSpawn -= seconds;
    if (_untilSpawn <= 0 && blocks.length < maxOnScreen) {
      _spawn();
      _untilSpawn = _spawnInterval;
    } else if (_untilSpawn <= 0) {
      _untilSpawn = 0.3;
    }
  }

  /// 입력한 글이 떨어지는 블록의 정답과 같으면 가장 아래 블록을 파괴한다. 파괴했으면 true.
  bool submit(String text) {
    if (over) return false;
    final input = normalize(text);
    if (input.isEmpty) return false;
    FallingBlock? hit;
    for (final b in blocks) {
      if (b.answers.contains(input) && (hit == null || b.y > hit.y)) hit = b;
    }
    if (hit == null) return false;
    blocks.remove(hit);
    lastDestroyed = hit;
    combo++;
    if (combo > bestCombo) bestCombo = combo;
    destroyed++;
    score += pointsPerWord;
    return true;
  }
}
