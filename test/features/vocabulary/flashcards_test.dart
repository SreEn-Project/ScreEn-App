import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/router.dart';
import 'package:translation_poc_app/app/theme/app_theme.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:translation_poc_app/features/vocabulary/presentation/view_models/flashcards_view_model.dart';
import 'package:translation_poc_app/l10n/app_localizations.dart';

import '../../fakes.dart';

Wordbook _book() => Wordbook(
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
  sourceLanguage: 'en',
  targetLanguage: 'ko',
  memorized: false,
  savedAt: DateTime(2026, 10, 1),
);

void main() {
  test('넘긴 카드는 외움 · 못 외움으로 나뉘고 단어장에 반영된다', () async {
    final repository = FakeVocabularyRepository(
      books: [_book()],
      words: [_word(1, 'apple', '사과'), _word(2, 'pear', '배')],
    );
    final container = ProviderContainer(
      overrides: fakeNativeOverrides(vocabulary: repository),
    );
    addTearDown(container.dispose);
    final provider = flashcardsViewModelProvider(1);
    await container.read(provider.future);
    final model = container.read(provider.notifier);

    final first = container.read(provider).value!.current!;
    await model.mark(memorized: true);
    await model.mark(memorized: false);

    final state = container.read(provider).value!;
    expect(state.finished, isTrue);
    expect(state.known.map((w) => w.id), [first.id]);
    expect(state.unknown, hasLength(1));
    expect(
      repository.savedWords.firstWhere((w) => w.id == first.id).memorized,
      isTrue,
    );

    model.reviewUnknown();
    final review = container.read(provider).value!;
    expect(review.deck.map((w) => w.id), state.unknown.map((w) => w.id));
    expect(review.finished, isFalse);
  });

  testWidgets('카드를 뒤집고 버튼으로 넘겨 결과에서 못 외운 단어를 다시 본다', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final repository = FakeVocabularyRepository(
      books: [_book()],
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
          routerConfig: createRouter(
            initialLocation: AppRoutes.flashcardsPath(1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('apple'), findsOneWidget);
    await tester.tap(find.text('apple'));
    await tester.pumpAndSettle();
    expect(find.text('사과'), findsOneWidget);

    await tester.tap(find.text('못 외웠어요'));
    await tester.pumpAndSettle();
    expect(find.text('카드 학습 결과'), findsOneWidget);
    expect(find.text('못 외운 단어만 다시 보기'), findsOneWidget);

    await tester.tap(find.text('못 외운 단어만 다시 보기'));
    await tester.pumpAndSettle();
    expect(find.text('apple'), findsOneWidget);

    // 오른쪽으로 밀면 외움.
    await tester.drag(find.text('apple'), const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(find.text('모두 외웠어요!'), findsOneWidget);
    expect(repository.savedWords.single.memorized, isTrue);
  });
}
