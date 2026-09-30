import '../../../../core/domain/use_case.dart';
import '../entities/app_permissions.dart';
import '../repositories/permission_repository.dart';

/// 번역 서비스에 필요한 권한 확인 (FL-02).
final class CheckPermissions implements NoParamsUseCase<AppPermissions> {
  const CheckPermissions(this._repository);

  final PermissionRepository _repository;

  @override
  Future<AppPermissions> call() => _repository.check();
}

/// 알림 권한 요청 후 바뀐 상태를 돌려준다.
final class RequestNotificationPermission
    implements NoParamsUseCase<AppPermissions> {
  const RequestNotificationPermission(this._repository);

  final PermissionRepository _repository;

  @override
  Future<AppPermissions> call() async {
    await _repository.requestNotification();
    return _repository.check();
  }
}

/// 다른 앱 위에 표시 설정으로 보낸 뒤 바뀐 상태를 돌려준다.
final class RequestOverlayPermission
    implements NoParamsUseCase<AppPermissions> {
  const RequestOverlayPermission(this._repository);

  final PermissionRepository _repository;

  @override
  Future<AppPermissions> call() async {
    await _repository.requestOverlay();
    return _repository.check();
  }
}
