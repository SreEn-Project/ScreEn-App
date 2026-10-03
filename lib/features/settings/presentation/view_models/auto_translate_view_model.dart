import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/translator_settings.dart';

part 'auto_translate_view_model.g.dart';

/// 자동 번역 설정 (#23): 켜짐 · 새 번역을 보여 주는 시점 (#35). 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
@riverpod
class AutoTranslateViewModel extends _$AutoTranslateViewModel {
  @override
  Stream<AutoTranslateSettings> build() async* {
    yield AutoTranslateSettings.of(await ref.watch(getSettingsProvider)());
    yield* ref.watch(watchSettingsProvider)().map(AutoTranslateSettings.of);
  }

  Future<void> setEnabled(bool enabled) =>
      ref.read(changeAutoTranslateProvider)(enabled);

  Future<void> setShowDelay(int ms) =>
      ref.read(changeAutoShowDelayProvider)(ms);
}

/// 화면이 쓰는 자동 번역 설정 묶음.
class AutoTranslateSettings {
  const AutoTranslateSettings({
    this.enabled = false,
    this.showDelayMs = defaultAutoShowDelayMs,
    this.available = true,
  });

  factory AutoTranslateSettings.of(TranslatorSettings s) =>
      AutoTranslateSettings(
        enabled: s.autoTranslate,
        showDelayMs: s.autoShowDelayMs,
        available:
            s.captureMode != CaptureMode.dragRegion &&
            s.displayMode == DisplayMode.overlay,
      );

  final bool enabled;
  final int showDelayMs;

  /// 드래그 영역이거나 결과 표시가 '본문 위에 표시'가 아니면 자동 번역을 쓸 수 없다 (#71).
  final bool available;

  @override
  bool operator ==(Object other) =>
      other is AutoTranslateSettings &&
      other.enabled == enabled &&
      other.showDelayMs == showDelayMs &&
      other.available == available;

  @override
  int get hashCode => Object.hash(enabled, showDelayMs, available);
}
