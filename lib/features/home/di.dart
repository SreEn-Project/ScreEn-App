import 'package:get_it/get_it.dart';

import 'presentation/bloc/service_bloc.dart';

// 홈 기능의 의존성 연결 (D-026). 유스케이스는 service 기능이 등록한다.

void registerHomeFeature(GetIt sl) {
  sl.registerFactory(
    () => ServiceBloc(
      getServiceStatus: sl(),
      watchServiceStatus: sl(),
      startTranslationService: sl(),
      stopTranslationService: sl(),
    ),
  );
}
