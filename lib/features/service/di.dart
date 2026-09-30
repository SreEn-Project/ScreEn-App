import 'package:get_it/get_it.dart';

import '../../core/bridge/bridge_module.dart';
import 'data/datasources/service_native_data_source.dart';
import 'data/repositories/service_repository_impl.dart';
import 'domain/repositories/service_repository.dart';
import 'domain/usecases/service_usecases.dart';

// 번역 서비스 기능의 의존성 연결 (D-018, D-026). 테스트는 ServiceRepository를 바꿔 끼운다.

void registerServiceFeature(GetIt sl) {
  sl
    ..registerLazySingleton<ServiceRepository>(
      () => ServiceRepositoryImpl(
        ServiceNativeDataSource(sl(), sl<TranslatorEventBus>().stream),
      ),
    )
    ..registerFactory(() => GetServiceStatus(sl()))
    ..registerFactory(() => WatchServiceStatus(sl()))
    ..registerFactory(() => StartTranslationService(sl()))
    ..registerFactory(() => StopTranslationService(sl()));
}
