import 'package:freezed_annotation/freezed_annotation.dart';

part 'translator_settings.freezed.dart';

/// 번역 엔진 (NA-11). AI 엔진은 3단계.
enum EngineType { mlKit, gemini, firebaseAi }

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

/// 사용자가 화면을 조작한 뒤 이전 번역(덮어쓰기)을 숨기기까지의 시간. 자동 번역과 무관하게 적용된다 (#35).
/// 0 = 바로, [hideNever] = 숨기지 않고 새 번역이 뜰 때까지 둔다.
const hideNever = -1;
const defaultHideAfterInteractionMs = 0;
const hideAfterInteractionChoicesMs = [0, 500, 1000, 2000, hideNever];

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
  }) = _TranslatorSettings;
}
