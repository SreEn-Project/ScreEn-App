import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:translation_poc_app/app/theme/app_theme.dart';
import 'package:translation_poc_app/core/ui/ui.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('AppNotice는 메시지를 보여 준다', (tester) async {
    await tester.pumpWidget(_host(const AppNotice.error('실패했어요')));
    expect(find.text('실패했어요'), findsOneWidget);
    expect(find.byIcon(Symbols.error_rounded), findsOneWidget);
  });

  testWidgets('AppEmptyState는 제목 · 설명 · 동작을 보여 준다', (tester) async {
    await tester.pumpWidget(
      _host(
        AppEmptyState(
          icon: Symbols.history_rounded,
          title: '비었어요',
          message: '설명',
          action: AppButton(label: '다시', onPressed: () {}),
        ),
      ),
    );
    expect(find.text('비었어요'), findsOneWidget);
    expect(find.text('설명'), findsOneWidget);
    expect(find.text('다시'), findsOneWidget);
  });

  testWidgets('AppToast는 뜨고 시간이 지나면 사라진다', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    AppToast.show(context, '저장했어요');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('저장했어요'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.text('저장했어요'), findsNothing);
  });

  testWidgets('showAppConfirm은 확인하면 true', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    final result = showAppConfirm(
      context,
      title: '지울까요?',
      confirmLabel: '지우기',
      cancelLabel: '취소',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('지우기'));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });
}
