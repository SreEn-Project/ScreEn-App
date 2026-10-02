import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:translation_poc_app/core/bridge/translator_api.g.dart'
    as pigeon;
import 'package:translation_poc_app/features/settings/data/datasources/settings_native_data_source.dart';
import 'package:translation_poc_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:translation_poc_app/features/settings/domain/entities/translator_settings.dart';

class _MockSettingsHostApi extends Mock implements pigeon.SettingsHostApi {}

pigeon.AppSettings _pigeonSettings({String targetLanguage = 'ko'}) =>
    pigeon.AppSettings(
      targetLanguage: targetLanguage,
      engine: pigeon.EngineType.gemini,
      captureMode: pigeon.CaptureMode.fixedRegion,
      displayMode: pigeon.DisplayMode.overlay,
      onboardingCompleted: true,
      quickLanguages: ['en', 'ja'],
      autoTranslate: true,
      autoShowDelayMs: 2000,
      hideAfterInteractionMs: -1,
      wifiOnlyModelDownload: false,
    );

void main() {
  late _MockSettingsHostApi api;
  late StreamController<pigeon.TranslatorEvent> events;
  late SettingsRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(pigeon.EngineType.mlKit));

  setUp(() {
    api = _MockSettingsHostApi();
    events = StreamController<pigeon.TranslatorEvent>.broadcast();
    repository = SettingsRepositoryImpl(
      SettingsNativeDataSource(api, events.stream),
    );
  });

  tearDown(() => events.close());

  test('load는 Pigeon 설정을 도메인 엔티티로 바꾼다', () async {
    when(() => api.getSettings()).thenAnswer((_) async => _pigeonSettings());

    expect(
      await repository.load(),
      const TranslatorSettings(
        engine: EngineType.gemini,
        captureMode: CaptureMode.fixedRegion,
        displayMode: DisplayMode.overlay,
        onboardingCompleted: true,
        quickLanguages: ['en', 'ja'],
        autoTranslate: true,
        autoShowDelayMs: 2000,
        hideAfterInteractionMs: -1,
        wifiOnlyModelDownload: false,
      ),
    );
  });

  test('watch는 설정 변경 이벤트만 전달한다', () async {
    final received = repository.watch().first;

    events
      ..add(pigeon.ServiceStateChanged(state: pigeon.ServiceState.running))
      ..add(
        pigeon.SettingsChanged(settings: _pigeonSettings(targetLanguage: 'ja')),
      );

    expect((await received).targetLanguage, 'ja');
  });

  test('도메인 값을 Pigeon 값으로 바꿔 저장한다', () async {
    when(() => api.setEngine(any())).thenAnswer((_) async {});

    await repository.setEngine(EngineType.firebaseAi);

    verify(() => api.setEngine(pigeon.EngineType.firebaseAi)).called(1);
  });
}
