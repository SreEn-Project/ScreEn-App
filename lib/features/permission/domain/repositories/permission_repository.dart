import '../entities/app_permissions.dart';

abstract interface class PermissionRepository {
  Future<AppPermissions> check();

  /// 알림 권한 팝업을 띄운다. 이미 막혔으면(두 번 거부) 앱 설정 화면을 연다.
  Future<void> requestNotification();

  /// "다른 앱 위에 표시" 시스템 설정 화면을 연다. 돌아오면 [check]로 다시 확인한다.
  Future<void> requestOverlay();
}
