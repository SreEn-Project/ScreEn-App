import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/app_localizations.dart';
import '../../features/settings/domain/entities/translator_settings.dart';

/// Pigeon 열거형 → 화면 문구 · 아이콘. 여러 화면에서 같은 이름을 쓰도록 한곳에 둔다.
extension EnumLabels on AppLocalizations {
  String engineName(EngineType engine) => switch (engine) {
    EngineType.mlKit => engineMlKit,
    EngineType.gemini => engineGemini,
    EngineType.groq => engineGroq,
    EngineType.gemma => engineGemma,
  };

  String engineDetail(EngineType engine) => switch (engine) {
    EngineType.mlKit => engineMlKitDetail,
    EngineType.gemini => engineGeminiDetail,
    EngineType.groq => engineGroqDetail,
    EngineType.gemma => engineGemmaDetail,
  };

  /// 탭 등에 쓰는 짧은 서비스 이름.
  String engineBrand(EngineType engine) => switch (engine) {
    EngineType.mlKit => engineMlKit,
    EngineType.gemini => 'Gemini',
    EngineType.groq => 'Groq',
    EngineType.gemma => 'Gemma',
  };

  String apiKeyHintFor(EngineType engine) =>
      engine == EngineType.groq ? apiKeyHintGroq : apiKeyHint;

  String apiKeyIntroFor(EngineType engine) =>
      engine == EngineType.groq ? apiKeyIntroGroq : apiKeyIntro;

  String apiKeyGetFor(EngineType engine) =>
      engine == EngineType.groq ? apiKeyGetGroq : apiKeyGet;

  String aiToneName(AiTone tone) => switch (tone) {
    AiTone.standard => aiToneStandard,
    AiTone.formal => aiToneFormal,
    AiTone.informal => aiToneInformal,
  };

  String captureModeName(CaptureMode mode) => switch (mode) {
    CaptureMode.fullScreen => captureModeFull,
    CaptureMode.dragRegion => captureModeRegion,
    CaptureMode.fixedRegion => captureModeFixed,
  };

  String displayModeName(DisplayMode mode) => switch (mode) {
    DisplayMode.list => displayModeList,
    DisplayMode.paragraph => displayModeParagraph,
    DisplayMode.overlay => displayModeOverlay,
  };
}

IconData engineIcon(EngineType engine) => switch (engine) {
  EngineType.mlKit => Symbols.offline_bolt_rounded,
  EngineType.gemini => Symbols.key_rounded,
  EngineType.groq => Symbols.bolt_rounded,
  EngineType.gemma => Symbols.memory_rounded,
};

IconData captureModeIcon(CaptureMode mode) => switch (mode) {
  CaptureMode.fullScreen => Symbols.fullscreen_rounded,
  CaptureMode.dragRegion => Symbols.crop_rounded,
  CaptureMode.fixedRegion => Symbols.push_pin_rounded,
};
