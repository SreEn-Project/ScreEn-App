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

/// 자동 번역(#23) 화면 확인 간격 · 안정 대기 선택지 (ms). 네이티브 `Settings`의 범위 안이다.
const defaultAutoCheckIntervalMs = 2000;
const autoCheckIntervalChoicesMs = [1000, 2000, 3000, 5000];
const defaultAutoSettleMs = 1000;
const autoSettleChoicesMs = [500, 1000, 1500, 2000];

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

    /// 자동 번역의 화면 확인 간격 (ms). 짧을수록 열 · 배터리를 더 쓴다.
    @Default(defaultAutoCheckIntervalMs) int autoCheckIntervalMs,

    /// 화면이 멈춘 뒤 번역하기까지 기다리는 시간 (ms).
    @Default(defaultAutoSettleMs) int autoSettleMs,
  }) = _TranslatorSettings;
}
