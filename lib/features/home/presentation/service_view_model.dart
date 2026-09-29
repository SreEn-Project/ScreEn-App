import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/bridge/bridge_providers.dart';
import '../../service/data/pigeon_service_repository.dart';

part 'service_view_model.g.dart';

/// 홈의 번역 시작/중지 (FL-03). 네이티브 서비스 상태를 그대로 따라간다.
/// 알림의 "중지"나 시스템에서 공유를 끈 경우에도 이벤트로 상태가 맞춰진다.
@riverpod
class ServiceViewModel extends _$ServiceViewModel {
  @override
  Stream<ServiceState> build() async* {
    final repository = ref.watch(serviceRepositoryProvider);
    yield await repository.currentState();
    yield* repository.watchState();
  }

  /// 꺼짐 · 오류 → 시작(캡처 동의부터), 실행 중 → 중지. 동의 대기 중에는 아무것도 하지 않는다.
  Future<void> toggle() async {
    final repository = ref.read(serviceRepositoryProvider);
    switch (state.value) {
      case ServiceState.running:
        await repository.stop();
      case ServiceState.starting:
        return;
      case ServiceState.stopped || ServiceState.error || null:
        await repository.start();
    }
  }
}
