import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/app_permissions.dart';
import '../domain/permission_repository.dart';

part 'system_permission_repository.g.dart';

@Riverpod(keepAlive: true)
PermissionRepository permissionRepository(Ref ref) =>
    const SystemPermissionRepository();

/// permission_handler 플러그인으로 시스템 권한을 확인 · 요청한다.
/// (Flutter ↔ 우리 네이티브 코드는 Pigeon만 쓰지만, 검증된 플러그인은 그대로 쓴다.)
class SystemPermissionRepository implements PermissionRepository {
  const SystemPermissionRepository();

  @override
  Future<AppPermissions> check() async {
    final overlay = await Permission.systemAlertWindow.status;
    final notification = await Permission.notification.status;
    return AppPermissions(
      overlay: overlay.isGranted,
      notification: notification.isGranted,
      notificationBlocked: notification.isPermanentlyDenied,
    );
  }

  @override
  Future<void> requestNotification() async {
    final status = await Permission.notification.status;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }
    await Permission.notification.request();
  }

  @override
  Future<void> requestOverlay() async {
    // Android에서는 "다른 앱 위에 표시" 설정 화면으로 이동한다.
    await Permission.systemAlertWindow.request();
  }
}
