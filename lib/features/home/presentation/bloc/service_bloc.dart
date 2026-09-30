import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../service/domain/entities/service_status.dart';
import '../../../service/domain/usecases/service_usecases.dart';

part 'service_event.dart';

/// 홈의 번역 시작/중지 (FL-03). 네이티브 서비스 상태를 그대로 따라간다.
/// 알림의 "중지"나 시스템에서 공유를 끈 경우에도 이벤트로 상태가 맞춰진다.
class ServiceBloc extends Bloc<ServiceEvent, ServiceStatus> {
  ServiceBloc({
    required GetServiceStatus getServiceStatus,
    required WatchServiceStatus watchServiceStatus,
    required StartTranslationService startTranslationService,
    required StopTranslationService stopTranslationService,
  }) : _getStatus = getServiceStatus,
       _watchStatus = watchServiceStatus,
       _start = startTranslationService,
       _stop = stopTranslationService,
       super(ServiceStatus.stopped) {
    on<ServiceSubscriptionRequested>(_onSubscriptionRequested);
    on<ServiceToggled>(_onToggled);
  }

  final GetServiceStatus _getStatus;
  final WatchServiceStatus _watchStatus;
  final StartTranslationService _start;
  final StopTranslationService _stop;

  Future<void> _onSubscriptionRequested(
    ServiceSubscriptionRequested event,
    Emitter<ServiceStatus> emit,
  ) async {
    emit(await _getStatus());
    await emit.forEach(_watchStatus(), onData: (status) => status);
  }

  /// 실행 중 → 중지, 그 밖(꺼짐 · 오류 · 동의 대기) → 시작.
  /// 동의 대기 중에 다시 누르면 동의 창을 다시 앞으로 가져온다 (다른 앱으로 갔다 온 경우).
  Future<void> _onToggled(ServiceToggled event, Emitter<ServiceStatus> emit) =>
      state == ServiceStatus.running ? _stop() : _start();
}
