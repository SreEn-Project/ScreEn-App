import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_permissions.dart';
import '../../domain/usecases/permission_usecases.dart';

/// 권한 안내 · 홈 시작 버튼이 함께 보는 권한 상태 (FL-02).
/// 상태가 `null`이면 아직 확인 중이다. 시스템 설정에서 돌아오면 화면이 [refresh]를 부른다.
class PermissionCubit extends Cubit<AppPermissions?> {
  PermissionCubit({
    required CheckPermissions checkPermissions,
    required RequestNotificationPermission requestNotificationPermission,
    required RequestOverlayPermission requestOverlayPermission,
  }) : _check = checkPermissions,
       _requestNotification = requestNotificationPermission,
       _requestOverlay = requestOverlayPermission,
       super(null);

  final CheckPermissions _check;
  final RequestNotificationPermission _requestNotification;
  final RequestOverlayPermission _requestOverlay;

  Future<void> refresh() async => _emit(await _check());

  Future<void> requestNotification() async =>
      _emit(await _requestNotification());

  Future<void> requestOverlay() async => _emit(await _requestOverlay());

  // 권한 창이 떠 있는 사이 Cubit이 닫혔을 수 있다.
  void _emit(AppPermissions permissions) {
    if (!isClosed) emit(permissions);
  }
}
