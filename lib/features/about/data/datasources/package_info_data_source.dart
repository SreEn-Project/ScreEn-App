import 'package:package_info_plus/package_info_plus.dart';

/// 설치된 앱의 버전 정보 (package_info_plus).
class PackageInfoDataSource {
  const PackageInfoDataSource();

  Future<({String version, String buildNumber})> read() async {
    final info = await PackageInfo.fromPlatform();
    return (version: info.version, buildNumber: info.buildNumber);
  }
}
