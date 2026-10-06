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
    quickLanguages: List.of(quickLanguages),
    autoTranslate: autoTranslate,
    autoShowDelayMs: autoShowDelayMs,
    hideAfterInteractionMs: hideAfterInteractionMs,
    wifiOnlyModelDownload: wifiOnlyModelDownload,
    buttonSizeDp: buttonSizeDp,
    buttonOpacityPercent: buttonOpacityPercent,
    hasFixedRegion: hasFixedRegion,
    ageConfirmed: ageConfirmed,
    aiTone: aiTone.toEntity(),
    glossary: [
      for (final e in glossary)
        GlossaryEntry(source: e.source, target: e.target),
    ],
  );
}

extension on pigeon.AiTone {
  AiTone toEntity() => switch (this) {
    pigeon.AiTone.standard => AiTone.standard,
    pigeon.AiTone.formal => AiTone.formal,
    pigeon.AiTone.informal => AiTone.informal,
  };
}

extension AiToneToPigeon on AiTone {
  pigeon.AiTone toPigeon() => switch (this) {
    AiTone.standard => pigeon.AiTone.standard,
    AiTone.formal => pigeon.AiTone.formal,
    AiTone.informal => pigeon.AiTone.informal,
  };
}

extension GlossaryEntryToPigeon on GlossaryEntry {
  pigeon.GlossaryEntry toPigeon() =>
      pigeon.GlossaryEntry(source: source, target: target);
}

extension on pigeon.EngineType {
  EngineType toEntity() => switch (this) {
    pigeon.EngineType.mlKit => EngineType.mlKit,
    pigeon.EngineType.gemini => EngineType.gemini,
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
    pigeon.DisplayMode.paragraph => DisplayMode.paragraph,
    pigeon.DisplayMode.overlay => DisplayMode.overlay,
  };
}

extension EngineTypeToPigeon on EngineType {
  pigeon.EngineType toPigeon() => switch (this) {
    EngineType.mlKit => pigeon.EngineType.mlKit,
    EngineType.gemini => pigeon.EngineType.gemini,
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
    DisplayMode.paragraph => pigeon.DisplayMode.paragraph,
    DisplayMode.overlay => pigeon.DisplayMode.overlay,
  };
}
