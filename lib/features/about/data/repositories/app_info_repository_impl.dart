import '../../domain/entities/app_info.dart';
import '../../domain/repositories/app_info_repository.dart';
import '../datasources/package_info_data_source.dart';

class AppInfoRepositoryImpl implements AppInfoRepository {
  const AppInfoRepositoryImpl(this._dataSource);

  final PackageInfoDataSource _dataSource;

  @override
  Future<AppInfo> load() async {
    final info = await _dataSource.read();
    return AppInfo(version: info.version, buildNumber: info.buildNumber);
  }
}
