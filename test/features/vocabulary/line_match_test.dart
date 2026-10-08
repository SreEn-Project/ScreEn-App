import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/router.dart';
import 'package:translation_poc_app/app/theme/app_theme.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/line_match.dart';
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
  group('LineMatchGame', () {
    final words = [for (var i = 1; i <= 7; i++) _word(i, 'w$i', 'm$i')];

    test('처음에는 5쌍만 보이고 나머지는 대기한다', () {
      final game = LineMatchGame.start(words, random: Random(1));
      expect(game.left, hasLength(5));
      expect(game.right, hasLength(5));
      expect(game.remaining, 7);
      expect(game.finished, isFalse);
    });

    test('맞히면 블록이 사라지고 새 쌍이 채워진다', () {
      var game = LineMatchGame.start(words, random: Random(1));
      final id = game.left.first.wordId;
      final (next, outcome) = game.attempt(id, id);
      game = next;
      expect(outcome, MatchOutcome.correct);
      expect(game.left, hasLength(5)); // 하나 지우고 하나 채움
      expect(game.pool, hasLength(1));
      expect(game.matchedCount, 1);
      expect(game.score, 1);
    });

    test('틀리면 블록은 그대로 두고 오답으로 기록하며 점수를 못 받는다', () {
      var game = LineMatchGame.start(words, random: Random(1));
      final a = game.left[0].wordId;
      final b = game.left[1].wordId;
      final (afterWrong, outcome) = game.attempt(a, b);
      expect(outcome, MatchOutcome.wrong);
      expect(afterWrong.left, hasLength(5));
      expect(afterWrong.missedIds, {a});
      game = afterWrong.attempt(a, a).$1;
      expect(game.matchedCount, 1);
      expect(game.score, 0);
    });

    test('모두 맞히면 끝나고 틀린 단어를 모아 준다', () {
      var game = LineMatchGame.start(words, random: Random(2));
      final first = game.left.first.wordId;
      game = game.attempt(first, game.right.first.wordId).$1;
      while (!game.finished) {
        final id = game.left.first.wordId;
        game = game.attempt(id, id).$1;
      }
      expect(game.matchedCount, words.length);
      expect(game.remaining, 0);
      expect(game.score + game.missedWords.length, words.length);
    });

    test('같은 뜻의 다른 단어 블록에 이어도 맞는 것으로 친다', () {
      final twins = [_word(1, 'a', '사과'), _word(2, 'b', '사과')];
      final game = LineMatchGame.start(twins, random: Random(1));
      final (_, outcome) = game.attempt(1, 2);
      expect(outcome, MatchOutcome.correct);
    });
  });

  testWidgets('드래그로 단어를 뜻에 이어 끝까지 맞힌다', (tester) async {
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
      words: [_word(1, 'apple', '사과'), _word(2, 'pear', '배')],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: fakeNativeOverrides(vocabulary: repository),
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: createRouter(
            initialLocation: AppRoutes.lineMatchPath([1]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('남은 단어 2개'), findsOneWidget);

    Future<void> connect(String word, String meaning) async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.text(word)),
      );
      await gesture.moveTo(tester.getCenter(find.text(meaning)));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
    }

    // 틀리게 한 번, 그다음 제대로.
    await connect('apple', '배');
    expect(find.text('남은 단어 2개'), findsOneWidget);
    await connect('apple', '사과');
    expect(find.text('남은 단어 1개'), findsOneWidget);
    await connect('pear', '배');

    expect(find.text('선 잇기 결과'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget); // apple은 틀렸으니 점수 없음
    expect(find.text('apple'), findsOneWidget);
  });
}
