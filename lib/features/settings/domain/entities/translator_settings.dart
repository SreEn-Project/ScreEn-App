import 'package:freezed_annotation/freezed_annotation.dart';

part 'translator_settings.freezed.dart';

/// 번역 엔진 (NA-11). mlKit = 기기 내 번역, gemini · groq = 내 API 키 (NA-13).
enum EngineType {
  mlKit,
  gemini,
  groq;

  /// 사용자가 발급한 API 키가 있어야 쓰는 AI 엔진인가.
  bool get needsApiKey => this != mlKit;
}

/// AI 번역 말투 (FL-11). standard = 지정하지 않음 (AI가 원문에 맞춘다).
enum AiTone { standard, formal, informal }

/// AI 번역 용어집 한 줄 (FL-11): [source] 표현은 항상 [target]으로 옮긴다.
class GlossaryEntry {
  const GlossaryEntry({required this.source, required this.target});

  final String source;
  final String target;

  @override
  bool operator ==(Object other) =>
      other is GlossaryEntry &&
      other.source == source &&
      other.target == target;

  @override
  int get hashCode => Object.hash(source, target);
}

/// 용어집은 최대 [maxGlossaryEntries]개, 원문 · 번역어 각각 [maxGlossaryTextLength]자까지
/// (네이티브 `Settings.MAX_GLOSSARY_*`와 같게).
const maxGlossaryEntries = 50;
const maxGlossaryTextLength = 60;

/// 캡처 범위 (NA-06). 1단계는 fullScreen만 동작.
enum CaptureMode { fullScreen, dragRegion, fixedRegion }

/// 결과 표시 방식 (FL-07). 1단계는 list만 동작.
enum DisplayMode { list, paragraph, overlay }

/// 빠른 언어 기본값 (네이티브 `Settings.DEFAULT_QUICK_LANGUAGES`와 같게).
const defaultQuickLanguages = ['ko', 'en', 'ja', 'zh'];

/// 빠른 언어는 최소 1개, 최대 [maxQuickLanguages]개 (버블 옵션 메뉴가 화면을 넘지 않게).
const minQuickLanguages = 1;
const maxQuickLanguages = 8;

/// 자동 번역이 새 번역을 보여 주는 시점 (#35): 조작이 끝난 뒤 이 시간이 지나기 전에는 새 번역을 올리지 않는다.
/// 0 = 번역이 되는 대로 바로. 번역 작업 자체는 화면이 멈추면 바로 시작한다.
const defaultAutoShowDelayMs = 0;
const autoShowDelayChoicesMs = [0, 1000, 2000, 3000];

/// 사용자가 화면을 조작한 뒤 번역 결과(시트 · 덮어쓰기)를 닫기까지의 시간. 자동 번역과 무관하게 적용된다 (#35, #76).
/// 0 = 바로, [hideNever] = 직접 닫기: 결과가 뒤 앱을 막고 사용자가 닫을 때까지 둔다.
const hideNever = -1;
const defaultHideAfterInteractionMs = 0;
const hideAfterInteractionChoicesMs = [0, 500, 1000, 2000, hideNever];

/// 플로팅 버튼 원 지름 (dp, FL-07). 네이티브 `Settings.BUTTON_SIZE_RANGE_DP` · 기본값과 같게.
const minButtonSizeDp = 40;
const maxButtonSizeDp = 72;
const buttonSizeStepDp = 4;
const defaultButtonSizeDp = 52;

/// 플로팅 버튼 불투명도 (%, FL-07). 100 = 불투명.
const minButtonOpacityPercent = 30;
const maxButtonOpacityPercent = 100;
const buttonOpacityStepPercent = 10;
const defaultButtonOpacityPercent = 100;

/// [choices] 중 [value]에 가장 가까운 값.
int nearestChoice(List<int> choices, int value) =>
    choices.reduce((a, b) => (a - value).abs() <= (b - value).abs() ? a : b);

/// 번역 설정 (NA-16). 원본은 네이티브 DataStore이며 앱은 읽고 바꾸기만 한다.
@freezed
abstract class TranslatorSettings with _$TranslatorSettings {
  const factory TranslatorSettings({
    /// BCP-47 언어 코드. 예: "ko", "en".
    @Default('ko') String targetLanguage,
    @Default(EngineType.mlKit) EngineType engine,
    @Default(CaptureMode.fullScreen) CaptureMode captureMode,
    @Default(DisplayMode.list) DisplayMode displayMode,
    @Default(false) bool onboardingCompleted,

    /// 플로팅 버튼 "빠른 언어" 버블에 나올 대상 언어 코드들 (사용자 편집, 순서 유지).
    @Default(defaultQuickLanguages) List<String> quickLanguages,

    /// 자동 번역 (#23): 번역한 뒤 화면이 바뀌면 알아서 다시 번역. 기본 꺼짐.
    @Default(false) bool autoTranslate,

    /// 자동 번역이 새 번역을 보여 주는 시점 (ms). 0 = 번역이 되는 대로 바로.
    @Default(defaultAutoShowDelayMs) int autoShowDelayMs,

    /// 조작 뒤 이전 번역을 숨기기까지의 시간 (ms). [hideNever] = 숨기지 않음.
    @Default(defaultHideAfterInteractionMs) int hideAfterInteractionMs,

    /// 언어 모델을 Wi-Fi에서만 받는다 (FL-05).
    @Default(true) bool wifiOnlyModelDownload,

    /// 플로팅 버튼 원 지름 (dp, FL-07).
    @Default(defaultButtonSizeDp) int buttonSizeDp,

    /// 플로팅 버튼 불투명도 (%, FL-07).
    @Default(defaultButtonOpacityPercent) int buttonOpacityPercent,

    /// 고정 영역이 저장돼 있다 (FL-08). 영역 자체는 네이티브 전용.
    @Default(false) bool hasFixedRegion,

    /// 만 18세 이상 확인 (FL-09). 확인하기 전에는 AI 엔진을 고를 수 없다.
    @Default(false) bool ageConfirmed,

    /// AI 번역 말투 (FL-11).
    @Default(AiTone.standard) AiTone aiTone,

    /// AI 번역 용어집 (FL-11).
    @Default(<GlossaryEntry>[]) List<GlossaryEntry> glossary,
  }) = _TranslatorSettings;
}
