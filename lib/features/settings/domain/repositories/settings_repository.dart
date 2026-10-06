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

  /// 만 18세 이상 확인 (FL-09). 거두면 네이티브가 엔진을 ML Kit으로 되돌린다.
  Future<void> setAgeConfirmed(bool confirmed);
  Future<void> setAiTone(AiTone tone);
  Future<void> setGlossary(List<GlossaryEntry> entries);

  /// AI 번역 API 키 (NA-13). 없으면 null.
  Future<String?> getApiKey();
  Future<void> setApiKey(String apiKey);
  Future<void> clearApiKey();

  /// 키를 실제로 호출해 본다. 성공이면 null, 실패면 구글이 알려 준 이유.
  Future<String?> testApiKey(String apiKey);
}
