import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/bridge/bridge_providers.dart';
import 'data/datasources/service_native_data_source.dart';
import 'data/repositories/service_repository_impl.dart';
import 'domain/repositories/service_repository.dart';
import 'domain/usecases/service_usecases.dart';

part 'di.g.dart';

// 번역 서비스 기능의 의존성 연결 (D-018). 테스트는 serviceRepositoryProvider를 바꿔 끼운다.

@Riverpod(keepAlive: true)
ServiceRepository serviceRepository(Ref ref) => ServiceRepositoryImpl(
  ServiceNativeDataSource(
    ref.watch(serviceHostApiProvider),
    ref.watch(translatorEventBusProvider).stream,
  ),
);

@riverpod
GetServiceStatus getServiceStatus(Ref ref) =>
    GetServiceStatus(ref.watch(serviceRepositoryProvider));

@riverpod
WatchServiceStatus watchServiceStatus(Ref ref) =>
    WatchServiceStatus(ref.watch(serviceRepositoryProvider));

@riverpod
StartTranslationService startTranslationService(Ref ref) =>
    StartTranslationService(ref.watch(serviceRepositoryProvider));

@riverpod
StopTranslationService stopTranslationService(Ref ref) =>
    StopTranslationService(ref.watch(serviceRepositoryProvider));
