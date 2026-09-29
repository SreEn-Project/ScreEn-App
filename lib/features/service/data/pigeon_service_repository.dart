import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/bridge/bridge_providers.dart';
import '../../../core/bridge/translator_api.g.dart';
import '../domain/service_repository.dart';

part 'pigeon_service_repository.g.dart';

@Riverpod(keepAlive: true)
ServiceRepository serviceRepository(Ref ref) {
  return PigeonServiceRepository(
    api: ref.watch(serviceHostApiProvider),
    events: ref.watch(translatorEventBusProvider).stream,
  );
}

class PigeonServiceRepository implements ServiceRepository {
  PigeonServiceRepository({required this._api, required this._events});

  final ServiceHostApi _api;
  final Stream<TranslatorEvent> _events;

  @override
  Future<ServiceState> currentState() => _api.getServiceState();

  @override
  Stream<ServiceState> watchState() => _events
      .where((event) => event is ServiceStateChanged)
      .cast<ServiceStateChanged>()
      .map((event) => event.state);
}
