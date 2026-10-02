import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/translator_settings.dart';

part 'capture_settings_view_model.g.dart';

/// 캡처 모드 설정 (FL-08): 기본 캡처 모드 · 고정 영역 초기화. 네이티브 설정(DataStore)이 원본이라
/// 플로팅 버튼 메뉴에서 바꾼 모드도 이벤트로 돌아와 화면에 반영된다.
@riverpod
class CaptureSettingsViewModel extends _$CaptureSettingsViewModel {
  @override
  Stream<CaptureSettings> build() async* {
    yield CaptureSettings.of(await ref.watch(getSettingsProvider)());
    yield* ref.watch(watchSettingsProvider)().map(CaptureSettings.of);
  }

  Future<void> setMode(CaptureMode mode) =>
      ref.read(changeCaptureModeProvider)(mode);

  Future<void> resetFixedRegion() => ref.read(resetFixedRegionProvider)();
}

/// 화면이 쓰는 캡처 모드 설정 묶음.
class CaptureSettings {
  const CaptureSettings({
    this.mode = CaptureMode.fullScreen,
    this.hasFixedRegion = false,
  });

  factory CaptureSettings.of(TranslatorSettings s) =>
      CaptureSettings(mode: s.captureMode, hasFixedRegion: s.hasFixedRegion);

  final CaptureMode mode;
  final bool hasFixedRegion;

  @override
  bool operator ==(Object other) =>
      other is CaptureSettings &&
      other.mode == mode &&
      other.hasFixedRegion == hasFixedRegion;

  @override
  int get hashCode => Object.hash(mode, hasFixedRegion);
}
