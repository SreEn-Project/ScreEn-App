import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/app.dart';
import 'package:translation_poc_app/features/home/presentation/home_screen.dart';
import 'package:translation_poc_app/features/permission/presentation/permission_screen.dart';

void main() {
  testWidgets('첫 실행: 온보딩 → 권한 안내 → 홈', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    // 온보딩: 건너뛰기 → 언어 선택 페이지 → 시작하기
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.byType(PermissionScreen), findsOneWidget);

    // 권한 두 개를 허용해야 계속하기가 켜진다.
    await tester.tap(find.text('Open settings').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open settings').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
