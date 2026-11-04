import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/di.dart';
import '../../../settings/domain/entities/translator_settings.dart';
import '../../di.dart';
import '../../domain/entities/gemma_status.dart';

part 'gemma_view_model.g.dart';

/// Gemma 온디바이스 모델 화면 상태 (#174). 원본은 네이티브라 받는 중에는 [pollInterval]마다 다시 읽어 진행률을 갱신한다.
@riverpod
class GemmaViewModel extends _$GemmaViewModel {
  static const pollInterval = Duration(seconds: 1);

  Timer? _timer;

  @override
  Future<GemmaStatus> build() async {
    ref.onDispose(() => _timer?.cancel());
    final status = await ref.watch(getGemmaStatusProvider)();
    _schedulePoll(status);
    return status;
  }

  void _schedulePoll(GemmaStatus status) {
    _timer?.cancel();
    if (!status.isDownloading) return;
    _timer = Timer(pollInterval, refresh);
  }

  Future<void> refresh() async {
    try {
      final status = await ref.read(getGemmaStatusProvider)();
      state = AsyncData(status);
      _schedulePoll(status);
    } catch (_) {
      // 한 번 못 읽어도 다음 갱신에서 다시 시도한다.
      _timer = Timer(pollInterval, refresh);
    }
  }

  /// 받기를 시작한다. 설정의 "Wi-Fi에서만 받기"를 따른다. 메모리가 모자라면 시작하지 않는다.
  Future<void> download() async {
    final current = state.value;
    if (current != null && (current.isDownloading || current.isReady)) return;
    if (current != null && !current.ramSufficient) return;
    final settings = await ref.read(getSettingsProvider)();
    await ref.read(startGemmaDownloadProvider)(settings.wifiOnlyModelDownload);
    await refresh();
  }

  Future<void> cancel() async {
    await ref.read(cancelGemmaDownloadProvider)();
    await refresh();
  }

  Future<void> delete() async {
    await ref.read(deleteGemmaModelProvider)();
    // 모델이 없으면 Gemma를 1순위로 둘 수 없다 → ML Kit으로 되돌린다.
    final settings = await ref.read(getSettingsProvider)();
    if (settings.engine == EngineType.gemma) {
      await ref.read(changeEngineProvider)(EngineType.mlKit);
    }
    await refresh();
  }

  /// 토큰을 저장한다 (빈 값이면 지운다).
  Future<void> saveToken(String token) async {
    await ref.read(saveHuggingFaceTokenProvider)(token);
    await refresh();
  }
}
