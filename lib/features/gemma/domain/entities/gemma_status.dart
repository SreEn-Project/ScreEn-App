/// Gemma 온디바이스 모델 상태 (#174).
enum GemmaModelState { notDownloaded, downloading, ready }

/// 모델 받기 실패 이유. none = 실패 없음.
enum GemmaFailure {
  none,
  tokenRequired,
  licenseNotAccepted,
  network,
  notEnoughSpace,
  unknown,
}

class GemmaStatus {
  const GemmaStatus({
    this.state = GemmaModelState.notDownloaded,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.failure = GemmaFailure.none,
    this.hasToken = false,
    this.deviceRamMb = 0,
    this.minRamMb = 0,
  });

  final GemmaModelState state;
  final int downloadedBytes;
  final int totalBytes;
  final GemmaFailure failure;

  /// Hugging Face 토큰이 저장돼 있다 (값은 네이티브에만 있다).
  final bool hasToken;
  final int deviceRamMb;
  final int minRamMb;

  bool get isReady => state == GemmaModelState.ready;
  bool get isDownloading => state == GemmaModelState.downloading;

  /// 기기 메모리가 모델을 돌리기에 충분한가. 메모리를 모르면(0) 막지 않는다.
  bool get ramSufficient => deviceRamMb == 0 || deviceRamMb >= minRamMb;

  /// 0..1. 전체 크기를 모르면 null.
  double? get progress => totalBytes <= 0
      ? null
      : (downloadedBytes / totalBytes).clamp(0.0, 1.0).toDouble();
}
