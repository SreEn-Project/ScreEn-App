import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/translator_settings.dart';

part 'display_settings_view_model.g.dart';

/// 표시 설정 (FL-07): 결과 표시 방식 · 플로팅 버튼 크기 · 투명도. 네이티브 설정(DataStore)이 원본이라
/// 바꾸면 실행 중인 플로팅 버튼에 바로 반영되고, 이벤트로 다시 돌아와 화면이 갱신된다.
@riverpod
class DisplaySettingsViewModel extends _$DisplaySettingsViewModel {
  @override
  Stream<DisplaySettings> build() async* {
    yield DisplaySettings.of(await ref.watch(getSettingsProvider)());
    yield* ref.watch(watchSettingsProvider)().map(DisplaySettings.of);
  }

  Future<void> setMode(DisplayMode mode) =>
      ref.read(changeDisplayModeProvider)(mode);

  Future<void> setButtonSize(int dp) => ref.read(changeButtonSizeProvider)(dp);

  Future<void> setButtonOpacity(int percent) =>
      ref.read(changeButtonOpacityProvider)(percent);
}

/// 화면이 쓰는 표시 설정 묶음.
class DisplaySettings {
  const DisplaySettings({
    this.mode = DisplayMode.list,
    this.buttonSizeDp = defaultButtonSizeDp,
    this.buttonOpacityPercent = defaultButtonOpacityPercent,
  });

  factory DisplaySettings.of(TranslatorSettings s) => DisplaySettings(
    mode: s.displayMode,
    buttonSizeDp: s.buttonSizeDp,
    buttonOpacityPercent: s.buttonOpacityPercent,
  );

  final DisplayMode mode;
  final int buttonSizeDp;
  final int buttonOpacityPercent;

  @override
  bool operator ==(Object other) =>
      other is DisplaySettings &&
      other.mode == mode &&
      other.buttonSizeDp == buttonSizeDp &&
      other.buttonOpacityPercent == buttonOpacityPercent;

  @override
  int get hashCode => Object.hash(mode, buttonSizeDp, buttonOpacityPercent);
}
