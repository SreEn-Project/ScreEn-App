import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/app.dart';

void main() {
  testWidgets('앱이 홈 화면으로 시작한다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.byType(FilledButton), findsOneWidget);
  });
}
