import '../entities/service_status.dart';

/// 번역 포그라운드 서비스 (NA-02). 상태의 원본은 네이티브다.
abstract interface class ServiceRepository {
  Future<ServiceStatus> currentStatus();

  /// 알림 · 시스템에서 끈 경우를 포함해 상태가 바뀔 때마다 낸다.
  Stream<ServiceStatus> watchStatus();

  /// 화면 캡처 동의를 받고 서비스를 시작한다. 결과는 [watchStatus]로 온다.
  Future<void> start();

  Future<void> stop();
}
