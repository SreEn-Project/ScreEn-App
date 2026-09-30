import 'package:get_it/get_it.dart';

import 'translator_api.g.dart';

// Pigeon 생성 API를 get_it에 등록한다 (NA-01). data 계층의 데이터소스만 쓴다 (D-018, D-023).
// 테스트에서는 리포지토리를 가짜로 바꿔 끼워 네이티브 없이 검증한다.

void registerBridge(GetIt sl) {
  sl
    ..registerLazySingleton<SettingsHostApi>(SettingsHostApi.new)
    ..registerLazySingleton<ServiceHostApi>(ServiceHostApi.new)
    ..registerLazySingleton<TranslatorEventBus>(
      () => TranslatorEventBus(events()),
    );
}

/// 네이티브 이벤트 채널은 리스너가 하나뿐이라, 한 번만 구독하고 앱 안에서 나눠 쓴다.
/// 현재 값이 필요하면 이벤트를 기다리지 말고 각 리포지토리의 조회 함수를 쓴다.
class TranslatorEventBus {
  TranslatorEventBus(Stream<TranslatorEvent> source)
    : stream = source.asBroadcastStream();

  final Stream<TranslatorEvent> stream;
}
