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
  String get permissionAllow => '허용하기';

  @override
  String get permissionContinue => '계속하기';

  @override
  String get permissionPending => '모두 허용하면 계속할 수 있어요';

  @override
  String get homeGreeting => '안녕하세요';

  @override
  String get homeHeadline => '어떤 화면이든\n번역해 드려요';

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
  String get homeStatusOff => '꺼짐';

  @override
  String get homeStatusOn => '실행 중';

  @override
  String get homeStarting => '동의 창 다시 열기';

  @override
  String get homeStatusStarting => '동의 대기';

  @override
  String get homeStatusError => '오류';

  @override
  String get homeServiceStartingHint => '화면 녹화 · 전송 동의 창에서 \"시작\"을 눌러 주세요';

  @override
  String get homeServiceErrorHint => '시작하지 못했어요. 다시 눌러 주세요';

  @override
  String get homePermissionsNeeded => '권한을 허용해야 시작할 수 있어요';

  @override
  String get homeSourceAuto => '자동 감지';

  @override
  String get homeSectionSetup => '번역 설정';

  @override
  String get homeTargetLanguage => '대상 언어';

  @override
  String get homeModels => '언어 모델';

  @override
  String homeModelsReady(int count) {
    return '$count개 준비됨';
  }

  @override
  String homeModelsDownloading(int count) {
    return '$count개 받는 중';
  }

  @override
  String get homeEngine => '번역 엔진';

  @override
  String get homeAreaHint => '번역 영역은 떠 있는 버튼을 길게 눌러 바꿀 수 있어요';

  @override
  String get navHome => '홈';

  @override
  String get navLanguages => '언어';

  @override
  String get navSettings => '설정';

  @override
  String get languagesTitle => '언어';

  @override
  String get languagesSectionTarget => '번역할 언어';

  @override
  String get languagesSectionDownload => '다운로드';

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
  String get historyTitle => '번역 기록';

  @override
  String get historySearchHint => '원문 · 번역 검색';

  @override
  String get historyNoResult => '찾는 기록이 없어요';

  @override
  String get historyDelete => '삭제';

  @override
  String get historyClearAll => '전체 삭제';

  @override
  String get historyClearConfirm => '정말 삭제';

  @override
  String get historyDetailTranslated => '번역';

  @override
  String get historyDetailOriginal => '원문';

  @override
  String get historyCopy => '복사';

  @override
  String get historyCopied => '복사됨';

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
  String get engineNeedsKey => 'API 키를 등록해야 쓸 수 있어요';

  @override
  String get engineNeedsAge => 'AI 번역 설정에서 만 18세 확인이 필요해요';

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
  String get settingsAiSetupDetail => 'Gemini API 키 등록';

  @override
  String get apiKeyTitle => 'AI 번역 설정';

  @override
  String get apiKeyHint => 'Gemini API 키를 붙여 넣으세요';

  @override
  String get apiKeyIntro =>
      'Google AI Studio에서 본인 키를 발급받아 여기에 붙여 넣으세요. 키는 암호화되어 이 기기에만 저장돼요. 번역할 글자는 구글로 보내지고, 실패하면 ML Kit으로 대신 번역해요.';

  @override
  String get apiKeySave => '키 저장';

  @override
  String get apiKeyRemove => '키 삭제';

  @override
  String get apiKeyRegistered => '키가 등록돼 있어요';

  @override
  String get apiKeyShow => '보기';

  @override
  String get apiKeyHide => '숨기기';

  @override
  String get apiKeyTest => '키 테스트';

  @override
  String get apiKeyTestOk => '키가 정상이에요';

  @override
  String apiKeyTestFailed(String reason) {
    return '실패: $reason';
  }

  @override
  String get apiKeyGet => 'Google AI Studio에서 키 발급받기';

  @override
  String get apiKeyPinTitle => '키 잠금 PIN';

  @override
  String get apiKeyPinDetail => '키를 보거나 고치거나 지울 때 4자리 PIN을 물어요';

  @override
  String get apiKeyPinChange => 'PIN 변경';

  @override
  String get apiKeyLockedTitle => 'API 키가 잠겨 있어요';

  @override
  String get apiKeyLockedBody => 'PIN을 입력하면 키를 보고 고칠 수 있어요.';

  @override
  String get apiKeyUnlock => 'PIN 입력';

  @override
  String get apiKeyPinForgot => 'PIN을 잊었어요';

  @override
  String get pinEnterTitle => 'PIN 입력';

  @override
  String get pinEnterBody => '4자리 숫자를 입력하세요.';

  @override
  String get pinCurrentTitle => '현재 PIN';

  @override
  String get pinNewTitle => '새 PIN 만들기';

  @override
  String get pinNewBody => '키를 잠글 4자리 숫자예요.';

  @override
  String get pinConfirmTitle => 'PIN 한 번 더';

  @override
  String get pinWrong => 'PIN이 달라요';

  @override
  String get pinMismatch => '처음 입력한 PIN과 달라요';

  @override
  String get pinResetTitle => '키를 지우고 초기화할까요?';

  @override
  String get pinResetBody =>
      'PIN을 잊으면 등록한 API 키를 지우고 PIN도 없애요. 키는 다시 등록해야 하고, AI 엔진은 ML Kit으로 돌아가요.';

  @override
  String get pinResetConfirm => '키 삭제하고 초기화';

  @override
  String get pinCancel => '취소';

  @override
  String get aiAgeTitle => '만 18세 이상이에요';

  @override
  String get aiAgeDetail =>
      'Gemini API 약관상 만 18세 미만은 AI 번역을 쓸 수 없어요. 확인해야 AI 번역을 켤 수 있어요.';

  @override
  String get aiNoticeTitle => '데이터 전송 안내';

  @override
  String get aiNoticeBody =>
      'AI 번역을 켜면 화면에서 읽은 글자가 내가 고른 AI 제공자(Google Gemini)로 전송돼요. 무료 등급에서는 구글이 이 글을 서비스 개선과 검토에 쓸 수 있어요. 비밀번호나 개인정보가 보이는 화면은 번역하지 마세요.';

  @override
  String get aiOptionsTitle => '번역 옵션';

  @override
  String get aiToneTitle => '말투';

  @override
  String get aiToneHint => 'AI 번역에만 적용돼요. 대상 언어에 높임말 구분이 있을 때 효과가 커요.';

  @override
  String get aiToneStandard => '기본';

  @override
  String get aiToneFormal => '존댓말';

  @override
  String get aiToneInformal => '반말';

  @override
  String get aiGlossaryTitle => '용어집';

  @override
  String get aiGlossaryDetail =>
      '원문 표현을 항상 정한 번역어로 옮겨요. 번역할 글에 나온 항목만 AI로 보내요.';

  @override
  String get aiGlossarySourceHint => '원문 (예: Mana)';

  @override
  String get aiGlossaryTargetHint => '번역어 (예: 마나)';

  @override
  String get aiGlossaryAdd => '용어 추가';

  @override
  String get aiGlossaryRemove => '삭제';

  @override
  String get aiGlossaryEmpty => '아직 등록한 용어가 없어요';

  @override
  String aiGlossaryFull(int max) {
    return '용어는 최대 $max개까지 등록할 수 있어요';
  }

  @override
  String get settingsSectionCapture => '캡처';

  @override
  String get settingsDefaultCaptureMode => '기본 캡처 모드';

  @override
  String get settingsResetFixedRegion => '고정 영역 초기화';

  @override
  String get settingsResetFixedRegionEmpty => '저장된 고정 영역이 없어요';

  @override
  String get settingsSectionDisplay => '표시';

  @override
  String get settingsDisplayMode => '결과 표시 방식';

  @override
  String get displayModeList => '목록';

  @override
  String get displayModeParagraph => '문단';

  @override
  String get displayModeOverlay => '원문 위에 덮기';

  @override
  String get settingsButtonSize => '플로팅 버튼 크기';

  @override
  String get settingsButtonOpacity => '플로팅 버튼 투명도';

  @override
  String get settingsQuickLanguages => '빠른 언어';

  @override
  String get settingsQuickLanguagesDetail => '플로팅 버튼 길게 누르기 메뉴에 보일 언어';

  @override
  String get quickLanguagesTitle => '빠른 언어 편집';

  @override
  String quickLanguagesHint(int count, int max, int min) {
    return '$count/$max개 선택 · 최소 $min개. 누르면 켜고 꺼요.';
  }

  @override
  String get settingsSectionAuto => '자동 번역';

  @override
  String get settingsAutoTranslate => '화면이 바뀌면 자동으로 번역';

  @override
  String get settingsAutoTranslateDetail =>
      '번역한 뒤 화면을 가볍게 지켜보다가, 글자가 바뀌거나 스크롤이 멈추면 바로 번역을 준비해요. 안 바뀐 글자는 건너뛰어요. 켜 두면 배터리를 더 쓰고 기기가 따뜻해질 수 있어요.';

  @override
  String get settingsAutoTranslateUnavailable =>
      '결과 표시가 \'본문 위에 표시\'이고 캡처 영역이 전체 화면이나 고정 영역일 때만 쓸 수 있어요.';

  @override
  String get settingsHideOverlayOnly => '본문 위에 표시에서만';

  @override
  String get settingsAutoShowDelay => '새 번역을 보여 줄 시점 (조작이 끝난 뒤)';

  @override
  String get settingsHideAfterInteraction => '화면을 조작하면 번역 결과를 닫기까지';

  @override
  String get settingsAutoInstant => '바로';

  @override
  String get settingsAutoNever => '직접 닫기';

  @override
  String secondsShort(String value) {
    return '$value초';
  }

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
  String get modelsDownloading => '받는 중';

  @override
  String get modelsDownloadFailed => '받지 못했어요. 인터넷 연결을 확인해 주세요';

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

  @override
  String get vocabTitle => '단어장';

  @override
  String get vocabHomeHint => '저장한 단어를 모아 봐요';

  @override
  String get vocabEmpty => '아직 단어장이 없어요';

  @override
  String get vocabEmptyHint => '만들어 두면 번역 중 단어를 바로 저장할 수 있어요';

  @override
  String get vocabNewBook => '새 단어장';

  @override
  String get vocabNameHint => '단어장 이름';

  @override
  String get vocabCreate => '만들기';

  @override
  String get vocabRename => '이름 변경';

  @override
  String get vocabDelete => '삭제';

  @override
  String get vocabCancel => '취소';

  @override
  String get vocabSave => '저장';

  @override
  String get vocabNameTaken => '같은 이름의 단어장이 있어요';

  @override
  String vocabWordCount(int count) {
    return '단어 $count개';
  }

  @override
  String vocabMemorizedCount(int count) {
    return '외움 $count개';
  }

  @override
  String vocabDeleteBookTitle(String name) {
    return '‘$name’ 단어장을 삭제할까요?';
  }

  @override
  String vocabDeleteBookBody(int count) {
    return '안의 단어 $count개도 함께 지워져요.';
  }

  @override
  String get vocabSearchHint => '단어 · 뜻 검색';

  @override
  String get vocabSortNewest => '최신순';

  @override
  String get vocabSortOldest => '오래된순';

  @override
  String get vocabSortAlphabetical => '이름순';

  @override
  String get vocabNoWords => '이 단어장은 비어 있어요';

  @override
  String get vocabNoResult => '찾는 단어가 없어요';

  @override
  String get vocabMove => '다른 단어장으로 이동';

  @override
  String get vocabMoveTitle => '이동할 단어장';

  @override
  String get vocabMoveNoOther => '이동할 다른 단어장이 없어요';

  @override
  String get vocabMemorizedLabel => '외운 단어';

  @override
  String get vocabWordDetailTitle => '단어 상세';

  @override
  String get vocabMeaning => '뜻';

  @override
  String get vocabPronunciation => '발음';

  @override
  String get vocabPartOfSpeech => '품사';

  @override
  String get vocabContextMeaning => '문맥 뜻';

  @override
  String get vocabSentence => '문맥 예문';

  @override
  String get vocabSourceApp => '출처';

  @override
  String get vocabSavedAt => '저장한 날';

  @override
  String get vocabDeleteWord => '단어 삭제';

  @override
  String get vocabDeleteWordTitle => '이 단어를 삭제할까요?';

  @override
  String get vocabWordGone => '이미 지워진 단어예요';

  @override
  String get vocabAddWord => '단어 추가';

  @override
  String get vocabAddToBook => '단어장에 추가';

  @override
  String get vocabWordHint => '단어';

  @override
  String get vocabMeaningHint => '뜻';

  @override
  String get vocabPronunciationHint => '발음 (선택)';

  @override
  String get vocabPartOfSpeechHint => '품사 (선택)';

  @override
  String get vocabContextMeaningHint => '문맥 뜻 (선택)';

  @override
  String get vocabSentenceHint => '예문 (선택)';

  @override
  String get vocabSaveTo => '저장할 단어장';

  @override
  String vocabSavedTo(String name) {
    return '‘$name’에 저장했어요';
  }

  @override
  String get vocabSaveFailed => '저장하지 못했어요. 단어와 뜻을 확인해 주세요';

  @override
  String get vocabHistoryAddTitle => '기록에서 단어 추가';

  @override
  String get learnTitle => '학습';

  @override
  String get learnPickBook => '학습할 단어장';

  @override
  String get learnNoBooks => '단어장이 아직 없어요';

  @override
  String get learnNoBooksHint => '번역 결과나 기록에서 단어를 저장하면 여기서 학습할 수 있어요';

  @override
  String get learnBook => '단어장';

  @override
  String learnBookStats(int count, int memorized) {
    return '단어 $count개 · 외움 $memorized개';
  }

  @override
  String get learnTypes => '학습 유형';

  @override
  String get learnTest => '암기 테스트';

  @override
  String get learnTestHint => '뜻을 보고 단어를 쓰거나, 보기에서 고르기';

  @override
  String get learnTestNeedWords => '단어를 하나 이상 저장하면 볼 수 있어요';

  @override
  String get learnCards => '카드 학습';

  @override
  String get learnGames => '미니게임';

  @override
  String get learnCardsHint => '카드를 뒤집어 뜻을 보고, 밀어서 외웠는지 나눠요';

  @override
  String get cardsTitle => '카드 학습';

  @override
  String cardsProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String cardsUnknownCount(int count) {
    return '못 외움 $count';
  }

  @override
  String cardsKnownCount(int count) {
    return '외움 $count';
  }

  @override
  String get cardsFlipHint => '카드를 탭하면 뒤집혀요';

  @override
  String get cardsSwipeHint => '왼쪽으로 밀면 못 외움, 오른쪽으로 밀면 외움';

  @override
  String get cardsKnown => '외웠어요';

  @override
  String get cardsUnknown => '못 외웠어요';

  @override
  String get cardsResultTitle => '카드 학습 결과';

  @override
  String cardsResultSummary(int known, int unknown) {
    return '$known개 외우고 $unknown개는 더 봐야 해요';
  }

  @override
  String get cardsAllKnown => '모두 외웠어요!';

  @override
  String get cardsReviewUnknown => '못 외운 단어만 다시 보기';

  @override
  String get cardsRestart => '처음부터 다시';

  @override
  String get cardsDone => '끝내기';

  @override
  String get cardsUnknownWords => '못 외운 단어';

  @override
  String get learnComingSoon => '준비 중이에요';

  @override
  String get testTitle => '암기 테스트';

  @override
  String get testStart => '시작하기';

  @override
  String testQuestionCount(int count) {
    return '$count문제';
  }

  @override
  String get testMode => '방식';

  @override
  String get testModeChoice => '4지선다';

  @override
  String get testModeTyping => '직접 입력';

  @override
  String get testModeChoiceHint => '단어를 보고 보기 4개 중 맞는 뜻을 골라요';

  @override
  String get testModeTypingHint => '뜻을 보고 단어를 직접 써요. 대소문자와 앞뒤 공백은 무시해요';

  @override
  String testChoiceUnavailable(int min) {
    return '4지선다는 단어장 전체에 단어가 $min개 이상일 때 쓸 수 있어요';
  }

  @override
  String get testCannotStart => '문제를 만들지 못했어요. 단어를 더 저장해 주세요';

  @override
  String testProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String testCorrectSoFar(int count) {
    return '정답 $count개';
  }

  @override
  String get testPromptMeaning => '이 뜻의 단어는?';

  @override
  String get testPromptWord => '이 단어의 뜻은?';

  @override
  String get testAnswerHint => '단어를 입력하세요';

  @override
  String get testSubmit => '확인';

  @override
  String get testNext => '다음 문제';

  @override
  String get testSeeResult => '결과 보기';

  @override
  String get testCorrect => '정답이에요!';

  @override
  String testWrong(String answer) {
    return '정답: $answer';
  }

  @override
  String get testResultTitle => '테스트 결과';

  @override
  String testScore(int correct, int total) {
    return '$correct / $total';
  }

  @override
  String get testPerfect => '모두 맞혔어요!';

  @override
  String testWrongCount(int count) {
    return '틀린 단어 $count개';
  }

  @override
  String get testWrongWords => '틀린 단어';

  @override
  String testYourAnswer(String answer) {
    return '내 답: $answer';
  }

  @override
  String get testRetry => '다시 풀기';

  @override
  String get testDone => '끝내기';

  @override
  String get vocabStudy => '단어 학습';

  @override
  String get vocabStudyHint => '암기 테스트로 단어를 확인해요';
}
