import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/core/bridge/translator_api.g.dart';
import 'package:translation_poc_app/features/settings/data/pigeon_settings_repository.dart';
import 'package:translation_poc_app/features/settings/domain/translator_settings.dart';

class _MockSettingsHostApi extends Mock implements SettingsHostApi {}

AppSettings _pigeonSettings({String targetLanguage = 'ko'}) => AppSettings(
  targetLanguage: targetLanguage,
  engine: EngineType.mlKit,
  captureMode: CaptureMode.fullScreen,
  displayMode: DisplayMode.list,
  onboardingCompleted: true,
);

void main() {
  late _MockSettingsHostApi api;
  late StreamController<TranslatorEvent> events;
  late PigeonSettingsRepository repository;

  setUp(() {
    api = _MockSettingsHostApi();
    events = StreamController<TranslatorEvent>.broadcast();
    repository = PigeonSettingsRepository(api: api, events: events.stream);
  });

  tearDown(() => events.close());

  test('load는 네이티브 설정을 도메인 모델로 바꾼다', () async {
    when(() => api.getSettings()).thenAnswer((_) async => _pigeonSettings());

    expect(
      await repository.load(),
      const TranslatorSettings(onboardingCompleted: true),
    );
  });

  test('watch는 설정 변경 이벤트만 전달한다', () async {
    final received = repository.watch().first;

    events
      ..add(ServiceStateChanged(state: ServiceState.running))
      ..add(SettingsChanged(settings: _pigeonSettings(targetLanguage: 'ja')));

    expect((await received).targetLanguage, 'ja');
  });

  test('setter는 네이티브 API를 그대로 호출한다', () async {
    when(() => api.setEngine(EngineType.gemini)).thenAnswer((_) async {});

    await repository.setEngine(EngineType.gemini);

    verify(() => api.setEngine(EngineType.gemini)).called(1);
  });
}
