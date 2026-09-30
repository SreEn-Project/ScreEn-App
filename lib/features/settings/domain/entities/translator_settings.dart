import 'package:freezed_annotation/freezed_annotation.dart';

part 'translator_settings.freezed.dart';

/// 번역 엔진 (NA-11). AI 엔진은 3단계.
enum EngineType { mlKit, gemini, firebaseAi }

/// 캡처 범위 (NA-06). 1단계는 fullScreen만 동작.
enum CaptureMode { fullScreen, dragRegion, fixedRegion }

/// 결과 표시 방식 (FL-07). 1단계는 list만 동작.
enum DisplayMode { list, overlay }

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
  }) = _TranslatorSettings;
}
