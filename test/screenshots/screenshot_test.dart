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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translation_poc_app/app/router.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';
import 'package:translation_poc_app/features/service/domain/entities/service_status.dart';
import 'package:translation_poc_app/app/theme/app_theme.dart';
import 'package:translation_poc_app/l10n/app_localizations.dart';

import 'package:translation_poc_app/features/vocabulary/domain/entities/vocabulary.dart';

import 'package:translation_poc_app/features/study_log/di.dart';
import 'package:translation_poc_app/features/study_log/domain/entities/study_streak.dart';
import 'package:translation_poc_app/features/study_log/domain/usecases/study_log_usecases.dart';

import 'package:translation_poc_app/features/history/domain/entities/history_entry.dart';

import '../fakes.dart';

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

String _pubCacheFont(String packagePrefix, String file) {
  final cache = Directory(
    '${Platform.environment['LOCALAPPDATA']}/Pub/Cache/hosted/pub.dev',
  );
  final dir =
      cache
          .listSync()
          .whereType<Directory>()
          .where((d) => d.path.contains(packagePrefix))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return '${dir.last.path}/$file';
}

/// 실제 라우터(하단 탭 포함)로 [location] 화면을 연다.
Widget _route(
  String location, {
  ThemeMode mode = ThemeMode.light,
  ServiceStatus service = ServiceStatus.stopped,
  FakeSettingsRepository? settings,
  FakeVocabularyRepository? vocabulary,
  StudyStreak? streak,
  FakeHistoryRepository? history,
}) => ProviderScope(
  overrides: [
    ...fakeNativeOverrides(
      service: service,
      settings: settings,
      vocabulary: vocabulary,
      history: history,
      permissionsGranted: location != AppRoutes.permission,
    ),
    if (streak != null)
      getStudyStreakProvider.overrideWithValue(_FakeStreak(streak)),
  ],
  child: MaterialApp.router(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: mode,
    locale: const Locale('ko'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: createRouter(initialLocation: location),
  ),
);

class _FakeStreak implements GetStudyStreak {
  _FakeStreak(this.value);
  final StudyStreak value;
  @override
  Future<StudyStreak> call() async => value;
}

Future<void> _shoot(
  WidgetTester tester,
  String name, {
  String dir = _outDir,
}) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
  final boundary = tester.renderObject(
    find.byType(RepaintBoundary).first,
  ) as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$dir/$name.png')..createSync(recursive: true);
    file.writeAsBytesSync(data!.buffer.asUint8List());
  });
}

