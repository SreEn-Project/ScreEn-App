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

  /// 실행 중 → 중지, 그 밖(꺼짐 · 오류 · 동의 대기) → 시작.
  /// 동의 대기 중에 다시 누르면 동의 창을 다시 앞으로 가져온다 (다른 앱으로 갔다 온 경우).
  Future<void> toggle() async {
    final repository = ref.read(serviceRepositoryProvider);
    if (state.value == ServiceState.running) {
      await repository.stop();
    } else {
      await repository.start();
    }
  }
}
