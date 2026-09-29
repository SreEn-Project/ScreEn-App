import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/bridge/bridge_providers.dart';
import '../../../core/bridge/translator_api.g.dart';
import '../domain/settings_repository.dart';
import '../domain/translator_settings.dart';

part 'pigeon_settings_repository.g.dart';

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  return PigeonSettingsRepository(
    api: ref.watch(settingsHostApiProvider),
    events: ref.watch(translatorEventBusProvider).stream,
  );
}

class PigeonSettingsRepository implements SettingsRepository {
  PigeonSettingsRepository({required this._api, required this._events});

  final SettingsHostApi _api;
  final Stream<TranslatorEvent> _events;

  @override
  Future<TranslatorSettings> load() async =>
      (await _api.getSettings()).toDomain();

  @override
  Stream<TranslatorSettings> watch() => _events
      .where((event) => event is SettingsChanged)
      .cast<SettingsChanged>()
      .map((event) => event.settings.toDomain());

  @override
  Future<void> setTargetLanguage(String languageCode) =>
      _api.setTargetLanguage(languageCode);

  @override
  Future<void> setEngine(EngineType engine) => _api.setEngine(engine);

  @override
  Future<void> setCaptureMode(CaptureMode mode) => _api.setCaptureMode(mode);

  @override
  Future<void> setDisplayMode(DisplayMode mode) => _api.setDisplayMode(mode);

  @override
  Future<void> setOnboardingCompleted(bool completed) =>
      _api.setOnboardingCompleted(completed);
}

extension on AppSettings {
  TranslatorSettings toDomain() => TranslatorSettings(
    targetLanguage: targetLanguage,
    engine: engine,
    captureMode: captureMode,
    displayMode: displayMode,
    onboardingCompleted: onboardingCompleted,
  );
}
