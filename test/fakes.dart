import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:translation_poc_app/core/bridge/translator_api.g.dart';
import 'package:translation_poc_app/features/service/data/pigeon_service_repository.dart';
import 'package:translation_poc_app/features/permission/data/system_permission_repository.dart';
import 'package:translation_poc_app/features/permission/domain/app_permissions.dart';
import 'package:translation_poc_app/features/permission/domain/permission_repository.dart';
import 'package:translation_poc_app/features/service/domain/service_repository.dart';

/// 네이티브 없이 화면을 띄우는 위젯 · 스크린샷 테스트용 가짜 서비스.
class FakeServiceRepository implements ServiceRepository {
  FakeServiceRepository([this._state = ServiceState.stopped]);

  ServiceState _state;

  @override
  Future<ServiceState> currentState() async => _state;

  @override
  Stream<ServiceState> watchState() => const Stream.empty();

  @override
  Future<void> start() async => _state = ServiceState.running;

  @override
  Future<void> stop() async => _state = ServiceState.stopped;
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

/// 네이티브 연결 provider를 가짜로 바꾼다.
List<Override> fakeNativeOverrides({
  ServiceState service = ServiceState.stopped,
  bool permissionsGranted = false,
}) => [
  serviceRepositoryProvider.overrideWithValue(FakeServiceRepository(service)),
  permissionRepositoryProvider.overrideWithValue(
    FakePermissionRepository(
      overlay: permissionsGranted,
      notification: permissionsGranted,
    ),
  ),
];
