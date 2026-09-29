// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '화면 번역';

  @override
  String get homeGreeting => '안녕하세요';

  @override
  String get homeHeadline => '어떤 화면이든 번역해 드려요';

  @override
  String get homeHeadlineHighlight => '번역';

  @override
  String get homeNotifications => '알림';

  @override
  String get homeServiceStopped => '번역 서비스가 꺼져 있어요';

  @override
  String get homeServiceHint => '시작하면 다른 앱 위에 번역 버튼이 떠요';

  @override
  String get homeStart => '번역 시작';

  @override
  String get homeStatusTargetLanguage => '대상 언어';

  @override
  String get homeStatusEngine => '번역 엔진';

  @override
  String get homeStatusCaptureMode => '캡처 모드';

  @override
  String get homeCaptureModes => '캡처 모드';

  @override
  String get captureModeFull => '전체 화면';

  @override
  String get captureModeRegion => '영역 선택';

  @override
  String get captureModeFixed => '고정 영역';

  @override
  String get homeRecent => '최근 기록';

  @override
  String get homeRecentFilterAll => '전체';

  @override
  String get homeRecentFilterToday => '오늘';

  @override
  String get homeRecentFilterWeek => '이번 주';

  @override
  String get homeRecentEmpty => '아직 번역 기록이 없어요';

  @override
  String get languageKorean => '한국어';

  @override
  String get engineMlKit => '기기 내 번역 (ML Kit)';
}
