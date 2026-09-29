import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/about/presentation/about_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/language/presentation/language_picker_screen.dart';
import '../features/models/presentation/language_models_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/permission/presentation/permission_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

part 'router.g.dart';

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const permission = '/permission';
  static const home = '/';
  static const settings = '/settings';
  static const targetLanguage = '/settings/language';
  static const languageModels = '/settings/models';
  static const about = '/settings/about';
}

@riverpod
GoRouter router(Ref ref) {
  // UI 퍼블리싱 단계: 첫 실행 흐름을 확인하도록 온보딩에서 시작한다.
  // 온보딩 완료 여부에 따른 분기는 FL-01 기능 연결 때 redirect로 넣는다.
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.permission,
        builder: (context, state) => const PermissionScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.targetLanguage,
        builder: (context, state) => const LanguagePickerScreen(),
      ),
      GoRoute(
        path: AppRoutes.languageModels,
        builder: (context, state) => const LanguageModelsScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}
