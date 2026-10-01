import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/about/presentation/screens/about_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/language/presentation/screens/language_picker_screen.dart';
import '../features/models/presentation/screens/language_models_screen.dart';
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
}

@riverpod
GoRouter router(Ref ref) {
  // UI 퍼블리싱 단계: 첫 실행 흐름을 확인하도록 온보딩에서 시작한다.
  // 온보딩 완료 여부에 따른 분기는 FL-01 기능 연결 때 redirect로 넣는다.
  return createRouter();
}

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
        builder: (context, state) =>
            LanguagePickerScreen(selectedCode: state.extra as String? ?? 'ko'),
      ),
      GoRoute(
        path: AppRoutes.quickLanguages,
        builder: (context, state) => const QuickLanguagesScreen(),
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
