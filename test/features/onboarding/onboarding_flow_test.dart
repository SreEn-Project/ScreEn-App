import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/app.dart';
import 'package:translation_poc_app/features/home/presentation/screens/home_screen.dart';
import 'package:translation_poc_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:translation_poc_app/features/permission/presentation/screens/permission_screen.dart';

import '../../fakes.dart';

Future<void> _pumpApp(WidgetTester tester, List<Override> overrides) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(overrides: overrides, child: const App()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('온보딩을 마쳤으면 바로 홈이 열린다', (tester) async {
    await _pumpApp(tester, fakeNativeOverrides(onboardingCompleted: true));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('첫 실행: 고른 언어와 완료 표시를 저장하고 권한 안내로 간다', (tester) async {
    final settings = FakeSettingsRepository();
    await _pumpApp(tester, fakeNativeOverrides(settings: settings));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(settings.settings.onboardingCompleted, isFalse);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Japanese').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(settings.settings.targetLanguage, 'ja');
    expect(settings.settings.onboardingCompleted, isTrue);
    expect(find.byType(PermissionScreen), findsOneWidget);
  });
}
