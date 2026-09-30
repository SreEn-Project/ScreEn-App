import 'package:translation_poc_app/core/di/injector.dart';
import 'package:translation_poc_app/features/permission/domain/entities/app_permissions.dart';
import 'package:translation_poc_app/features/permission/domain/repositories/permission_repository.dart';
import 'package:translation_poc_app/features/service/domain/entities/service_status.dart';
import 'package:translation_poc_app/features/service/domain/repositories/service_repository.dart';

/// 네이티브 없이 화면을 띄우는 위젯 · 스크린샷 테스트용 가짜 서비스.
class FakeServiceRepository implements ServiceRepository {
  FakeServiceRepository([this._state = ServiceStatus.stopped]);

  ServiceStatus _state;

  @override
  Future<ServiceStatus> currentStatus() async => _state;

  @override
  Stream<ServiceStatus> watchStatus() => const Stream.empty();

  @override
  Future<void> start() async => _state = ServiceStatus.running;

  @override
  Future<void> stop() async => _state = ServiceStatus.stopped;
}

/// 요청하면 바로 허용되는 가짜 권한.
class FakePermissionRepository implements PermissionRepository {
  FakePermissionRepository({this.overlay = false, this.notification = false});

  bool overlay;
  bool notification;

  @override
  Future<AppPermissions> check() async =>
      AppPermissions(overlay: overlay, notification: notification);

  @override
  Future<void> requestNotification() async => notification = true;

  @override
  Future<void> requestOverlay() async => overlay = true;
}

/// 의존성을 새로 등록하고 네이티브 연결 리포지토리만 가짜로 바꾼다.
Future<void> setUpFakeNative({
  ServiceStatus service = ServiceStatus.stopped,
  bool permissionsGranted = false,
}) async {
  await getIt.reset();
  configureDependencies();
  getIt
    ..unregister<ServiceRepository>()
    ..registerSingleton<ServiceRepository>(FakeServiceRepository(service))
    ..unregister<PermissionRepository>()
    ..registerSingleton<PermissionRepository>(
      FakePermissionRepository(
        overlay: permissionsGranted,
        notification: permissionsGranted,
      ),
    );
}
