import 'package:get_it/get_it.dart';

import 'data/datasources/permission_system_data_source.dart';
import 'data/repositories/permission_repository_impl.dart';
import 'domain/repositories/permission_repository.dart';
import 'domain/usecases/permission_usecases.dart';
import 'presentation/bloc/permission_cubit.dart';

// 권한 기능의 의존성 연결 (D-018, D-023). 테스트는 PermissionRepository를 바꿔 끼운다.

void registerPermissionFeature(GetIt sl) {
  sl
    ..registerLazySingleton<PermissionRepository>(
      () => const PermissionRepositoryImpl(PermissionSystemDataSource()),
    )
    ..registerFactory(() => CheckPermissions(sl()))
    ..registerFactory(() => RequestNotificationPermission(sl()))
    ..registerFactory(() => RequestOverlayPermission(sl()))
    ..registerFactory(
      () => PermissionCubit(
        checkPermissions: sl(),
        requestNotificationPermission: sl(),
        requestOverlayPermission: sl(),
      ),
    );
}
