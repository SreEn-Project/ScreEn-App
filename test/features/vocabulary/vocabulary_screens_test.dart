import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/router.dart';
import 'package:translation_poc_app/app/theme/app_theme.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:translation_poc_app/l10n/app_localizations.dart';

import '../../fakes.dart';

final _book = Wordbook(
  id: 1,
  name: '영어',
  wordCount: 0,
  memorizedCount: 0,
  createdAt: DateTime(2026, 10, 1),
);

VocabularyWord _word(int id, String word, String meaning) => VocabularyWord(
  id: id,
  wordbookId: 1,
  word: word,
  meaning: meaning,
  pronunciation: '/ˈæp.əl/',
  partOfSpeech: 'noun',
  contextMeaning: '(과일) 사과',
  sentence: 'An apple a day keeps the doctor away.',
  sourceApp: 'Chrome',
  sourceLanguage: 'en',
  targetLanguage: 'ko',
  memorized: false,
  savedAt: DateTime(2026, 10, 6, 9, 30),
);

void main() {
  Future<FakeVocabularyRepository> pump(
    WidgetTester tester, {
    List<Wordbook> books = const [],
    List<VocabularyWord> words = const [],
    String location = AppRoutes.vocabulary,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final repository = FakeVocabularyRepository(books: books, words: words);
    await tester.pumpWidget(
      ProviderScope(
        overrides: fakeNativeOverrides(vocabulary: repository),
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: createRouter(initialLocation: location),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  testWidgets('단어장이 없으면 안내와 만들기 버튼을 보여 준다', (tester) async {
    await pump(tester);

    expect(find.text('아직 단어장이 없어요'), findsOneWidget);
    expect(find.text('새 단어장'), findsWidgets);
  });

  testWidgets('새 단어장을 만들면 목록에 나타난다', (tester) async {
    final repository = await pump(tester);

    await tester.tap(find.text('새 단어장').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '일본어');
    await tester.tap(find.text('만들기'));
    await tester.pumpAndSettle();

    expect(repository.books.map((b) => b.name), ['일본어']);
    expect(find.text('일본어'), findsOneWidget);
    expect(find.text('단어 0개'), findsOneWidget);
  });

  testWidgets('겹치는 이름으로 바꾸면 시트가 열린 채 안내한다', (tester) async {
    final repository = await pump(
      tester,
      books: [
        _book,
        Wordbook(
          id: 2,
          name: '일본어',
          wordCount: 0,
          memorizedCount: 0,
          createdAt: DateTime(2026, 10, 2),
        ),
      ],
    );

    await tester.tap(find.byTooltip('이름 변경').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '일본어');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(find.text('같은 이름의 단어장이 있어요'), findsOneWidget);
    expect(repository.books.first.name, '영어');
  });

  testWidgets('단어장을 지우면 확인 뒤 목록에서 사라진다', (tester) async {
    final repository = await pump(
      tester,
      books: [_book],
      words: [_word(1, 'apple', '사과')],
    );
    expect(find.text('단어 1개'), findsOneWidget);

    await tester.tap(find.byTooltip('삭제'));
    await tester.pumpAndSettle();
    expect(find.text('안의 단어 1개도 함께 지워져요.'), findsOneWidget);
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(repository.books, isEmpty);
    expect(repository.savedWords, isEmpty);
    expect(find.text('아직 단어장이 없어요'), findsOneWidget);
  });

  testWidgets('단어장 → 단어 → 단어 상세로 들어가 삭제한다', (tester) async {
    final repository = await pump(
      tester,
      books: [_book],
      words: [_word(1, 'apple', '사과')],
    );

    await tester.tap(find.text('영어'));
    await tester.pumpAndSettle();
    expect(find.text('apple'), findsOneWidget);

    await tester.tap(find.text('apple'));
    await tester.pumpAndSettle();
    expect(find.text('단어 상세'), findsOneWidget);
    expect(find.text('/ˈæp.əl/'), findsOneWidget);
    expect(find.text('(과일) 사과'), findsOneWidget);
    expect(find.text('An apple a day keeps the doctor away.'), findsOneWidget);
    expect(find.text('Chrome'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('단어 삭제'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('단어 삭제'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();

    expect(repository.savedWords, isEmpty);
    // 상세는 닫히고 단어장 상세의 목록에서도 사라진다.
    expect(find.text('단어 상세'), findsNothing);
    expect(find.text('이 단어장은 비어 있어요'), findsOneWidget);
  });

  testWidgets('단어장 상세에서 외운 표시를 바꾼다', (tester) async {
    final repository = await pump(
      tester,
      books: [_book],
      words: [_word(1, 'apple', '사과')],
      location: AppRoutes.wordbookPath(1),
    );

    await tester.tap(find.byTooltip('외운 단어'));
    await tester.pumpAndSettle();

    expect(repository.savedWords.single.memorized, isTrue);
  });
}
