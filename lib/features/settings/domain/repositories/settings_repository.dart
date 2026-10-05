import '../entities/translator_settings.dart';

abstract interface class SettingsRepository {
  Future<TranslatorSettings> load();

  /// 네이티브에서 설정이 바뀔 때마다 (다른 화면 · 서비스에서 바꾼 것 포함) 새 값을 낸다.
  Stream<TranslatorSettings> watch();

  Future<void> setTargetLanguage(String languageCode);
  Future<void> setEngine(EngineType engine);
  Future<void> setCaptureMode(CaptureMode mode);
  Future<void> setDisplayMode(DisplayMode mode);
  Future<void> setQuickLanguages(List<String> languageCodes);
  Future<void> setAutoTranslate(bool enabled);
  Future<void> setAutoShowDelayMs(int ms);
  Future<void> setHideAfterInteractionMs(int ms);
  Future<void> setWifiOnlyModelDownload(bool enabled);
  Future<void> setButtonSizeDp(int dp);
  Future<void> setButtonOpacityPercent(int percent);
  Future<void> resetFixedRegion();
  Future<void> setOnboardingCompleted(bool completed);

  /// AI 번역 API 키 (NA-13). 없으면 null.
  Future<String?> getApiKey();
  Future<void> setApiKey(String apiKey);
  Future<void> clearApiKey();
}
