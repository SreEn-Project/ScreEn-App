import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/app_localizations.dart';
import '../../features/settings/domain/entities/translator_settings.dart';

/// Pigeon 열거형 → 화면 문구 · 아이콘. 여러 화면에서 같은 이름을 쓰도록 한곳에 둔다.
extension EnumLabels on AppLocalizations {
  String engineName(EngineType engine) => switch (engine) {
    EngineType.mlKit => engineMlKit,
    EngineType.gemini => engineGemini,
    EngineType.firebaseAi => engineFirebase,
  };

  String engineDetail(EngineType engine) => switch (engine) {
    EngineType.mlKit => engineMlKitDetail,
    EngineType.gemini => engineGeminiDetail,
    EngineType.firebaseAi => engineFirebaseDetail,
  };

  String captureModeName(CaptureMode mode) => switch (mode) {
    CaptureMode.fullScreen => captureModeFull,
    CaptureMode.dragRegion => captureModeRegion,
    CaptureMode.fixedRegion => captureModeFixed,
  };

  String displayModeName(DisplayMode mode) => switch (mode) {
    DisplayMode.list => displayModeList,
    DisplayMode.overlay => displayModeOverlay,
  };
}

IconData engineIcon(EngineType engine) => switch (engine) {
  EngineType.mlKit => Symbols.offline_bolt_rounded,
  EngineType.gemini => Symbols.key_rounded,
  EngineType.firebaseAi => Symbols.auto_awesome_rounded,
};

IconData captureModeIcon(CaptureMode mode) => switch (mode) {
  CaptureMode.fullScreen => Symbols.fullscreen_rounded,
  CaptureMode.dragRegion => Symbols.crop_rounded,
  CaptureMode.fixedRegion => Symbols.push_pin_rounded,
};
