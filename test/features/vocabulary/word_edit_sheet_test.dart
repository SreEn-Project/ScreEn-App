import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/router.dart';
import 'package:translation_poc_app/app/theme/app_theme.dart';
import 'package:translation_poc_app/features/history/domain/entities/history_entry.dart';
import 'package:translation_poc_app/features/history/presentation/widgets/history_detail_sheet.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:translation_poc_app/features/vocabulary/presentation/widgets/word_edit_sheet.dart';
import 'package:translation_poc_app/l10n/app_localizations.dart';

import '../../fakes.dart';

final _book = Wordbook(
  id: 1,
  name: '영어',
  wordCount: 0,
  memorizedCount: 0,
  createdAt: DateTime(2026, 10, 1),
);

void main() {
  Future<FakeVocabularyRepository> pump(
    WidgetTester tester, {
    required Widget Function() home,
    List<Wordbook> books = const [],
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final repository = FakeVocabularyRepository(books: books);
    await tester.pumpWidget(
      ProviderScope(
        overrides: fakeNativeOverrides(vocabulary: repository),
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  testWidgets('단어장 상세의 + 로 단어를 직접 추가한다', (tester) async {
    final repository = FakeVocabularyRepository(books: [_book]);
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: fakeNativeOverrides(vocabulary: repository),
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: createRouter(
            initialLocation: AppRoutes.wordbookPath(1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('단어 추가'));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(WordEditSheet),
      matching: find.byType(TextField),
    );
    // 처음엔 단어 · 뜻만 보이고 발음 등은 + 칩을 눌러야 나타난다.
    expect(fields, findsNWidgets(2));
    expect(find.text('발음'), findsOneWidget);
    await tester.enterText(fields.at(0), 'apple');
    await tester.enterText(fields.at(1), '사과');
    await tester.tap(find.text('발음'));
    await tester.pumpAndSettle();
    expect(fields, findsNWidgets(3));
    expect(find.text('발음'), findsNothing); // 펼친 항목은 칩에서 빠진다.
    await tester.enterText(fields.at(2), '/ˈæp.əl/');
    // 추가한 항목은 ×로 비우고 접어 추가하기 전으로 돌릴 수 있다.
    await tester.tap(find.byTooltip('빼기'));
    await tester.pumpAndSettle();
    expect(fields, findsNWidgets(2));
    expect(find.text('발음'), findsOneWidget);
    await tester.tap(find.text('발음'));
    await tester.pumpAndSettle();
    await tester.enterText(fields.at(2), '/ˈæp.əl/');
    await tester.pump();
    await tester.tap(find.text('저장').last);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('‘영어’에 저장했어요'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final saved = repository.savedWords.single;
    expect(saved.word, 'apple');
    expect(saved.meaning, '사과');
    expect(saved.pronunciation, '/ˈæp.əl/');
    expect(saved.wordbookId, 1);
    // 목록에도 바로 나타난다.
    expect(find.text('apple'), findsOneWidget);
  });

  testWidgets('단어나 뜻이 비면 저장 버튼이 눌리지 않는다', (tester) async {
    final repository = FakeVocabularyRepository(books: [_book]);
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: fakeNativeOverrides(vocabulary: repository),
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: createRouter(
            initialLocation: AppRoutes.wordbookPath(1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('단어 추가'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find
          .descendant(
            of: find.byType(WordEditSheet),
            matching: find.byType(TextField),
          )
          .first,
      'apple',
    );
    await tester.pump();
    await tester.tap(find.text('저장').last);
    await tester.pumpAndSettle();

    expect(repository.savedWords, isEmpty);
  });

  testWidgets('기록 상세에서 고른 글로 단어 편집 시트가 채워진다', (tester) async {
    final entry = HistoryEntry(
      id: 1,
      original: 'An apple a day',
      translated: '하루 한 개의 사과',
      sourceLanguage: 'en',
      targetLanguage: 'ko',
      translatedAt: DateTime(2026, 10, 6, 9, 30),
    );
    final repository = await pump(
      tester,
      books: [_book],
      home: () => Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => HistoryDetailSheet.show(context, entry),
            child: const Text('열기'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('단어장에 추가'));
    await tester.pumpAndSettle();

    // 고른 글이 없으면 단어 · 뜻은 비어 있고 짧은 원문이 예문으로 들어간다.
    expect(find.text('기록에서 단어 추가'), findsOneWidget);
    expect(find.text('An apple a day'), findsWidgets);
    await tester.enterText(
      find
          .descendant(
            of: find.byType(WordEditSheet),
            matching: find.byType(TextField),
          )
          .first,
      'apple',
    );
    await tester.enterText(find.byType(TextField).at(1), '사과');
    await tester.pump();
    await tester.tap(find.text('저장').last);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final saved = repository.savedWords.single;
    expect(saved.sentence, 'An apple a day');
    expect(saved.sourceLanguage, 'en');
    expect(saved.targetLanguage, 'ko');
  });

  testWidgets('저장할 단어장은 목록 시트에서 골라 바꾼다', (tester) async {
    final second = Wordbook(
      id: 2,
      name: '일본어',
      wordCount: 0,
      memorizedCount: 0,
      createdAt: DateTime(2026, 10, 2),
    );
    final repository = FakeVocabularyRepository(books: [_book, second]);
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: fakeNativeOverrides(vocabulary: repository),
        child: MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('ko'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: createRouter(
            initialLocation: AppRoutes.wordbookPath(1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('단어 추가'));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(WordEditSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'りんご');
    await tester.enterText(fields.at(1), '사과');
    await tester.pump();

    // 단어장 칸을 눌러 목록 시트에서 다른 단어장을 고른다.
    await tester.tap(find.text('영어').last);
    await tester.pumpAndSettle();
    expect(find.text('새 단어장'), findsOneWidget);
    await tester.tap(find.text('일본어').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('저장').last);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(repository.savedWords.single.wordbookId, 2);
  });
}
