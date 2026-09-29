// 화면 스크린샷 생성 (UI 검증용). 기본 테스트에서는 건너뛴다.
// 실행: flutter test --run-skipped -t screenshot test/screenshots
// 결과: build/screenshots/*.png (Windows 한글 글꼴 · 아이콘 글꼴을 불러와 실제에 가깝게 그린다)
@Tags(['screenshot'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/router.dart';
import 'package:translation_poc_app/app/theme/app_theme.dart';
import 'package:translation_poc_app/features/about/presentation/about_screen.dart';
import 'package:translation_poc_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:translation_poc_app/features/permission/presentation/permission_screen.dart';
import 'package:translation_poc_app/l10n/app_localizations.dart';

const _outDir = 'build/screenshots';
const _phone = Size(412, 915);

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final bytes = file.readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

String _pubCacheIconFont() {
  final cache = Directory(
    '${Platform.environment['LOCALAPPDATA']}/Pub/Cache/hosted/pub.dev',
  );
  final dir =
      cache
          .listSync()
          .whereType<Directory>()
          .where((d) => d.path.contains('material_symbols_icons-'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return '${dir.last.path}/lib/fonts/MaterialSymbolsRounded.ttf';
}

Widget _wrap(Widget child, {ThemeMode mode = ThemeMode.light}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: mode,
  locale: const Locale('ko'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

/// 실제 라우터(하단 탭 포함)로 [location] 화면을 연다.
Widget _route(String location, {ThemeMode mode = ThemeMode.light}) =>
    MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      locale: const Locale('ko'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: createRouter(initialLocation: location),
    );

Future<void> _shoot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
  final boundary = tester.renderObject(
    find.byType(RepaintBoundary).first,
  ) as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$_outDir/$name.png')..createSync(recursive: true);
    file.writeAsBytesSync(data!.buffer.asUint8List());
  });
}

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
}

void main() {
  setUpAll(() async {
    const fonts = 'C:/Windows/Fonts';
    const korean = ['$fonts/malgun.ttf', '$fonts/malgunbd.ttf'];
    await _loadFont('Roboto', korean);
    // 글꼴을 지정하지 않은 스타일(버튼 · 칩)은 테스트 기본 글꼴로 그려지므로 같이 덮는다.
    await _loadFont('FlutterTest', korean);
    await _loadFont('packages/material_symbols_icons/MaterialSymbolsRounded', [
      _pubCacheIconFont(),
    ]);
  });

  tearDown(() {});

  testWidgets('screenshots', (tester) async {
    addTearDown(tester.view.reset);
    // flutter_test는 그림자를 흐림 없이 그린다. 실제 모양대로 보이게 잠시 끈다.
    debugDisableShadows = false;

    await _setSize(tester, _phone);
    await tester.pumpWidget(_wrap(const OnboardingScreen()));
    await _shoot(tester, '01_onboarding_intro');

    await tester.tap(find.text('건너뛰기'));
    await _shoot(tester, '02_onboarding_language');

    await tester.pumpWidget(_wrap(const PermissionScreen()));
    await tester.tap(find.text('설정 열기').first);
    await _shoot(tester, '03_permission');

    await _setSize(tester, const Size(412, 1100));
    await tester.pumpWidget(_route(AppRoutes.home));
    await _shoot(tester, '04_home');

    await tester.tap(find.text('번역 시작'));
    await _shoot(tester, '05_home_running');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_route(AppRoutes.home, mode: ThemeMode.dark));
    await _shoot(tester, '06_home_dark');

    await _setSize(tester, const Size(412, 1500));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_route(AppRoutes.settings));
    await _shoot(tester, '07_settings');

    await _setSize(tester, const Size(412, 1300));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_route(AppRoutes.languages));
    await _shoot(tester, '08_languages');
    // 가짜 다운로드 타이머 정리
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));

    await _setSize(tester, _phone);
    await tester.pumpWidget(_route(AppRoutes.targetLanguage));
    await _shoot(tester, '09_target_language');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_wrap(const AboutScreen()));
    await _shoot(tester, '10_about');

    debugDisableShadows = true;
  });
}
