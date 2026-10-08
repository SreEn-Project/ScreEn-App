import '../../../../core/bridge/translator_api.g.dart' as pigeon;

/// 네이티브 설정 API(Pigeon, DataStore 원본)를 감싼다.
class SettingsNativeDataSource {
  const SettingsNativeDataSource(this._api, this._events);

  final pigeon.SettingsHostApi _api;
  final Stream<pigeon.TranslatorEvent> _events;

  Future<pigeon.AppSettings> getSettings() => _api.getSettings();

  Stream<pigeon.AppSettings> watchSettings() => _events
      .where((event) => event is pigeon.SettingsChanged)
      .cast<pigeon.SettingsChanged>()
      .map((event) => event.settings);

  Future<void> setTargetLanguage(String code) => _api.setTargetLanguage(code);

  Future<void> setEngine(pigeon.EngineType engine) => _api.setEngine(engine);

  Future<void> setCaptureMode(pigeon.CaptureMode mode) =>
      _api.setCaptureMode(mode);

  Future<void> setDisplayMode(pigeon.DisplayMode mode) =>
      _api.setDisplayMode(mode);

  Future<void> setQuickLanguages(List<String> codes) =>
      _api.setQuickLanguages(codes);

  Future<void> setAutoTranslate(bool enabled) => _api.setAutoTranslate(enabled);

  Future<void> setAutoShowDelayMs(int ms) => _api.setAutoShowDelayMs(ms);

  Future<void> setHideAfterInteractionMs(int ms) =>
      _api.setHideAfterInteractionMs(ms);

  Future<void> setWifiOnlyModelDownload(bool enabled) =>
      _api.setWifiOnlyModelDownload(enabled);

  Future<void> setButtonSizeDp(int dp) => _api.setButtonSizeDp(dp);

  Future<void> setButtonOpacityPercent(int percent) =>
      _api.setButtonOpacityPercent(percent);

  Future<void> resetFixedRegion() => _api.resetFixedRegion();

  Future<void> setOnboardingCompleted(bool completed) =>
      _api.setOnboardingCompleted(completed);

  Future<void> setAgeConfirmed(bool confirmed) =>
      _api.setAgeConfirmed(confirmed);

  Future<void> setAiTone(pigeon.AiTone tone) => _api.setAiTone(tone);

  Future<void> setGlossary(List<pigeon.GlossaryEntry> entries) =>
      _api.setGlossary(entries);

  Future<String?> getApiKey(pigeon.EngineType engine) => _api.getApiKey(engine);

  Future<void> setApiKey(pigeon.EngineType engine, String apiKey) =>
      _api.setApiKey(engine, apiKey);

  Future<void> clearApiKey(pigeon.EngineType engine) =>
      _api.clearApiKey(engine);

  Future<String?> testApiKey(pigeon.EngineType engine, String apiKey) =>
      _api.testApiKey(engine, apiKey);

  Future<bool> isApiKeyPinEnabled() => _api.isApiKeyPinEnabled();

  Future<bool> verifyApiKeyPin(String pin) => _api.verifyApiKeyPin(pin);

  Future<bool> setApiKeyPin(String newPin, String? currentPin) =>
      _api.setApiKeyPin(newPin, currentPin);

  Future<bool> clearApiKeyPin(String currentPin) =>
      _api.clearApiKeyPin(currentPin);

  Future<void> resetApiKeyProtection() => _api.resetApiKeyProtection();
}
