import '../entities/app_info.dart';

abstract interface class AppInfoRepository {
  Future<AppInfo> load();
}
