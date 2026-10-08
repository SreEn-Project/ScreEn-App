import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/router.dart';
import 'package:translation_poc_app/app/theme/app_theme.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/falling_game.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:translation_poc_app/l10n/app_localizations.dart';

import '../../fakes.dart';

VocabularyWord _word(int id, String word, String meaning) => VocabularyWord(
  id: id,
  wordbookId: 1,
  word: word,
  meaning: meaning,
  sourceLanguage: 'en',
  targetLanguage: 'ko',
  memorized: false,
  savedAt: DateTime(2026, 10, 1),
);

void main() {
  group('FallingGame', () {
    final words = [_word(1, 'apple', '사과, 능금'), _word(2, 'pear', '배')];

    FallingGame game([FallingMode mode = FallingMode.meaning]) =>
        FallingGame(words: words, mode: mode, random: Random(1));

    test('시간이 지나면 블록이 나타나 떨어진다', () {
      final g = game();
      g.update(1);
      expect(g.blocks, hasLength(1));
      final y = g.blocks.first.y;
      g.update(1);
      expect(g.blocks.first.y, greaterThan(y));
    });

    test('연달아 맞히면 콤보가 쌓이고 놓치면 끊긴다', () {
      final g = game(FallingMode.spelling);
      g.update(1);
      final first = g.blocks.first;
      expect(g.submit(first.answers.first), isTrue);
      expect(g.combo, 1);
      expect(g.lastDestroyed, same(first));
      while (g.blocks.isEmpty) {
        g.update(0.5);
      }
      expect(g.submit(g.blocks.first.answers.first), isTrue);
      expect(g.combo, 2);
      expect(g.bestCombo, 2);
      // 아무것도 안 맞히고 기다리면 바닥에 떨어져 콤보가 끊긴다.
      while (g.landedNow.isEmpty && !g.over) {
        g.update(0.5);
      }
      expect(g.combo, 0);
      expect(g.bestCombo, 2);
    });

    test('속도 배율은 낙하 속도를 비례해서 바꾼다', () {
      FallingGame make(double scale) => FallingGame(
        words: words,
        mode: FallingMode.meaning,
        random: Random(1),
        speedScale: scale,
      );
      expect(make(2.0).speed, closeTo(make(1.0).speed * 2, 1e-9));
      expect(make(0.5).speed, closeTo(make(1.0).speed / 2, 1e-9));
    });

    test('같은 단어는 동시에 둘 이상 떨어지지 않는다', () {
      final g = game();
      for (var i = 0; i < 40; i++) {
        g.update(0.1);
      }
      final ids = g.blocks.map((b) => b.wordId).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('뜻 입력: 맞는 입력은 블록을 없애고 점수를 준다 (쉼표로 나뉜 뜻 하나만 써도 됨)', () {
      final g = game();
      g.update(1);
      while (g.blocks.every((b) => b.wordId != 1)) {
        g.update(0.5);
      }
      expect(g.submit('능금'), isTrue);
      expect(g.score, FallingGame.pointsPerWord);
      expect(g.destroyed, 1);
      expect(g.blocks.where((b) => b.wordId == 1), isEmpty);
      expect(g.submit('능금'), isFalse);
    });

    test('철자 입력: 대소문자와 공백을 무시한다', () {
      final g = game(FallingMode.spelling);
      g.update(1);
      final block = g.blocks.first;
      expect(block.text, anyOf('사과, 능금', '배'));
      final answer = words.firstWhere((w) => w.id == block.wordId).word;
      expect(g.submit('  ${answer.toUpperCase()} '), isTrue);
    });

    test('바닥에 닿으면 목숨이 줄고, 모두 잃으면 끝난다', () {
      final g = game();
      var guard = 0;
      while (!g.over && guard++ < 2000) {
        g.update(0.1);
      }
      expect(g.over, isTrue);
      expect(g.lives, 0);
      expect(g.missedWords, isNotEmpty);
      expect(g.blocks, isEmpty);
    });

    test('많이 없앨수록 빨라진다', () {
      final g = game();
      final before = g.speed;
      g.destroyed = 10;
      expect(g.speed, greaterThan(before));
      g.destroyed = 1000;
      expect(g.speed, lessThanOrEqualTo(FallingGame.baseSpeed * 3 + 1e-9));
    });
  });

  testWidgets('입력으로 블록을 없애다 목숨을 모두 잃으면 결과가 나온다', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final repository = FakeVocabularyRepository(
      books: [
        Wordbook(
          id: 1,
          name: '영어',
          wordCount: 0,
          memorizedCount: 0,
          createdAt: DateTime(2026, 10, 1),
        ),
      ],
      words: [_word(1, 'apple', '사과')],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: fakeNativeOverrides(vocabulary: repository),
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: createRouter(initialLocation: AppRoutes.fallingPath(1)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('시작하기'));
    await tester.pump();
    for (var i = 0; i < 30 && find.text('apple').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 첫 단어가 떨어지는 중 — 뜻을 입력하면 사라지고 점수가 오른다.
    expect(find.text('apple'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '사과');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('apple'), findsNothing);
    expect(find.text('점수 10'), findsOneWidget);

    // 더는 입력하지 않으면 블록이 바닥에 닿아 목숨을 잃고 끝난다.
    for (
      var i = 0;
      i < 400 && find.text('하강형 타이핑 결과').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
    expect(find.text('하강형 타이핑 결과'), findsOneWidget);
    expect(find.text('놓친 단어'), findsOneWidget);
  });
}
