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
  String get commonNext => '다음';

  @override
  String get commonSkip => '건너뛰기';

  @override
  String get commonDone => '완료';

  @override
  String get commonOpenSettings => '설정 열기';

  @override
  String get commonAllowed => '허용됨';

  @override
  String get commonNotAllowed => '허용 필요';

  @override
  String get onboardingStart => '시작하기';

  @override
  String get onboardingIntro1Title => '보이는 그대로 번역해요';

  @override
  String get onboardingIntro1Highlight => '번역';

  @override
  String get onboardingIntro1Body =>
      '게임, 만화, SNS처럼 글자를 복사할 수 없는 화면도 찍어서 바로 번역해요.';

  @override
  String get onboardingIntro2Title => '버튼 하나면 충분해요';

  @override
  String get onboardingIntro2Highlight => '버튼';

  @override
  String get onboardingIntro2Body => '다른 앱 위에 떠 있는 버튼을 누르면 지금 화면의 글자를 읽어 번역해요.';

  @override
  String get onboardingIntro3Title => '기기 안에서 안전하게';

  @override
  String get onboardingIntro3Highlight => '안전';

  @override
  String get onboardingIntro3Body =>
      '기본 번역은 기기 안에서 처리돼요. 화면 이미지는 저장하거나 보내지 않아요.';

  @override
  String get onboardingLanguageTitle => '어떤 언어로 번역할까요?';

  @override
  String get onboardingLanguageHighlight => '언어';

  @override
  String get onboardingLanguageBody => '나중에 설정에서 바꿀 수 있어요.';

  @override
  String get languageSearchHint => '언어 검색';

  @override
  String get languageOcrUnsupported => '원문 인식 불가';

  @override
  String get languageEmpty => '찾는 언어가 없어요';

  @override
  String get languagePickerTitle => '대상 언어';

  @override
  String get permissionTitle => '두 가지만 허용해 주세요';

  @override
  String get permissionHighlight => '허용';

  @override
  String get permissionBody => '번역 버튼을 띄우고 실행 중임을 알리는 데 필요해요.';

  @override
  String get permissionOverlayTitle => '다른 앱 위에 표시';

  @override
  String get permissionOverlayBody => '어떤 앱을 쓰든 번역 버튼과 결과를 화면 위에 띄워요.';

  @override
  String get permissionNotificationTitle => '알림';

  @override
  String get permissionNotificationBody =>
      '번역 서비스가 켜져 있는 동안 알림으로 알려 주고, 거기서 바로 끌 수 있어요.';

  @override
  String get permissionContinue => '계속하기';

  @override
  String get permissionPending => '모두 허용하면 계속할 수 있어요';

  @override
  String get homeGreeting => '안녕하세요';

  @override
  String get homeHeadline => '어떤 화면이든 번역해 드려요';

  @override
  String get homeHeadlineHighlight => '번역';

  @override
  String get homeNotifications => '알림';

  @override
  String get homeSettings => '설정';

  @override
  String get homeServiceStopped => '번역 서비스가 꺼져 있어요';

  @override
  String get homeServiceRunning => '번역 서비스가 켜져 있어요';

  @override
  String get homeServiceHint => '시작하면 다른 앱 위에 번역 버튼이 떠요';

  @override
  String get homeServiceRunningHint => '다른 앱에서 번역 버튼을 눌러 보세요';

  @override
  String get homeStart => '번역 시작';

  @override
  String get homeStop => '번역 중지';

  @override
  String get homeStatusTargetLanguage => '대상 언어';

  @override
  String get homeStatusEngine => '번역 엔진';

  @override
  String get homeStatusCaptureMode => '캡처 모드';

  @override
  String get homeCaptureModes => '캡처 모드';

  @override
  String get homeRecent => '최근 기록';

  @override
  String get homeRecentSeeAll => '전체 보기';

  @override
  String get homeRecentFilterAll => '전체';

  @override
  String get homeRecentFilterToday => '오늘';

  @override
  String get homeRecentFilterWeek => '이번 주';

  @override
  String get homeRecentEmpty => '아직 번역 기록이 없어요';

  @override
  String get captureModeFull => '전체 화면';

  @override
  String get captureModeRegion => '영역 선택';

  @override
  String get captureModeFixed => '고정 영역';

  @override
  String get engineMlKit => '기기 내 번역';

  @override
  String get engineMlKitDetail => 'ML Kit · 오프라인 · 무료';

  @override
  String get engineGemini => '내 Gemini 키';

  @override
  String get engineGeminiDetail => '더 자연스러운 AI 번역 · API 키 필요';

  @override
  String get engineFirebase => '구글 로그인 AI';

  @override
  String get engineFirebaseDetail => '로그인만 하면 쓰는 AI 번역';

  @override
  String get engineNeedsKey => 'API 키를 등록해야 쓸 수 있어요';

  @override
  String get engineNeedsLogin => '구글 로그인과 연령 확인이 필요해요';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsSectionTranslation => '번역';

  @override
  String get settingsTargetLanguage => '대상 언어';

  @override
  String get settingsLanguageModels => '언어 모델 관리';

  @override
  String get settingsLanguageModelsDetail => '기기 내 번역에 쓰는 언어 파일';

  @override
  String get settingsSectionEngine => '번역 엔진';

  @override
  String get settingsAiSetup => 'AI 번역 설정';

  @override
  String get settingsAiSetupDetail => 'API 키 등록 · 구글 로그인';

  @override
  String get settingsSectionCapture => '캡처';

  @override
  String get settingsDefaultCaptureMode => '기본 캡처 모드';

  @override
  String get settingsResetFixedRegion => '고정 영역 초기화';

  @override
  String get settingsSectionDisplay => '표시';

  @override
  String get settingsDisplayMode => '결과 표시 방식';

  @override
  String get displayModeList => '목록';

  @override
  String get displayModeOverlay => '원문 위에 덮기';

  @override
  String get settingsButtonSize => '플로팅 버튼 크기';

  @override
  String get settingsButtonOpacity => '플로팅 버튼 투명도';

  @override
  String get settingsSectionEtc => '기타';

  @override
  String get settingsAbout => '앱 정보';

  @override
  String get modelsTitle => '언어 모델';

  @override
  String get modelsHeadline => '기기 내 번역 언어';

  @override
  String get modelsHighlight => '기기 내';

  @override
  String get modelsBody => '언어마다 약 30MB예요. 받아 두면 인터넷 없이도 번역해요.';

  @override
  String get modelsWifiOnly => 'Wi-Fi에서만 받기';

  @override
  String get modelsWifiOnlyDetail => '모바일 데이터를 쓰지 않아요';

  @override
  String get modelsInstalled => '설치됨';

  @override
  String get modelsNotInstalled => '받지 않음';

  @override
  String modelsDownloading(int percent) {
    return '받는 중 $percent%';
  }

  @override
  String modelsSize(int size) {
    return '약 ${size}MB';
  }

  @override
  String get modelsDownload => '받기';

  @override
  String get modelsDelete => '삭제';

  @override
  String get modelsCancel => '취소';

  @override
  String get modelsSectionInstalled => '받은 언어';

  @override
  String get modelsSectionAvailable => '받을 수 있는 언어';

  @override
  String get modelsTargetOnly => '대상 언어 전용';

  @override
  String get aboutTitle => '앱 정보';

  @override
  String get aboutVersion => '버전';

  @override
  String get aboutPrivacy => '개인정보처리방침';

  @override
  String get aboutLicenses => '오픈소스 라이선스';

  @override
  String get aboutPending => '준비 중';
}
