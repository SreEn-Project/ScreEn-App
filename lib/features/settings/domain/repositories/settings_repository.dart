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
  Future<void> setAutoCheckIntervalMs(int ms);
  Future<void> setAutoSettleMs(int ms);
  Future<void> setOnboardingCompleted(bool completed);
}
