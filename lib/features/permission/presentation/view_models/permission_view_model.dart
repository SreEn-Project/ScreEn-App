import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di.dart';
import '../../domain/entities/app_permissions.dart';

part 'permission_view_model.g.dart';

/// 권한 안내 · 홈 시작 버튼이 함께 보는 권한 상태 (FL-02).
/// 시스템 설정에서 돌아오면 화면이 [refresh]를 불러 다시 확인한다.
@Riverpod(keepAlive: true)
class PermissionViewModel extends _$PermissionViewModel {
  @override
  Future<AppPermissions> build() => ref.read(checkPermissionsProvider)();

  Future<void> refresh() async {
    state = AsyncData(await ref.read(checkPermissionsProvider)());
  }

  Future<void> requestNotification() async {
    state = AsyncData(await ref.read(requestNotificationPermissionProvider)());
  }

  Future<void> requestOverlay() async {
    state = AsyncData(await ref.read(requestOverlayPermissionProvider)());
  }
}
