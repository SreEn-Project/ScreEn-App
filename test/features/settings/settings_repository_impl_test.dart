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
      buttonSizeDp: 60,
      buttonOpacityPercent: 70,
      hasFixedRegion: true,
      ageConfirmed: true,
      aiTone: pigeon.AiTone.formal,
      glossary: [pigeon.GlossaryEntry(source: 'Mana', target: '마나')],
      gemmaPolish: true,
    );

void main() {
  late _MockSettingsHostApi api;
  late StreamController<pigeon.TranslatorEvent> events;
  late SettingsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(pigeon.EngineType.mlKit);
    registerFallbackValue(pigeon.AiTone.standard);
    registerFallbackValue(<pigeon.GlossaryEntry>[]);
  });

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
        buttonSizeDp: 60,
        buttonOpacityPercent: 70,
        hasFixedRegion: true,
        ageConfirmed: true,
        aiTone: AiTone.formal,
        glossary: [GlossaryEntry(source: 'Mana', target: '마나')],
        gemmaPolish: true,
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

    await repository.setEngine(EngineType.gemini);

    verify(() => api.setEngine(pigeon.EngineType.gemini)).called(1);
  });

  test('Gemma 도우미 설정을 Pigeon으로 전달한다', () async {
    when(() => api.setGemmaPolish(any())).thenAnswer((_) async {});

    await repository.setGemmaPolish(false);

    verify(() => api.setGemmaPolish(false)).called(1);
  });

  test('연령 확인 · 말투 · 용어집도 Pigeon 값으로 바꿔 저장한다', () async {
    when(() => api.setAgeConfirmed(any())).thenAnswer((_) async {});
    when(() => api.setAiTone(any())).thenAnswer((_) async {});
    when(() => api.setGlossary(any())).thenAnswer((_) async {});

    await repository.setAgeConfirmed(true);
    await repository.setAiTone(AiTone.informal);
    await repository.setGlossary([
      const GlossaryEntry(source: 'Mana', target: '마나'),
    ]);

    verify(() => api.setAgeConfirmed(true)).called(1);
    verify(() => api.setAiTone(pigeon.AiTone.informal)).called(1);
    final sent =
        verify(() => api.setGlossary(captureAny())).captured.single
            as List<pigeon.GlossaryEntry>;
    expect(sent.single.source, 'Mana');
    expect(sent.single.target, '마나');
  });
}
