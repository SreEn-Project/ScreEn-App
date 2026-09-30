import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_permissions.freezed.dart';

/// 번역 서비스에 필요한 권한 상태 (FL-02).
@freezed
abstract class AppPermissions with _$AppPermissions {
  const factory AppPermissions({
    /// 다른 앱 위에 표시 (SYSTEM_ALERT_WINDOW). 시스템 설정 화면에서만 켤 수 있다.
    required bool overlay,

    /// 알림 (POST_NOTIFICATIONS, Android 13+). 없으면 서비스 알림 · "중지"가 안 보인다.
    required bool notification,

    /// 알림을 두 번 거부해 팝업이 더 이상 뜨지 않는 상태. 이때는 앱 설정 화면으로 보낸다.
    @Default(false) bool notificationBlocked,
  }) = _AppPermissions;

  const AppPermissions._();

  bool get allGranted => overlay && notification;
}
