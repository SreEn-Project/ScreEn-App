import 'package:get_it/get_it.dart';

import '../../features/home/di.dart';
import '../../features/permission/di.dart';
import '../../features/service/di.dart';
import '../../features/settings/di.dart';
import '../bridge/bridge_module.dart';

/// 앱 전체 의존성 컨테이너 (D-023). 화면은 BlocProvider로 Bloc · Cubit을 받고,
/// Bloc · Cubit을 만들 때만 여기서 꺼낸다.
final GetIt getIt = GetIt.instance;

/// 기능별 `di.dart`의 등록 함수를 모은다. 앱 시작 때 한 번 부른다.
/// 테스트는 [getIt]을 reset한 뒤 다시 부르고 리포지토리만 가짜로 바꾼다.
void configureDependencies() {
  registerBridge(getIt);
  registerPermissionFeature(getIt);
  registerServiceFeature(getIt);
  registerSettingsFeature(getIt);
  registerHomeFeature(getIt);
}
