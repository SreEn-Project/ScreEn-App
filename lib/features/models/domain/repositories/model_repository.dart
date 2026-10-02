/// 기기에 받아 둔 번역 언어 모델 (FL-05). 원본은 네이티브(ML Kit)가 가진 파일이다.
abstract interface class ModelRepository {
  /// 받아 둔 모델의 언어 코드들.
  Future<Set<String>> downloaded();

  /// 모델을 받는다. 끝나면 돌아오고, 실패하면 예외를 던진다.
  Future<void> download(String languageCode, {required bool wifiOnly});

  Future<void> delete(String languageCode);
}
