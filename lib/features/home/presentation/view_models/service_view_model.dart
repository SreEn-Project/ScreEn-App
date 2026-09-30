import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../service/di.dart';
import '../../../service/domain/entities/service_status.dart';

part 'service_view_model.g.dart';

/// 홈의 번역 시작/중지 (FL-03). 네이티브 서비스 상태를 그대로 따라간다.
/// 알림의 "중지"나 시스템에서 공유를 끈 경우에도 이벤트로 상태가 맞춰진다.
@riverpod
class ServiceViewModel extends _$ServiceViewModel {
  @override
  Stream<ServiceStatus> build() async* {
    yield await ref.watch(getServiceStatusProvider)();
    yield* ref.watch(watchServiceStatusProvider)();
  }

  /// 실행 중 → 중지, 그 밖(꺼짐 · 오류 · 동의 대기) → 시작.
  /// 동의 대기 중에 다시 누르면 동의 창을 다시 앞으로 가져온다 (다른 앱으로 갔다 온 경우).
  Future<void> toggle() async {
    if (state.value == ServiceStatus.running) {
      await ref.read(stopTranslationServiceProvider)();
    } else {
      await ref.read(startTranslationServiceProvider)();
    }
  }
}
