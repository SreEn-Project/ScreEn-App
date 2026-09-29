import '../../../core/bridge/bridge_providers.dart';

/// 번역 포그라운드 서비스 상태 (NA-01). 시작 · 중지는 NA-02 / FL-03에서 추가.
abstract interface class ServiceRepository {
  Future<ServiceState> currentState();

  Stream<ServiceState> watchState();
}
