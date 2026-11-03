import '../entities/gemma_status.dart';

/// 기기 안에서 도는 Gemma 번역 모델 (#174). 파일과 실행은 네이티브가 가진다.
abstract interface class GemmaRepository {
  Future<GemmaStatus> status();

  /// 받기를 시작하고 바로 돌아온다. 진행률은 [status]로 본다.
  Future<void> startDownload({required bool wifiOnly});

  Future<void> cancelDownload();

  Future<void> deleteModel();

  Future<void> setToken(String token);

  Future<void> clearToken();
}