/// 화면을 스크롤 전 / 스크롤 후(맨 아래) 두 장으로 찍는다. 스크롤할 게 없으면 한 장.
Future<void> _pair(WidgetTester tester, String name) async {
  const dir = '$_outDir/pairs';
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
  await _shoot(tester, '${name}_a_top', dir: dir);
  final scrollable = find.byType(Scrollable).first;
  final state = tester.state<ScrollableState>(scrollable);
  if (state.position.maxScrollExtent > 0) {
    state.position.jumpTo(state.position.maxScrollExtent);
    await _shoot(tester, '${name}_b_scrolled', dir: dir);
  }
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
    await _loadFont('packages/lucide_icons_flutter/Lucide', [
      _pubCacheFont('lucide_icons_flutter-', 'assets/lucide.ttf'),
    ]);
  });

  tearDown(() {});

  testWidgets('screenshots', (tester) async {
    addTearDown(tester.view.reset);
    // flutter_test는 그림자를 흐림 없이 그린다. 실제 모양대로 보이게 잠시 끈다.
    debugDisableShadows = false;

    await _setSize(tester, _phone);
    await tester.pumpWidget(_route(AppRoutes.onboarding));
    await _shoot(tester, '01_onboarding_intro');

    await tester.tap(find.text('건너뛰기'));
    await _shoot(tester, '02_onboarding_language');

    await tester.pumpWidget(_route(AppRoutes.permission));
    await tester.pumpAndSettle();
    await tester.tap(find.text('설정 열기'));
    await _shoot(tester, '03_permission');

    await _setSize(tester, const Size(412, 1100));
    await tester.pumpWidget(_route(AppRoutes.home));
    await _shoot(tester, '04_home');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _route(AppRoutes.home, service: ServiceStatus.running),
    );
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
    await tester.pumpWidget(_route(AppRoutes.about));
    await _shoot(tester, '10_about');

    // AI 번역 설정 (FL-09 · FL-11): 연령 확인 전 / 후
    await _setSize(tester, const Size(412, 1000));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_route(AppRoutes.aiSetup));
    await _shoot(tester, '11_ai_setup_age');

    await _setSize(tester, const Size(412, 1700));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _route(
        AppRoutes.aiSetup,
        settings: FakeSettingsRepository(
          const TranslatorSettings(
            onboardingCompleted: true,
            ageConfirmed: true,
            aiTone: AiTone.formal,
            glossary: [
              GlossaryEntry(source: 'Mana', target: '마나'),
              GlossaryEntry(source: 'Quest', target: '퀘스트'),
            ],
          ),
        ),
      ),
    );
    await _shoot(tester, '12_ai_setup_options');

    // 단어장 (AD-04 ~ AD-06)
    final vocabulary = FakeVocabularyRepository(
      books: [
        Wordbook(
          id: 1,
          name: '영어 기초',
          wordCount: 0,
          memorizedCount: 0,
          createdAt: DateTime(2026, 10, 1),
        ),
        Wordbook(
          id: 2,
          name: '게임 용어',
          wordCount: 0,
          memorizedCount: 0,
          createdAt: DateTime(2026, 10, 2),
        ),
      ],
      words: [
        for (final (i, w) in [
          ('apple', '사과'),
          ('journey', '여정'),
          ('reluctant', '꺼리는'),
        ].indexed)
          VocabularyWord(
            id: i + 1,
            wordbookId: 1,
            word: w.$1,
            meaning: w.$2,
            pronunciation: '/ˈæp.əl/',
            partOfSpeech: '명사',
            contextMeaning: '(과일) 사과',
            sentence: 'An apple a day keeps the doctor away.',
            sourceApp: 'Chrome',
            sourceLanguage: 'en',
            targetLanguage: 'ko',
            memorized: i == 1,
            savedAt: DateTime(2026, 10, 6, 9, 30 + i),
          ),
      ],
    );
    await _setSize(tester, _phone);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _route(AppRoutes.vocabulary, vocabulary: vocabulary),
    );
    await _shoot(tester, '13_wordbooks');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _route(AppRoutes.wordbookPath(1), vocabulary: vocabulary),
    );
    await _shoot(tester, '14_wordbook_detail');

    await _setSize(tester, const Size(412, 1000));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _route(AppRoutes.wordPath(1), vocabulary: vocabulary),
    );
    await _shoot(tester, '15_word_detail');

    // 홈 학습 기록 달력 칸 (오늘 학습 전 / 후)
    await _setSize(tester, const Size(412, 2000));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _route(
        AppRoutes.home,
        vocabulary: vocabulary,
        streak: StudyStreak(
          current: 3,
          best: 7,
          week: const [false, true, true, false, true, true, true],
          studiedToday: true,
          days: {
            for (final back in [8, 9, 10, 12, 15, 16])
              StudyStreak.formatDay(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day - back,
                ),
              ),
          },
        ),
      ),
    );
    await _shoot(tester, '16_home_study_done');
    // 달력 칸을 오른쪽으로 밀어 이전 주를 본다.
    await tester.drag(
      find.byWidgetPredicate(
        (w) => w is ListView && w.scrollDirection == Axis.horizontal,
      ),
      const Offset(300, 0),
    );
    await _shoot(tester, '18_home_study_scrolled');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _route(
        AppRoutes.home,
        vocabulary: vocabulary,
        streak: const StudyStreak(
          current: 2,
          best: 7,
          week: [false, true, true, false, true, true, false],
          studiedToday: false,
        ),
      ),
    );
    await _shoot(tester, '17_home_study_todo');

    // 홈 전체(기록 있음): 맨 위 / 맨 아래까지 스크롤
    await _setSize(tester, _phone);
    await tester.pumpWidget(const SizedBox());
    final now = DateTime.now();
    await tester.pumpWidget(
      _route(
        AppRoutes.home,
        vocabulary: vocabulary,
        history: FakeHistoryRepository([
          HistoryEntry(
            id: 1,
            original: 'Please sign in to continue',
            translated: '계속하려면 로그인해 주세요',
            sourceLanguage: 'en',
            targetLanguage: 'ko',
            translatedAt: now.subtract(const Duration(minutes: 20)),
          ),
          HistoryEntry(
            id: 2,
            original: 'Order summary',
            translated: '주문 요약',
            sourceLanguage: 'en',
            targetLanguage: 'ko',
            translatedAt: now.subtract(const Duration(hours: 3)),
          ),
          HistoryEntry(
            id: 3,
            original: 'Terms of service',
            translated: '서비스 약관',
            sourceLanguage: 'en',
            targetLanguage: 'ko',
            translatedAt: now.subtract(const Duration(hours: 5)),
          ),
        ]),
        streak: StudyStreak(
          current: 3,
          best: 7,
          week: const [false, true, true, false, true, true, true],
          studiedToday: true,
        ),
      ),
    );
    await _shoot(tester, '19_home_top');
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -700));
    await _shoot(tester, '20_home_middle');
    await tester.drag(scrollable, const Offset(0, -3000));
    await _shoot(tester, '21_home_bottom');

    // 화면별 스크롤 전 / 후
    final pairNow = DateTime.now();
    final pairHistory = FakeHistoryRepository([
      for (final (i, t) in [
        ('Please sign in to continue', '계속하려면 로그인해 주세요'),
        ('Order summary', '주문 요약'),
        ('Terms of service', '서비스 약관'),
        ('Your session has expired', '세션이 만료되었어요'),
        ('Add to cart', '장바구니에 담기'),
        ('Free shipping over 50 dollars', '50달러 이상 무료 배송'),
      ].indexed)
        HistoryEntry(
          id: i + 1,
          original: t.$1,
          translated: t.$2,
          sourceLanguage: 'en',
          targetLanguage: 'ko',
          translatedAt: pairNow.subtract(Duration(hours: i * 3 + 1)),
        ),
    ]);
    final pairStreak = StudyStreak(
      current: 3,
      best: 7,
      week: const [false, true, true, false, true, true, true],
      studiedToday: true,
    );
    await _setSize(tester, _phone);
    for (final (name, route) in [
      ('01_home', AppRoutes.home),
      ('02_wordbooks', AppRoutes.vocabulary),
      ('03_history', AppRoutes.history),
      ('04_settings', AppRoutes.settings),
      ('05_languages', AppRoutes.languages),
    ]) {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        _route(
          route,
          vocabulary: vocabulary,
          history: pairHistory,
          streak: pairStreak,
        ),
      );
      await _pair(tester, name);
      if (route == AppRoutes.languages) {
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 10));
      }
    }

    debugDisableShadows = true;
  });
}
