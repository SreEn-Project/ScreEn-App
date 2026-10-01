import '../../domain/entities/translator_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_native_data_source.dart';
import '../mappers/settings_mapper.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._dataSource);

  final SettingsNativeDataSource _dataSource;

  @override
  Future<TranslatorSettings> load() async =>
      (await _dataSource.getSettings()).toEntity();

  @override
  Stream<TranslatorSettings> watch() =>
      _dataSource.watchSettings().map((settings) => settings.toEntity());

  @override
  Future<void> setTargetLanguage(String languageCode) =>
      _dataSource.setTargetLanguage(languageCode);

  @override
  Future<void> setEngine(EngineType engine) =>
      _dataSource.setEngine(engine.toPigeon());

  @override
  Future<void> setCaptureMode(CaptureMode mode) =>
      _dataSource.setCaptureMode(mode.toPigeon());

  @override
  Future<void> setDisplayMode(DisplayMode mode) =>
      _dataSource.setDisplayMode(mode.toPigeon());

  @override
  Future<void> setQuickLanguages(List<String> languageCodes) =>
      _dataSource.setQuickLanguages(languageCodes);

  @override
  Future<void> setAutoTranslate(bool enabled) =>
      _dataSource.setAutoTranslate(enabled);

  @override
  Future<void> setAutoShowDelayMs(int ms) => _dataSource.setAutoShowDelayMs(ms);

  @override
  Future<void> setHideAfterInteractionMs(int ms) =>
      _dataSource.setHideAfterInteractionMs(ms);

  @override
  Future<void> setOnboardingCompleted(bool completed) =>
      _dataSource.setOnboardingCompleted(completed);
}
