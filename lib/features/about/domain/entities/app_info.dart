/// 앱 정보 (FL-14). 버전은 빌드 설정(pubspec)의 값이다.
final class AppInfo {
  const AppInfo({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  /// 화면에 보이는 버전. 빌드 번호가 있으면 "1.0.0 (3)".
  String get displayVersion =>
      buildNumber.isEmpty ? version : '$version ($buildNumber)';
}
