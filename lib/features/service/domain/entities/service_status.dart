/// 번역 포그라운드 서비스 상태 (NA-02).
enum ServiceStatus {
  stopped,

  /// 화면 캡처 동의를 기다리는 중.
  waitingConsent,
  running,

  /// 시작 실패. 다시 시작하면 벗어난다.
  error,
}
