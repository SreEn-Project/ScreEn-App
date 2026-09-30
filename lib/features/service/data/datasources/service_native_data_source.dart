import '../../../../core/bridge/translator_api.g.dart' as pigeon;

/// 네이티브 서비스 API(Pigeon)를 감싼다. Pigeon 타입은 data 계층 밖으로 나가지 않는다.
class ServiceNativeDataSource {
  const ServiceNativeDataSource(this._api, this._events);

  final pigeon.ServiceHostApi _api;
  final Stream<pigeon.TranslatorEvent> _events;

  Future<pigeon.ServiceState> getState() => _api.getServiceState();

  Stream<pigeon.ServiceState> watchState() => _events
      .where((event) => event is pigeon.ServiceStateChanged)
      .cast<pigeon.ServiceStateChanged>()
      .map((event) => event.state);

  Future<void> start() => _api.startService();

  Future<void> stop() => _api.stopService();
}
