import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'translator_api.g.dart';

part 'bridge_providers.g.dart';

// Pigeon 생성 API를 Riverpod으로 제공한다 (NA-01). data 계층의 데이터소스만 쓴다 (D-018).
// 테스트에서는 이 provider들을 override해 네이티브 없이 검증한다.

@Riverpod(keepAlive: true)
SettingsHostApi settingsHostApi(Ref ref) => SettingsHostApi();

@Riverpod(keepAlive: true)
ServiceHostApi serviceHostApi(Ref ref) => ServiceHostApi();

@Riverpod(keepAlive: true)
ModelHostApi modelHostApi(Ref ref) => ModelHostApi();

@Riverpod(keepAlive: true)
HistoryHostApi historyHostApi(Ref ref) => HistoryHostApi();

@Riverpod(keepAlive: true)
TranslatorEventBus translatorEventBus(Ref ref) => TranslatorEventBus(events());

/// 네이티브 이벤트 채널은 리스너가 하나뿐이라, 한 번만 구독하고 앱 안에서 나눠 쓴다.
/// 현재 값이 필요하면 이벤트를 기다리지 말고 각 리포지토리의 조회 함수를 쓴다.
class TranslatorEventBus {
  TranslatorEventBus(Stream<TranslatorEvent> source)
    : stream = source.asBroadcastStream();

  final Stream<TranslatorEvent> stream;
}
