import 'package:get_it/get_it.dart';

import '../../core/bridge/bridge_module.dart';
import 'data/datasources/settings_native_data_source.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/settings_usecases.dart';

// 설정 기능의 의존성 연결 (D-018, D-023). 테스트는 SettingsRepository를 바꿔 끼운다.

void registerSettingsFeature(GetIt sl) {
  sl
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(
        SettingsNativeDataSource(sl(), sl<TranslatorEventBus>().stream),
      ),
    )
    ..registerFactory(() => GetSettings(sl()))
    ..registerFactory(() => WatchSettings(sl()))
    ..registerFactory(() => ChangeTargetLanguage(sl()))
    ..registerFactory(() => ChangeEngine(sl()))
    ..registerFactory(() => ChangeCaptureMode(sl()))
    ..registerFactory(() => ChangeDisplayMode(sl()))
    ..registerFactory(() => CompleteOnboarding(sl()));
}
