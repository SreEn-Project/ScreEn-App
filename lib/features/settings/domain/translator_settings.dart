import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/bridge/bridge_providers.dart';

part 'translator_settings.freezed.dart';

/// 번역 설정 (NA-16). 원본은 네이티브 DataStore이며 Flutter는 읽고 바꾸기만 한다.
/// 열거형은 Pigeon 생성 타입을 그대로 쓴다 (D-010).
@freezed
abstract class TranslatorSettings with _$TranslatorSettings {
  const factory TranslatorSettings({
    @Default('ko') String targetLanguage,
    @Default(EngineType.mlKit) EngineType engine,
    @Default(CaptureMode.fullScreen) CaptureMode captureMode,
    @Default(DisplayMode.list) DisplayMode displayMode,
    @Default(false) bool onboardingCompleted,
  }) = _TranslatorSettings;
}
