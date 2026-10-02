import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/di.dart';

part 'target_language_view_model.g.dart';

/// 대상 언어 (FL-04). 네이티브 설정(DataStore)이 원본이라 바꾸면 이벤트로 다시 돌아와 화면이 갱신된다.
/// 홈 · 언어 탭 · 선택 화면이 함께 쓴다.
@riverpod
class TargetLanguageViewModel extends _$TargetLanguageViewModel {
  @override
  Stream<String> build() async* {
    yield (await ref.watch(getSettingsProvider)()).targetLanguage;
    yield* ref.watch(watchSettingsProvider)().map((s) => s.targetLanguage);
  }

  Future<void> select(String code) =>
      ref.read(changeTargetLanguageProvider)(code);
}

/// 언어 모델 화면의 Wi-Fi 전용 받기 스위치 (FL-05).
@riverpod
class WifiOnlyDownloadViewModel extends _$WifiOnlyDownloadViewModel {
  @override
  Stream<bool> build() async* {
    yield (await ref.watch(getSettingsProvider)()).wifiOnlyModelDownload;
    yield* ref
        .watch(watchSettingsProvider)()
        .map((s) => s.wifiOnlyModelDownload);
  }

  Future<void> setEnabled(bool enabled) =>
      ref.read(changeWifiOnlyModelDownloadProvider)(enabled);
}
