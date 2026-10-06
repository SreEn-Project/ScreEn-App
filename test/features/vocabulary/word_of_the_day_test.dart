import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/router.dart';
import 'package:translation_poc_app/app/theme/app_theme.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:translation_poc_app/features/vocabulary/domain/usecases/vocabulary_usecases.dart';
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

Wordbook _book() => Wordbook(
  id: 1,
  name: '영어',
  wordCount: 0,
  memorizedCount: 0,
  createdAt: DateTime(2026, 10, 1),
);

FakeVocabularyRepository _repo(List<VocabularyWord> words) =>
    FakeVocabularyRepository(books: [_book()], words: words);

void main() {
  final day = DateTime(2026, 10, 7);

  test('같은 날에는 같은 단어, skip을 올리면 다른 단어', () async {
    final useCase = GetWordOfTheDay(
      _repo([
        _word(1, 'a', 'A'),
        _word(2, 'b', 'B'),
        _word(3, 'c', 'C'),
        _word(4, 'd', 'D'),
        _word(5, 'e', 'E'),
      ]),
    );
    final first = await useCase(GetWordOfTheDayParams(day));
    final again = await useCase(GetWordOfTheDayParams(day));
    expect(again!.word.id, first!.word.id);
    final other = await useCase(GetWordOfTheDayParams(day, skip: 1));
    expect(other!.word.id, isNot(first.word.id));
    // 보기는 정답을 포함하고 서로 다르다.
    expect(first.hasQuiz, isTrue);
    expect(first.choices, contains(first.word.meaning));
    expect(first.choices.toSet().length, first.choices.length);
    expect(first.choices.length, lessThanOrEqualTo(4));
  });

  test('단어가 없으면 null, 하나뿐이면 보기가 없다', () async {
    expect(
      await GetWordOfTheDay(_repo([]))(GetWordOfTheDayParams(day)),
      isNull,
    );
    final single = await GetWordOfTheDay(_repo([_word(1, 'a', 'A')]))(
      GetWordOfTheDayParams(day),
    );
    expect(single!.hasQuiz, isFalse);
  });

  Future<void> pumpHome(
    WidgetTester tester,
    FakeVocabularyRepository repo,
  ) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: fakeNativeOverrides(vocabulary: repo),
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: createRouter(initialLocation: AppRoutes.home),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('홈의 오늘의 단어 카드에서 보기를 골라 답한다', (tester) async {
    await pumpHome(
      tester,
      _repo([
        _word(1, 'apple', '사과'),
        _word(2, 'pear', '배'),
        _word(3, 'plum', '자두'),
      ]),
    );
    expect(find.text('오늘의 단어'), findsOneWidget);
    await tester.tap(find.text('사과').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('정답'), findsOneWidget);
  });

  testWidgets('저장한 단어가 없으면 카드가 없다', (tester) async {
    await pumpHome(tester, _repo([]));
    expect(find.text('오늘의 단어'), findsNothing);
  });
}
