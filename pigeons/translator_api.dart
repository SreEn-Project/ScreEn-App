// Flutter ↔ 네이티브 통신 정의 (NA-01).
// 수정 후 재생성: dart run pigeon --input pigeons/translator_api.dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/bridge/translator_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut: 'android/app/src/main/kotlin/com/example/translation_poc_app/bridge/TranslatorApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.example.translation_poc_app.bridge',
    ),
    dartPackageName: 'translation_poc_app',
  ),
)
/// 번역 엔진 (NA-11). mlKit = 기기 내 번역, gemini = 내 API 키 (NA-13).
enum EngineType { mlKit, gemini }

/// 캡처 범위 (NA-06). 1단계는 fullScreen만 동작.
enum CaptureMode { fullScreen, dragRegion, fixedRegion }

/// 결과 표시 방식 (FL-07). list = 블록별 카드, paragraph = 나누지 않고 한 문단, overlay = 원문 위에 덮기(NA-22).
enum DisplayMode { list, paragraph, overlay }

/// AI 번역 말투 (FL-11). standard = 지정하지 않음(AI가 원문에 맞춤).
enum AiTone { standard, formal, informal }

/// 포그라운드 서비스 상태 (NA-02). starting = 화면 캡처 동의 대기 중.
/// error = 시작 실패 (동의 후 서비스 시작 실패 등). 다시 시작하면 벗어난다.
enum ServiceState { stopped, starting, running, error }

/// AI 번역 용어집 한 줄 (FL-11): 원문 표현을 항상 이 번역어로 옮긴다.
class GlossaryEntry {
  GlossaryEntry({required this.source, required this.target});

  String source;
  String target;
}

/// DataStore에 저장되는 설정 (NA-16).
class AppSettings {
  AppSettings({
    required this.targetLanguage,
    required this.engine,
    required this.captureMode,
    required this.displayMode,
    required this.onboardingCompleted,
    required this.quickLanguages,
    required this.autoTranslate,
    required this.autoShowDelayMs,
    required this.hideAfterInteractionMs,
    required this.wifiOnlyModelDownload,
    required this.buttonSizeDp,
    required this.buttonOpacityPercent,
    required this.hasFixedRegion,
    required this.ageConfirmed,
    required this.aiTone,
    required this.glossary,
  });

  /// BCP-47 언어 코드. 예: "ko", "en", "ja".
  String targetLanguage;
  EngineType engine;
  CaptureMode captureMode;
  DisplayMode displayMode;
  bool onboardingCompleted;

  /// 플로팅 버튼 "빠른 언어" 버블에 나올 대상 언어 코드들 (사용자 편집, 순서 유지).
  List<String> quickLanguages;

  /// 자동 번역 (#23): 번역한 뒤 화면이 바뀌면 알아서 다시 번역. 기본 꺼짐.
  bool autoTranslate;

  /// 자동 번역이 새 번역을 보여 주는 시점 (ms): 조작이 끝난 뒤 이 시간 이후. 0 = 번역이 되는 대로 바로.
  int autoShowDelayMs;

  /// 사용자가 화면을 조작한 뒤 이전 번역(덮어쓰기)을 숨기기까지의 시간 (ms). 자동 번역과 무관하게 적용된다.
  /// 0 = 바로, -1 = 숨기지 않고 새 번역이 뜰 때까지 둔다.
  int hideAfterInteractionMs;

  /// 언어 모델을 Wi-Fi에서만 받는다 (FL-05). 번역 중 자동으로 받을 때도 같다.
  bool wifiOnlyModelDownload;

  /// 플로팅 버튼 원 지름 (dp, FL-07).
  int buttonSizeDp;

  /// 플로팅 버튼 불투명도 (%, FL-07). 100 = 불투명.
  int buttonOpacityPercent;

  /// 고정 영역이 저장돼 있다 (FL-08). 영역 자체는 네이티브 전용이다.
  bool hasFixedRegion;

  /// 만 18세 이상임을 확인했다 (FL-09). 확인하기 전에는 AI 엔진을 고를 수 없다.
  bool ageConfirmed;

  /// AI 번역 말투 (FL-11).
  AiTone aiTone;

  /// AI 번역 용어집 (FL-11). 입력 순서 유지.
  List<GlossaryEntry> glossary;
}

@HostApi()
abstract class SettingsHostApi {
  @async
  AppSettings getSettings();

  @async
  void setTargetLanguage(String languageCode);

  @async
  void setEngine(EngineType engine);

  @async
  void setCaptureMode(CaptureMode mode);

  @async
  void setDisplayMode(DisplayMode mode);

  @async
  void setQuickLanguages(List<String> languageCodes);

  @async
  void setAutoTranslate(bool enabled);

  @async
  void setAutoShowDelayMs(int ms);

  @async
  void setHideAfterInteractionMs(int ms);

  @async
  void setWifiOnlyModelDownload(bool enabled);

  @async
  void setButtonSizeDp(int dp);

  @async
  void setButtonOpacityPercent(int percent);

  /// 저장된 고정 영역을 지운다 (FL-08). 다음에 고정 영역 번역을 시작하면 영역을 새로 고른다.
  @async
  void resetFixedRegion();

  @async
  void setOnboardingCompleted(bool completed);

  /// 만 18세 이상 확인을 기록한다 (FL-09).
  @async
  void setAgeConfirmed(bool confirmed);

  @async
  void setAiTone(AiTone tone);

  /// 용어집 전체를 바꾼다 (FL-11). 네이티브가 빈 칸 · 중복 · 개수를 정리해 저장한다.
  @async
  void setGlossary(List<GlossaryEntry> entries);

