import 'package:permission_handler/permission_handler.dart';

/// permission_handler 플러그인을 감싼다. 플러그인 타입은 data 계층 밖으로 나가지 않는다.
/// (Flutter ↔ 우리 네이티브 코드는 Pigeon만 쓰지만, 검증된 플러그인은 그대로 쓴다.)
class PermissionSystemDataSource {
  const PermissionSystemDataSource();

  Future<PermissionStatus> overlayStatus() =>
      Permission.systemAlertWindow.status;

  Future<PermissionStatus> notificationStatus() =>
      Permission.notification.status;

  Future<PermissionStatus> requestNotification() =>
      Permission.notification.request();

  /// Android에서는 "다른 앱 위에 표시" 설정 화면으로 이동한다.
  Future<PermissionStatus> requestOverlay() =>
      Permission.systemAlertWindow.request();

  Future<bool> openAppSettingsScreen() => openAppSettings();
}
