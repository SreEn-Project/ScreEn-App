import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/app.dart';
import 'package:translation_poc_app/app/router.dart';

import '../../fakes.dart';

void main() {
  testWidgets('정보 화면에 앱 버전이 보이고 라이선스 화면이 열린다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: fakeNativeOverrides(onboardingCompleted: true),
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    // 홈이 열린 뒤 정보 화면으로 이동한다.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    container.read(routerProvider).push(AppRoutes.about);
    await tester.pumpAndSettle();

    expect(find.text('Version 1.2.3 (45)'), findsOneWidget);

    await tester.tap(find.text('Open source licenses'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
  });
}
