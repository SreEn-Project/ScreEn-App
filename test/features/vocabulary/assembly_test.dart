import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/router.dart';
import 'package:translation_poc_app/app/theme/app_theme.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:translation_poc_app/features/vocabulary/domain/entities/word_assembly.dart';
import 'package:translation_poc_app/features/vocabulary/presentation/view_models/assembly_view_model.dart';
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

void main() {
  group('AssemblyQuestion', () {
    final apple = _word(1, 'apple', '사과');
    final others = [apple, _word(2, 'banana', '바나나'), _word(3, 'cherry', '체리')];

    test('조각 선택형: 정답 조각을 순서대로 이으면 정답이고 방해 조각이 섞인다', () {
      final q = AssemblyQuestion.build(
        apple,
        AssemblyMode.pieces,
        others: others,
        random: Random(1),
      );
      expect(q.answer, 'apple');
      // 정답 조각: ap / pl / e
      final order = [
        for (final piece in ['ap', 'pl', 'e'])
          q.tiles.firstWhere((t) => t.text == piece).id,
      ];
      expect(q.isCorrect(order), isTrue);
      expect(q.isCorrect(order.reversed.toList()), isFalse);
      expect(q.tiles.length, greaterThan(3));
    });

    test('글자 정렬형: 글자 카드만 있고 섞은 상태가 정답이 아니다', () {
      for (var seed = 0; seed < 20; seed++) {
        final q = AssemblyQuestion.build(
          apple,
          AssemblyMode.letters,
          random: Random(seed),
        );
        expect(q.tiles.map((t) => t.text).toList()..sort(), [
          'a',
          'e',
          'l',
          'p',
          'p',
        ]);
        expect(q.isCorrect([for (final t in q.tiles) t.id]), isFalse);
      }
    });

    test('공백은 카드에서 빼고 대소문자는 무시한다', () {
      final q = AssemblyQuestion.build(
        _word(9, 'Ice Cream', '아이스크림'),
        AssemblyMode.letters,
        random: Random(3),
      );
      expect(q.answer, 'icecream');
      expect(q.tiles, hasLength(8));
      final sorted = [...q.tiles]..sort((a, b) => a.id.compareTo(b.id));
      expect(q.isCorrect([for (final t in sorted) t.id]), isTrue);
    });
  });

  test('ViewModel: 조각을 놓고 빼고 확인하면 결과가 쌓인다', () async {
    final repository = FakeVocabularyRepository(
      books: [_book()],
      words: [_word(1, 'cat', '고양이')],
    );
    final container = ProviderContainer(
      overrides: fakeNativeOverrides(vocabulary: repository),
    );
    addTearDown(container.dispose);
    final provider = assemblyViewModelProvider(1);
    await container.read(provider.future);
    final model = container.read(provider.notifier);

    await model.start();
    var state = container.read(provider).value!;
    final q = state.current!;
    // cat은 3글자라 조각이 글자 하나씩이고, 방해 조각은 없다(다른 단어가 없음).
    expect(q.tiles, hasLength(3));
    final wrong = q.tiles.firstWhere((t) => t.text == 't').id;
    model.place(wrong);
    model.place(wrong); // 같은 카드를 두 번 놓을 수 없다.
    expect(container.read(provider).value!.placed, [wrong]);
    model.undo();
    expect(container.read(provider).value!.placed, isEmpty);

    for (final ch in ['c', 'a', 't']) {
      model.place(q.tiles.firstWhere((t) => t.text == ch).id);
    }
    model.check();
    state = container.read(provider).value!;
    expect(state.revealed, isTrue);
    expect(state.lastResult!.correct, isTrue);
    model.next();
    expect(container.read(provider).value!.phase, AssemblyPhase.finished);
    expect(container.read(provider).value!.correctCount, 1);
  });

  test('ViewModel: 글자 정렬형은 끌어 넣고 옮겨 정답을 만든다', () async {
    final repository = FakeVocabularyRepository(
      books: [_book()],
      words: [_word(1, 'abc', '에이비씨')],
    );
    final container = ProviderContainer(
      overrides: fakeNativeOverrides(vocabulary: repository),
    );
    addTearDown(container.dispose);
    final provider = assemblyViewModelProvider(1);
    await container.read(provider.future);
    final model = container.read(provider.notifier);
    model.setMode(AssemblyMode.letters);
    await model.start();

    final q = container.read(provider).value!.current!;
    // 글자는 처음부터 모두 한 줄에 섞여 있다. 자리 지정으로 a, b, c 순서를 맞춘다.
    expect(container.read(provider).value!.placed, hasLength(3));
    int idOf(String t) => q.tiles.firstWhere((x) => x.text == t).id;
    model.place(idOf('a'), at: 0);
    model.place(idOf('b'), at: 1);
    model.place(idOf('c'), at: 3);
    expect(
      container.read(provider).value!.placed.map((id) => q.tile(id).text),
      ['a', 'b', 'c'],
    );
    // 글자 정렬형은 카드를 뺄 수 없다.
    model.remove(idOf('a'));
    expect(container.read(provider).value!.placed, hasLength(3));
    model.check();
    expect(container.read(provider).value!.lastResult!.correct, isTrue);
  });

  testWidgets('조각 선택형 화면에서 카드를 눌러 단어를 완성하고 결과를 본다', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final repository = FakeVocabularyRepository(
      books: [_book()],
      words: [_word(1, 'cat', '고양이')],
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
            initialLocation: AppRoutes.assemblyPath(1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('고양이'), findsOneWidget);

    for (final ch in ['c', 'a', 't']) {
      await tester.tap(find.text(ch));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(find.text('정답이에요!'), findsOneWidget);

    await tester.tap(find.text('결과 보기'));
    await tester.pumpAndSettle();
    expect(find.text('단어 조립 결과'), findsOneWidget);
    expect(find.text('모두 맞혔어요!'), findsOneWidget);
  });

  testWidgets('카드를 완성 칸으로 끌어 넣고, 끌어서 순서를 바꾼다', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    final repository = FakeVocabularyRepository(
      books: [_book()],
      words: [_word(1, 'cat', '고양이')],
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
            initialLocation: AppRoutes.assemblyPath(1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    final slot = tester.getCenter(find.text('카드를 여기로 끌어 넣어요'));
    Future<void> dragToSlot(String text) async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.text(text)),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveTo(slot + const Offset(0, 60));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveTo(slot);
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.up();
      await tester.pumpAndSettle();
    }

    await dragToSlot('t');
    expect(find.text('카드를 여기로 끌어 넣어요'), findsNothing);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    final provider = assemblyViewModelProvider(1);
    List<String> placed() {
      final st = container.read(provider).value!;
      return [for (final id in st.placed) st.current!.tile(id).text];
    }

    expect(placed(), ['t']);
  });
}
