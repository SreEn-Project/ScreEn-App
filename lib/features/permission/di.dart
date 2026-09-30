import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'data/datasources/permission_system_data_source.dart';
import 'data/repositories/permission_repository_impl.dart';
import 'domain/repositories/permission_repository.dart';
import 'domain/usecases/permission_usecases.dart';

part 'di.g.dart';

// 권한 기능의 의존성 연결 (D-018). 테스트는 permissionRepositoryProvider를 바꿔 끼운다.

@Riverpod(keepAlive: true)
PermissionRepository permissionRepository(Ref ref) =>
    const PermissionRepositoryImpl(PermissionSystemDataSource());

@riverpod
CheckPermissions checkPermissions(Ref ref) =>
    CheckPermissions(ref.watch(permissionRepositoryProvider));

@riverpod
RequestNotificationPermission requestNotificationPermission(Ref ref) =>
    RequestNotificationPermission(ref.watch(permissionRepositoryProvider));

@riverpod
RequestOverlayPermission requestOverlayPermission(Ref ref) =>
    RequestOverlayPermission(ref.watch(permissionRepositoryProvider));
