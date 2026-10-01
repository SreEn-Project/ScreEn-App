import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/translator_settings.dart';

part 'auto_translate_view_model.g.dart';

/// 자동 번역 설정 (#23): 켜짐 · 다시 번역 속도 · 이전 결과 숨김. 네이티브 설정(DataStore)이 원본이라
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

  Future<void> setSpeed(AutoSpeed speed) =>
      ref.read(changeAutoSpeedProvider)(speed);

  Future<void> setHide(int ms) => ref.read(changeAutoHideProvider)(ms);
}

/// 화면이 쓰는 자동 번역 설정 묶음.
class AutoTranslateSettings {
  const AutoTranslateSettings({
    this.enabled = false,
    this.speed = defaultAutoSpeed,
    this.hideMs = defaultAutoHideMs,
  });

  factory AutoTranslateSettings.of(TranslatorSettings s) =>
      AutoTranslateSettings(
        enabled: s.autoTranslate,
        speed: AutoSpeed.fromCheckInterval(s.autoCheckIntervalMs),
        hideMs: s.autoHideMs,
      );

  final bool enabled;
  final AutoSpeed speed;
  final int hideMs;

  @override
  bool operator ==(Object other) =>
      other is AutoTranslateSettings &&
      other.enabled == enabled &&
      other.speed == speed &&
      other.hideMs == hideMs;

  @override
  int get hashCode => Object.hash(enabled, speed, hideMs);
}
