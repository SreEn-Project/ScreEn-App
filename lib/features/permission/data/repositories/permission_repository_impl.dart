import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/app_permissions.dart';
import '../../domain/repositories/permission_repository.dart';
import '../datasources/permission_system_data_source.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  const PermissionRepositoryImpl(this._dataSource);

  final PermissionSystemDataSource _dataSource;

  @override
  Future<AppPermissions> check() async {
    final overlay = await _dataSource.overlayStatus();
    final notification = await _dataSource.notificationStatus();
    return AppPermissions(
      overlay: overlay.isGranted,
      notification: notification.isGranted,
      notificationBlocked: notification.isPermanentlyDenied,
    );
  }

  @override
  Future<void> requestNotification() async {
    final status = await _dataSource.notificationStatus();
    if (status.isPermanentlyDenied) {
      await _dataSource.openAppSettingsScreen();
      return;
    }
    await _dataSource.requestNotification();
  }

  @override
  Future<void> requestOverlay() => _dataSource.requestOverlay();
}
