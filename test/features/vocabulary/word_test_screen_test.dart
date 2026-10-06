import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/router.dart';
import 'package:translation_poc_app/app/theme/app_theme.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:translation_poc_app/l10n/app_localizations.dart';

import '../../fakes.dart';

Wordbook _book(int id, String name) => Wordbook(
  id: id,
  name: name,
  wordCount: 0,
  memorizedCount: 0,
  createdAt: DateTime(2026, 10, 1),
);

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
  testWidgets('학습 시작에서 단어장을 골라 입력형 테스트를 끝까지 푼다', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final repository = FakeVocabularyRepository(
      books: [_book(1, '영어')],
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
          routerConfig: createRouter(initialLocation: AppRoutes.learning),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 단어가 1개뿐이라 4지선다는 안 되고 입력형으로 시작한다.
    expect(find.text('카드 학습'), findsOneWidget);
    await tester.tap(find.text('암기 테스트'));
    await tester.pumpAndSettle();
    expect(find.textContaining('4지선다는'), findsOneWidget);
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    expect(find.text('사과'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '  APPLE ');
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(find.text('정답이에요!'), findsOneWidget);

    await tester.tap(find.text('결과 보기'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text('모두 맞혔어요!'), findsOneWidget);
  });
}
