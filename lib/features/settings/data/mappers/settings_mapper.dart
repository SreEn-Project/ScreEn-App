import '../../../../core/bridge/translator_api.g.dart' as pigeon;
import '../../domain/entities/translator_settings.dart';

// Pigeon 타입 ↔ 도메인 엔티티. 도메인은 Pigeon을 모른다 (D-018).

extension AppSettingsMapper on pigeon.AppSettings {
  TranslatorSettings toEntity() => TranslatorSettings(
    targetLanguage: targetLanguage,
    engine: engine.toEntity(),
    captureMode: captureMode.toEntity(),
    displayMode: displayMode.toEntity(),
    onboardingCompleted: onboardingCompleted,
  );
}

extension on pigeon.EngineType {
  EngineType toEntity() => switch (this) {
    pigeon.EngineType.mlKit => EngineType.mlKit,
    pigeon.EngineType.gemini => EngineType.gemini,
    pigeon.EngineType.firebaseAi => EngineType.firebaseAi,
  };
}

extension on pigeon.CaptureMode {
  CaptureMode toEntity() => switch (this) {
    pigeon.CaptureMode.fullScreen => CaptureMode.fullScreen,
    pigeon.CaptureMode.dragRegion => CaptureMode.dragRegion,
    pigeon.CaptureMode.fixedRegion => CaptureMode.fixedRegion,
  };
}

extension on pigeon.DisplayMode {
  DisplayMode toEntity() => switch (this) {
    pigeon.DisplayMode.list => DisplayMode.list,
    pigeon.DisplayMode.overlay => DisplayMode.overlay,
  };
}

extension EngineTypeToPigeon on EngineType {
  pigeon.EngineType toPigeon() => switch (this) {
    EngineType.mlKit => pigeon.EngineType.mlKit,
    EngineType.gemini => pigeon.EngineType.gemini,
    EngineType.firebaseAi => pigeon.EngineType.firebaseAi,
  };
}

extension CaptureModeToPigeon on CaptureMode {
  pigeon.CaptureMode toPigeon() => switch (this) {
    CaptureMode.fullScreen => pigeon.CaptureMode.fullScreen,
    CaptureMode.dragRegion => pigeon.CaptureMode.dragRegion,
    CaptureMode.fixedRegion => pigeon.CaptureMode.fixedRegion,
  };
}

extension DisplayModeToPigeon on DisplayMode {
  pigeon.DisplayMode toPigeon() => switch (this) {
    DisplayMode.list => pigeon.DisplayMode.list,
    DisplayMode.overlay => pigeon.DisplayMode.overlay,
  };
}
