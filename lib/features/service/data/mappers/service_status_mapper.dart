import '../../../../core/bridge/translator_api.g.dart' as pigeon;
import '../../domain/entities/service_status.dart';

extension ServiceStateMapper on pigeon.ServiceState {
  ServiceStatus toEntity() => switch (this) {
    pigeon.ServiceState.stopped => ServiceStatus.stopped,
    pigeon.ServiceState.starting => ServiceStatus.waitingConsent,
    pigeon.ServiceState.running => ServiceStatus.running,
    pigeon.ServiceState.error => ServiceStatus.error,
  };
}
