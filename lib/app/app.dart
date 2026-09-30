import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'app_bloc_providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // UI 퍼블리싱 단계: 첫 실행 흐름을 확인하도록 온보딩에서 시작한다.
  // 온보딩 완료 여부에 따른 분기는 FL-01 기능 연결 때 redirect로 넣는다.
  final _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBlocProviders(
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // 기기 언어가 한국어 · 영어가 아니면 한국어로 보인다 (기본은 알파벳순 첫 언어인 영어).
        localeResolutionCallback: (locale, supported) => supported.firstWhere(
          (s) => s.languageCode == locale?.languageCode,
          orElse: () => const Locale('ko'),
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