  /// 저장된 AI 번역 API 키 (NA-13). 없으면 null. 설정 화면에서 가려서 보여 주고 고치게 하려고 내보낸다.
  @async
  String? getApiKey();

  /// API 키를 Keystore로 암호화해 기기에만 저장한다.
  @async
  void setApiKey(String apiKey);

  @async
  void clearApiKey();

  /// 입력한 키로 아주 짧은 번역을 해 본다 (NA-13). 성공이면 null, 실패면 구글이 알려 준 이유(사람이 읽는 문장).
  @async
  String? testApiKey(String apiKey);
}

/// 언어 모델 관리 (FL-05, NA-12). 모델의 원본은 ML Kit이 기기에 받아 둔 파일이다.
@HostApi()
abstract class ModelHostApi {
  /// 기기에 받아 둔 언어 모델의 언어 코드들.
  @async
  List<String> getDownloadedLanguages();

  /// 언어 모델을 받는다. 끝나면 돌아온다 (이미 있으면 바로). Wi-Fi 전용이라 조건이 안 맞으면 실패한다.
  /// ML Kit이 진행률을 알려 주지 않아 중간 값은 없다.
  @async
  void downloadLanguage(String languageCode, bool wifiOnly);

  @async
  void deleteLanguage(String languageCode);
}

@HostApi()
abstract class ServiceHostApi {
  ServiceState getServiceState();

  /// 화면 캡처 동의를 받고 번역 서비스를 시작한다 (NA-02, NA-04).
  /// 결과는 이벤트(ServiceStateChanged)로 온다: starting → running, 거부하면 stopped.
  void startService();

  /// 번역 서비스를 멈춘다. 알림의 "중지"와 같다.
  void stopService();
}

/// 번역 기록 한 줄 (NA-23, FL-13): 번역된 블록 하나.
class TranslationRecord {
  TranslationRecord({
    required this.id,
    required this.original,
    required this.translated,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.engine,
    required this.createdAtMs,
  });

  int id;
  String original;
  String translated;
  String sourceLanguage;
  String targetLanguage;
  EngineType engine;

  /// 마지막으로 번역한 시각 (epoch ms).
  int createdAtMs;
}

/// 번역 기록 (NA-23, FL-13). 저장은 네이티브가 번역할 때 알아서 하고, Flutter는 조회 · 삭제만 한다.
@HostApi()
abstract class HistoryHostApi {
  /// 최신순. [query]는 원문 · 번역에서 찾을 글자(빈 문자열 = 전부), [sinceMs] 이후(epoch ms, 0 = 전체)만.
  @async
  List<TranslationRecord> getHistory(String query, int sinceMs, int limit);

  @async
  void deleteHistory(int id);

  @async
  void clearHistory();
}

/// 단어장 (AD-03, AD-04).
class Wordbook {
  Wordbook({
    required this.id,
    required this.name,
    required this.wordCount,
    required this.memorizedCount,
    required this.createdAtMs,
  });

  int id;
  String name;
  int wordCount;
  int memorizedCount;
  int createdAtMs;
}

/// 저장한 단어 (AD-03, AD-05, AD-06).
class VocabWord {
  VocabWord({
    required this.id,
    required this.wordbookId,
    required this.word,
    required this.meaning,
    this.pronunciation,
    this.partOfSpeech,
    this.contextMeaning,
    this.sentence,
    this.sourceApp,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.memorized,
    required this.createdAtMs,
  });

  int id;
  int wordbookId;
  String word;
  String meaning;
  String? pronunciation;
  String? partOfSpeech;

  /// 주변 문장 기준 문맥 뜻 (AI 엔진으로 저장했을 때만).
  String? contextMeaning;

  /// 단어를 고른 원래 문장.
  String? sentence;
  String? sourceApp;
  String sourceLanguage;
  String targetLanguage;
  bool memorized;

  /// 저장한 시각 (epoch ms).
  int createdAtMs;
}

enum VocabSort { newest, oldest, alphabetical }

/// 단어장 관리 (AD-04 ~ AD-06). 단어 저장(AD-03)은 오버레이(네이티브)가 직접 한다.
@HostApi()
abstract class VocabularyHostApi {
  /// 만든 순서대로. 단어 수 · 외운 단어 수 포함.
  @async
  List<Wordbook> getWordbooks();

  /// 같은 이름이 이미 있으면 그 단어장을 돌려준다. 이름이 비었으면 null.
  @async
  Wordbook? createWordbook(String name);

  /// 이름이 비었거나 다른 단어장과 겹치면 false.
  @async
  bool renameWordbook(int id, String name);

  /// 안의 단어도 함께 지운다.
  @async
  void deleteWordbook(int id);

  /// [query]는 단어 · 뜻에서 찾을 글자(빈 문자열 = 전부).
  @async
  List<VocabWord> getWords(int wordbookId, String query, VocabSort sort);

  @async
  VocabWord? getWord(int id);

  /// 다른 단어장으로 옮긴다. 거기에 같은 단어가 있으면 합친다(옮기는 쪽을 지운다).
  @async
  void moveWord(int id, int wordbookId);

  @async
  void deleteWord(int id);

  @async
  void setMemorized(int id, bool memorized);
}

/// 네이티브 → Flutter 이벤트. 구독 시 현재 상태를 먼저 한 번씩 보낸다.
sealed class TranslatorEvent {}

class ServiceStateChanged extends TranslatorEvent {
  ServiceStateChanged(this.state);
  ServiceState state;
}

class SettingsChanged extends TranslatorEvent {
  SettingsChanged(this.settings);
  AppSettings settings;
}

@EventChannelApi()
abstract class TranslatorEventApi {
  TranslatorEvent events();
}
