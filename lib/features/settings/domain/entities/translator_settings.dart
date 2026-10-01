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

/// 자동 번역 "다시 번역 속도" (#33). 화면 확인 간격과 조작이 끝난 뒤 기다리는 시간을 한 번에 정한다.
/// 빠를수록 바로 반응하지만 배터리를 더 쓴다. 저장은 네이티브의 두 값(ms)으로 하고, 읽을 때는
/// 확인 간격이 가장 가까운 단계로 되돌린다.
enum AutoSpeed {
  fast(checkIntervalMs: 500, settleMs: 0),
  normal(checkIntervalMs: 1000, settleMs: 0),
  saver(checkIntervalMs: 2000, settleMs: 1000),
  batterySaver(checkIntervalMs: 5000, settleMs: 2000);

  const AutoSpeed({required this.checkIntervalMs, required this.settleMs});

  final int checkIntervalMs;
  final int settleMs;

  /// 저장된 확인 간격(ms)에 가장 가까운 단계.
  static AutoSpeed fromCheckInterval(int ms) => values.reduce(
    (a, b) => (a.checkIntervalMs - ms).abs() <= (b.checkIntervalMs - ms).abs()
        ? a
        : b,
  );
}

const defaultAutoSpeed = AutoSpeed.normal;

/// [defaultAutoSpeed]의 저장값 (네이티브 `Settings` 기본값과 같게).
const defaultAutoCheckIntervalMs = 1000;
const defaultAutoSettleMs = 0;

/// 화면이 바뀐 뒤 이전 결과를 숨기기까지의 시간. 0 = 바로, [autoHideNever] = 새 결과가 뜰 때까지 둔다.
const autoHideNever = -1;
const defaultAutoHideMs = 0;
const autoHideChoicesMs = [0, 500, 1000, 2000, autoHideNever];

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

    /// 화면이 멈춘 뒤 번역하기까지 기다리는 시간 (ms). 0 = 바로.
    @Default(defaultAutoSettleMs) int autoSettleMs,

    /// 화면이 바뀐 뒤 이전 결과를 숨기기까지의 시간 (ms). [autoHideNever] = 숨기지 않음.
    @Default(defaultAutoHideMs) int autoHideMs,
  }) = _TranslatorSettings;
}
