import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/theme/app_theme.dart';
import 'package:translation_poc_app/features/history/domain/entities/history_entry.dart';
import 'package:translation_poc_app/features/history/presentation/widgets/history_card.dart';
import 'package:translation_poc_app/l10n/app_localizations.dart';

void main() {
  final longOriginal = List.filled(40, 'The quick brown fox jumps.').join(' ');
  final longTranslated = List.filled(40, '빠른 갈색 여우가 뛴다.').join(' ');
  final entry = HistoryEntry(
    id: 1,
    original: longOriginal,
    translated: longTranslated,
    sourceLanguage: 'en',
    targetLanguage: 'ko',
    translatedAt: DateTime(2026, 10, 6, 9, 30),
  );

  Future<void> pumpCard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HistoryCard(entry: entry)),
      ),
    );
  }

  testWidgets('목록 카드는 긴 글을 줄여 보인다', (tester) async {
    await pumpCard(tester);

    final translated = tester.widget<Text>(find.text(longTranslated));
    final original = tester.widget<Text>(find.text(longOriginal));
    expect(translated.maxLines, 3);
    expect(translated.overflow, TextOverflow.ellipsis);
    expect(original.maxLines, 2);
    expect(original.overflow, TextOverflow.ellipsis);
  });

  testWidgets('카드를 탭하면 전체 글이 시트에 뜨고 복사된다', (tester) async {
    await pumpCard(tester);

    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.tap(find.byType(HistoryCard));
    await tester.pumpAndSettle();

    // 시트의 SelectableText는 줄임 없이 전체를 보여 준다.
    expect(find.byType(SelectableText), findsNWidgets(2));
    expect(find.text(longTranslated, findRichText: true), findsWidgets);

    await tester.tap(find.text('Copy').first);
    await tester.pumpAndSettle();
    expect(copied, longTranslated);
    expect(find.text('Copied'), findsOneWidget);
  });
}
