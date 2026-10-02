import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/about/presentation/screens/about_screen.dart';
import '../features/history/presentation/screens/history_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/language/presentation/screens/language_picker_screen.dart';
import '../features/models/presentation/screens/language_models_screen.dart';
import '../features/settings/di.dart';
import '../features/settings/presentation/screens/quick_languages_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/permission/presentation/screens/permission_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import 'app_shell.dart';

part 'router.g.dart';

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const permission = '/permission';

  // 하단 탭 (AppShell)
  static const home = '/';
  static const languages = '/languages';
  static const settings = '/settings';

  // 탭 위로 덮는 화면
  static const targetLanguage = '/target-language';
  static const quickLanguages = '/quick-languages';
  static const about = '/about';
  static const history = '/history';
}

/// 첫 실행이면 온보딩, 이미 마쳤으면 홈에서 시작한다 (FL-01). 저장된 설정을 한 번 읽는다.
@Riverpod(keepAlive: true)
Future<String> startLocation(Ref ref) async {
  try {
    final settings = await ref.watch(getSettingsProvider)();
    return settings.onboardingCompleted ? AppRoutes.home : AppRoutes.onboarding;
  } catch (_) {
    // 설정을 못 읽으면 처음부터 안내한다 (온보딩은 다시 봐도 해가 없다).
    return AppRoutes.onboarding;
  }
}

/// [startLocationProvider]가 정해진 뒤에만 읽는다 (앱이 그때까지 기다린다).
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) => createRouter(
  initialLocation: ref.watch(startLocationProvider).requireValue,
);

/// 앱 라우터. 테스트 · 스크린샷에서 원하는 화면부터 열 때 [initialLocation]을 준다.
GoRouter createRouter({String initialLocation = AppRoutes.onboarding}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.permission,
        builder: (context, state) => const PermissionScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          _tab(AppRoutes.home, const HomeScreen()),
          _tab(AppRoutes.languages, const LanguageModelsScreen()),
          _tab(AppRoutes.settings, const SettingsScreen()),
        ],
      ),
      GoRoute(
        path: AppRoutes.targetLanguage,
        builder: (context, state) => const LanguagePickerScreen(),
      ),
      GoRoute(
        path: AppRoutes.quickLanguages,
        builder: (context, state) => const QuickLanguagesScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}

StatefulShellBranch _tab(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (context, state) => screen)],
);
